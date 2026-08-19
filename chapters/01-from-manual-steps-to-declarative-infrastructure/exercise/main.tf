# Chapter 01 Exercise: Declarative Infrastructure
#
# Goal:
# Practice the relationship between configuration, plan, apply, and state
# without creating external infrastructure or incurring cloud costs.
#
# TODO 1:
# Declare a terraform_data resource with the local name "learning".
#
# TODO 2:
# Set its input value to "manual-to-automation".
#
# Verification workflow:
# 1. Initialize the working directory.
# 2. Validate the configuration.
# 3. Predict the execution plan before running it.
# 4. Review all create, change, and destroy actions.
# 5. Apply only after reviewing the plan.
# 6. Inspect the managed resource through Terraform state commands.
# 7. Change the input value to "declarative-thinking".
# 8. Predict and review the in-place update.
# 9. Apply the update and verify that a new plan reports no changes.
# 10. Review a destroy plan before performing cleanup.
#
# Safety:
# Never commit Terraform state or saved plan files.
#
# Write the Terraform configuration below this line.