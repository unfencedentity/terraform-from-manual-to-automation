# Terraform: From Manual to Automation

A hands-on learning journey from Terraform fundamentals to production-grade Azure infrastructure automation.

## Purpose

This repository documents my practical Terraform learning journey.

The goal is not to memorize syntax or commands, but to understand how Terraform models, plans, creates, updates, and tracks infrastructure.

## Learning approach

Each concept progresses through the following stages:

1. Recognition
2. Understanding
3. Guided writing
4. Independent writing
5. Application
6. Diagnosis

The repository contains only concepts and exercises that have been understood, tested, and verified.

## Core workflow

Every configuration is analyzed through the following conceptual flow:

`Inputs → Configuration → Dependency Graph → Plan → Apply → State → Outputs`

## Technology focus

* Terraform
* Microsoft Azure
* Infrastructure as Code
* Cloud engineering
* Automation
* State management
* Reusable modules
* Testing and validation
* CI/CD
* Production troubleshooting

## Safety principles

* Always inspect the execution plan before applying changes.
* Identify create, update, replace, and destroy operations.
* Never assume that an apply operation is safe.
* Never commit credentials, secrets, state files, or plan files.
* Prefer small, controlled, and cost-conscious Azure resources.
* Verify both Terraform state and the real infrastructure.
* Clean up laboratory resources explicitly and carefully.

## Current progress

Repository initialization.
