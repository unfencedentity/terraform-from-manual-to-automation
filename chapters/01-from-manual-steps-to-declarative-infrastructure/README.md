# Chapter 01 — From Manual Steps to Declarative Infrastructure

## Learning outcome

By the end of this chapter, you should be able to:

* explain the difference between imperative and declarative automation;
* recognize the structure of a basic Terraform resource block;
* explain the relationship between configuration, plan, apply, and state;
* predict whether Terraform will create, update, or destroy an object;
* distinguish values known before `apply` from values known only after `apply`;
* inspect a Terraform-managed object in state;
* explain why a second plan can report no changes;
* perform explicit and controlled cleanup.

This chapter uses the built-in `terraform_data` resource.

It does not create Azure infrastructure, require cloud credentials, or generate cloud costs.

---

## The problem before Terraform

Infrastructure can be created manually through:

* the Azure portal;
* Azure CLI commands;
* PowerShell scripts;
* REST API calls;
* step-by-step operational documentation.

These approaches can work, but they require us to describe the exact sequence of actions:

1. create an object;
2. configure it;
3. check whether it already exists;
4. update it if necessary;
5. handle failures;
6. repeat the same steps consistently.

The operator or script must control both:

* the desired result;
* the procedure used to reach that result.

As infrastructure grows, this becomes difficult to repeat, review, and maintain safely.

---

## Imperative and declarative thinking

An imperative instruction describes the actions to perform.

Example:

> Create one object, set its value, and update it later if the value changes.

A declarative configuration describes the desired end state.

Example:

```hcl
resource "terraform_data" "learning" {
  input = "manual-to-automation"
}
```

This configuration does not contain separate instructions such as:

* check whether the object exists;
* create it if it does not exist;
* compare its current input;
* update it if the input changed.

Terraform performs those comparisons by using the configuration, state, and provider-reported reality.

### PowerShell comparison

A PowerShell script usually describes a sequence of operations:

```powershell
New-Something
Set-Something
Get-Something
Remove-Something
```

Terraform configuration describes the result that should exist:

```hcl
resource "terraform_data" "learning" {
  input = "manual-to-automation"
}
```

The central question changes from:

> What commands should I execute?

to:

> What should exist when Terraform finishes?

---

## The first configuration

The configuration used in this chapter is:

```hcl
resource "terraform_data" "learning" {
  input = "manual-to-automation"
}
```

This is a small configuration, but it introduces the core mental model used by real Azure resources.

---

## Reading the configuration at four levels

### 1. Symbols and expressions

```hcl
resource
```

`resource` declares an object that Terraform will manage.

```hcl
"terraform_data"
```

This is the resource type.

The `terraform_data` resource is built into Terraform, so it does not require an external provider or cloud account.

```hcl
"learning"
```

This is the local resource name.

It identifies this particular resource inside the current Terraform configuration.

```hcl
input
```

This is an argument accepted by the `terraform_data` resource.

```hcl
"manual-to-automation"
```

This is a string value assigned to `input`.

### 2. The resource header

```hcl
resource "terraform_data" "learning"
```

The header contains:

```text
resource "<RESOURCE_TYPE>" "<LOCAL_NAME>"
```

Together, the resource type and local name form the Terraform resource address:

```text
terraform_data.learning
```

Terraform commands and state use this address to identify the object.

### 3. The resource block

```hcl
resource "terraform_data" "learning" {
  input = "manual-to-automation"
}
```

The braces define the body of the resource block.

Inside the block, arguments describe the desired configuration of the resource.

Here, the desired input is:

```text
manual-to-automation
```

### 4. The complete configuration

The complete configuration declares one managed object.

Terraform evaluates the configuration and determines whether the object must be:

* created;
* updated;
* replaced;
* destroyed;
* left unchanged.

The configuration itself does not directly perform those operations.

It describes the desired state that Terraform should compare with its current knowledge.

---

## The Terraform workflow

The basic workflow introduced in this chapter is:

```text
Write → Initialize → Validate → Plan → Review → Apply → Inspect
```

Cleanup is a separate, explicit operation:

```text
Plan destruction → Review → Destroy → Verify
```

---

## Step 1 — Initialize the working directory

```powershell
terraform init
```

Initialization prepares the current directory for Terraform operations.

For this configuration, Terraform reported:

```text
terraform.io/builtin/terraform is built in to Terraform
```

This means `terraform_data` is provided directly by Terraform.

No external provider plugin was required.

A successful initialization ended with:

```text
Terraform has been successfully initialized!
```

### Mental model

`terraform init` prepares the working directory.

It does not create the declared resource.

---

## Step 2 — Validate the configuration

```powershell
terraform validate
```

Validation checks whether the configuration is syntactically valid and internally consistent.

The expected result was:

```text
Success! The configuration is valid.
```

### What validation does not prove

A successful validation does not prove that:

* the planned operation is safe;
* the resource already exists;
* Azure credentials are valid;
* the configuration follows organizational standards;
* an `apply` will succeed;
* no destructive operation will occur.

Validation answers a limited question:

> Is this Terraform configuration structurally valid?

---

## Step 3 — Preview the proposed actions

```powershell
terraform plan
```

Terraform produced:

```text
Plan: 1 to add, 0 to change, 0 to destroy.
```

The `+` symbol indicated a create operation:

```text
+ create
```

Terraform planned to create:

```text
terraform_data.learning
```

### Why Terraform proposed one create operation

At that moment:

* the configuration declared one resource;
* the Terraform state did not contain that resource;
* therefore, Terraform detected one missing managed object.

The configuration described what should exist.

The state described what Terraform currently managed.

The difference between them produced the plan.

---

## Known before apply and known after apply

The first plan displayed values similar to:

```hcl
+ id     = (known after apply)
+ input  = "manual-to-automation"
+ output = (known after apply)
```

### Known before apply

Terraform already knew:

```hcl
input = "manual-to-automation"
```

The value was written directly in the configuration.

### Known after apply

Terraform did not yet know:

```hcl
id
output
```

Those values were computed while creating the resource.

Terraform represented them as:

```text
(known after apply)
```

### Mental model

A Terraform plan may contain both:

* known values available during planning;
* computed values that become available only during or after apply.

This distinction becomes important with Azure resources.

For example, a resource ID or provider-generated value may not exist until Azure accepts the create operation.

---

## Step 4 — Apply the reviewed plan

```powershell
terraform apply
```

Terraform generated and displayed a plan again, then requested explicit confirmation:

```text
Only 'yes' will be accepted to approve.
```

After the plan was reviewed, the operation was approved by entering:

```text
yes
```

Terraform reported:

```text
Apply complete! Resources: 1 added, 0 changed, 0 destroyed.
```

### Plan and apply are different operations

`terraform plan` previews proposed actions.

`terraform apply` performs approved actions and updates Terraform state.

A plan does not change infrastructure by itself.

An apply can create, modify, replace, or destroy managed objects.

The plan must always be inspected before approval.

---

## Step 5 — Inspect Terraform state

After apply, the managed resource could be listed with:

```powershell
terraform state list
```

The output contained:

```text
terraform_data.learning
```

This is the resource address stored in Terraform state.

More details could be inspected with:

```powershell
terraform state show terraform_data.learning
```

The state contained values such as:

```hcl
resource "terraform_data" "learning" {
  id     = "<generated-id>"
  input  = "manual-to-automation"
  output = "manual-to-automation"
}
```

### What state means

Terraform state is Terraform's record of the objects it manages.

It connects a resource address from the configuration:

```text
terraform_data.learning
```

to a managed object and its known attributes.

State is not simply a log file.

Terraform uses it when calculating future plans.

### The room inventory analogy

Imagine that the configuration says:

> The room should contain one chair.

Terraform state records:

> Terraform manages this particular chair.

The real environment contains the actual chair.

Terraform compares:

* the desired room;
* its inventory record;
* the real room.

From that comparison, Terraform determines the next action.

---

## Idempotence and the no-change plan

After apply, the configuration and state agreed.

Running another plan:

```powershell
terraform plan
```

reported:

```text
No changes. Your infrastructure matches the configuration.
```

The effective plan was:

```text
0 to add, 0 to change, 0 to destroy
```

Terraform did not create a duplicate object.

### Why this matters

A declarative system should converge toward the declared result.

Once the desired state is reached, running the same workflow again should not produce unnecessary changes.

This behavior is called idempotence.

---

## Updating the desired state

The input was changed from:

```hcl
input = "manual-to-automation"
```

to:

```hcl
input = "declarative-thinking"
```

The configuration now described a different desired value.

Running:

```powershell
terraform plan
```

produced:

```text
Plan: 0 to add, 1 to change, 0 to destroy.
```

Terraform displayed:

```text
~ update in-place
```

The `~` symbol indicated a modification.

The plan showed the value transition:

```text
"manual-to-automation" -> "declarative-thinking"
```

### Why this was an update instead of a replacement

Terraform determined that the `input` attribute could be updated without replacing the resource.

The resource address remained:

```text
terraform_data.learning
```

The generated ID also remained unchanged after apply.

This demonstrated an in-place update.

### Important safety lesson

Not every Terraform attribute can be updated in place.

With real Azure resources, some changes require replacement.

A replacement may appear in a plan as:

```text
-/+
```

or:

```text
+/- 
```

Replacement can mean deleting an existing resource and creating another one.

Always inspect the complete plan instead of assuming that a change is safe.

---

## Applying and verifying the update

The update was applied with:

```powershell
terraform apply
```

Terraform reported:

```text
Apply complete! Resources: 0 added, 1 changed, 0 destroyed.
```

State was inspected again:

```powershell
terraform state show terraform_data.learning
```

The updated values included:

```hcl
input  = "declarative-thinking"
output = "declarative-thinking"
```

A final plan:

```powershell
terraform plan
```

reported no changes.

This confirmed that configuration and state had converged again.

---

## Controlled destruction

Before cleanup, the destruction plan was inspected with:

```powershell
terraform plan -destroy
```

Terraform reported:

```text
Plan: 0 to add, 0 to change, 1 to destroy.
```

The `-` symbol represented destruction.

Only after reviewing the destruction plan was cleanup performed:

```powershell
terraform destroy
```

Terraform requested explicit confirmation and then reported:

```text
Destroy complete! Resources: 1 destroyed.
```

---

## What happens to state during destroy

Before destruction, state contained:

```text
terraform_data.learning
```

After destruction:

```powershell
terraform state list
```

returned no resource addresses.

Terraform had:

1. destroyed the managed object;
2. removed the object's record from the current state.

Removing an object from state means Terraform no longer has a current state entry connecting the resource address to that managed object.

---

## Destroy is not the same as forgetting

These operations have different meanings.

### `terraform destroy`

```powershell
terraform destroy
```

Terraform attempts to delete the real managed object and then updates state.

### `terraform state rm`

```powershell
terraform state rm <RESOURCE_ADDRESS>
```

Terraform removes the state association without deleting the real object.

The real object may continue to exist, but Terraform no longer manages it through that state.

`terraform state rm` was not used in this chapter.

State manipulation is powerful and potentially dangerous. It will be studied later with import, refactoring, and recovery scenarios.

---

## Why the next plan proposed creation again

After destroy, the configuration still contained:

```hcl
resource "terraform_data" "learning" {
  input = "declarative-thinking"
}
```

The state no longer contained the resource.

Therefore, another:

```powershell
terraform plan
```

proposed:

```text
Plan: 1 to add, 0 to change, 0 to destroy.
```

This is expected.

The configuration still said:

> This object should exist.

Destroy removed the object, but it did not rewrite the configuration.

As long as the resource remains declared and absent from state, Terraform will attempt to create it again on the next apply.

---

## The complete conceptual flow

### Inputs

Values provided directly or indirectly to the configuration.

In this chapter:

```hcl
"manual-to-automation"
```

### Configuration

The desired state written in Terraform language:

```hcl
resource "terraform_data" "learning" {
  input = "manual-to-automation"
}
```

### Dependency graph

Terraform analyzes resource references and constructs a dependency graph.

This configuration contained only one independent resource, so the graph was simple.

In Azure configurations, the graph determines ordering.

For example, a subnet may depend on a virtual network, and a virtual machine network interface may depend on a subnet.

### Plan

Terraform compares the desired configuration with its current knowledge and provider-reported reality.

The plan describes proposed actions such as:

* create;
* update in place;
* replace;
* destroy;
* no change.

### Apply

Terraform performs the reviewed actions after approval.

### State

Terraform records managed object identities and known attributes.

### Outputs

Resources can expose values used by other resources or explicit Terraform output blocks.

For `terraform_data`, the `output` attribute became known after apply.

The complete flow is:

```text
Inputs → Configuration → Dependency Graph → Plan → Apply → State → Outputs
```

---

## Mapping the model to Azure

The same model applies to real Azure infrastructure.

Example:

```hcl
resource "azurerm_resource_group" "learning" {
  name     = "rg-terraform-learning"
  location = "westeurope"
}
```

Terraform would conceptually:

1. read the desired resource group configuration;
2. build the dependency graph;
3. compare configuration, state, and Azure-reported reality;
4. produce a plan;
5. call the Azure API during apply;
6. store the managed resource identity and attributes in state;
7. use that information during future plans.

The Azure portal displays the real resource.

Terraform configuration declares what should exist.

Terraform state connects the configuration address to the Azure resource.

---

## Common mistakes

### Treating Terraform like a top-to-bottom script

Terraform configuration is not primarily a sequence of commands.

Block order usually does not define execution order.

Terraform derives ordering mainly from resource references and dependencies.

### Confusing configuration with state

Configuration describes the desired result.

State records Terraform's current managed-object knowledge.

They are related, but they are not the same thing.

### Assuming plan performs the changes

A plan previews actions.

Apply performs them.

### Applying without reading the plan

A syntactically valid configuration can still produce destructive actions.

Always inspect:

```text
to add
to change
to destroy
```

Also inspect each affected resource and attribute.

### Assuming every update is in place

Some changes require resource replacement.

Replacement can cause downtime, data loss, or a new resource identity.

### Destroying while leaving the declaration in configuration

Destroy removes the managed object.

If the resource remains declared, the next plan proposes creation again.

### Forgetting to save the file

Terraform reads the version stored on disk.

Unsaved editor changes are not part of the configuration Terraform evaluates.

### Committing Terraform state

State may contain:

* resource IDs;
* infrastructure metadata;
* generated values;
* sensitive values;
* values that are no longer present in current configuration.

State files and their backups must not be committed.

---

## State safety

The following files must remain outside version control:

```text
*.tfstate
*.tfstate.*
*.tfplan
tfplan
```

The `.gitignore` file in this repository excludes Terraform state and saved plan files.

However, `.gitignore` is only one safety layer.

Before every commit, inspect:

```powershell
git status
```

Never commit:

* `terraform.tfstate`;
* `terraform.tfstate.backup`;
* saved plan files;
* credentials;
* secrets;
* private keys;
* generated provider cache directories.

State backups can contain older values even after the current state changes.

Treat state and state backups as sensitive data.

---

## Interview questions

### What is the difference between imperative and declarative automation?

Imperative automation describes the operations to perform and their sequence.

Declarative automation describes the desired end state. Terraform determines the actions needed to move from the current state to the desired state.

### What does `terraform plan` do?

It evaluates the configuration, state, and provider-reported reality to propose the actions Terraform would take.

It does not normally apply those actions.

### Why is Terraform state required?

State connects Terraform resource addresses to managed objects and stores known attributes used to calculate future changes.

### What does `known after apply` mean?

Terraform cannot determine the final value during planning. The value will be computed during or after the apply operation.

### Why did the second plan report no changes?

The desired configuration already matched the managed object recorded in state. Terraform had reached convergence.

### What is an in-place update?

Terraform modifies an existing managed object without destroying and recreating it.

### Does a valid configuration guarantee a safe apply?

No.

Validation checks configuration structure and internal consistency. Safety must be evaluated by reviewing the plan and understanding the affected infrastructure.

### Why did Terraform propose creation after destroy?

The object was removed, but its resource block remained in configuration. The desired state still required the object to exist.

### What is the difference between `terraform destroy` and `terraform state rm`?

`terraform destroy` deletes managed infrastructure and updates state.

`terraform state rm` removes Terraform's state association without deleting the real object.

---

## Exercise

The guided exercise is located at:

```text
exercise/main.tf
```

Complete the TODOs without opening the solution first.

The intended configuration must declare:

* resource type: `terraform_data`;
* local name: `learning`;
* input value: `manual-to-automation`.

Before each command, predict the result.

Questions to ask:

* What will Terraform detect?
* What will appear in the plan?
* What is known before apply?
* What is known only after apply?
* What will be stored in state?
* Is the proposed operation a create, update, replacement, or destroy?
* Is the operation safe?

---

## Solution

The reference solution is located at:

```text
solution/main.tf
```

Use it only after completing the exercise or when diagnosing a problem.

The solution contains:

```hcl
resource "terraform_data" "learning" {
  input = "manual-to-automation"
}
```

---

## Verification workflow

Run the commands from the exercise directory:

```powershell
Set-Location .\chapters\01-from-manual-steps-to-declarative-infrastructure\exercise
```

Initialize the directory:

```powershell
terraform init
```

Validate the configuration:

```powershell
terraform validate
```

Check formatting:

```powershell
terraform fmt -check
```

Preview the initial change:

```powershell
terraform plan
```

Expected summary:

```text
Plan: 1 to add, 0 to change, 0 to destroy.
```

After reviewing the complete plan, apply it:

```powershell
terraform apply
```

Inspect state:

```powershell
terraform state list
terraform state show terraform_data.learning
```

Verify idempotence:

```powershell
terraform plan
```

Expected result:

```text
No changes. Your infrastructure matches the configuration.
```

Change the input to:

```hcl
input = "declarative-thinking"
```

Preview the update:

```powershell
terraform plan
```

Expected summary:

```text
Plan: 0 to add, 1 to change, 0 to destroy.
```

After reviewing the update, apply it:

```powershell
terraform apply
```

Verify convergence:

```powershell
terraform plan
```

Expected result:

```text
No changes. Your infrastructure matches the configuration.
```

---

## Cleanup

Preview destruction first:

```powershell
terraform plan -destroy
```

Expected summary:

```text
Plan: 0 to add, 0 to change, 1 to destroy.
```

After reviewing the destruction plan:

```powershell
terraform destroy
```

Verify that the current state contains no managed resource addresses:

```powershell
terraform state list
```

The command should return no resources.

Remember: because the resource block still exists in configuration, another regular plan will propose one create operation.

---

## Chapter completion criteria

This chapter is complete when you can:

* identify the resource type and local name;
* write the resource block with limited or no guidance;
* predict the first plan;
* explain why `id` is known after apply;
* explain what state records;
* predict an in-place update;
* explain why the second plan reports no changes;
* distinguish plan from apply;
* distinguish destroy from removing a state association;
* perform cleanup safely;
* verify that Terraform state no longer contains the resource.

---

## Key takeaway

Terraform does not merely execute a list of commands.

It continuously compares:

```text
Desired configuration ↔ Managed state ↔ Reported reality
```

From that comparison, Terraform proposes the actions required to reach the declared result.

The most important habit is:

> Predict the plan, inspect the plan, and only then decide whether to apply it.
