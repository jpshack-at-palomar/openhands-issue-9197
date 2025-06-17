# OpenHands Setup.sh Issue Reproduction

This repository reproduces the issue described in issue
[#9197](https://github.com/All-Hands-AI/OpenHands/issues/9197) where a complex
`.openhands/setup.sh` script prevents OpenHands agents from fully starting up in
OpenHands Cloud. When attempting to start an agent from the UI, the agent never
comes online and remains in a non-functional state.

## 1. Problem Description

When using OpenHands Cloud with this repository's `.openhands/setup.sh` script,
the agent initialization process fails completely:

### 1.1. Primary Issue: Agent Never Starts

- Agent never comes online after initiating from the OpenHands Cloud UI
- The startup process appears to hang or fail during setup script execution
- No agent interface becomes available for interaction
- The agent remains in a non-functional state indefinitely

### 1.2. Secondary Issue: No Debugging Visibility

- No access to stdout/stderr from the setup script during startup
- No indication whether the script succeeded, failed, or where it got stuck
- Impossible to debug what specifically is preventing agent startup

## 2. Expected Behavior

According to the [OpenHands
documentation](https://docs.all-hands.dev/usage/prompting/repository), the setup
script should:

- Run automatically during agent initialization
- Complete successfully, allowing the agent to come online
- Install dependencies, set environment variables, and perform setup tasks
- Allow normal agent interaction after completion

## 3. Actual Behavior

In OpenHands Cloud with this repository:

- Agent initialization process never completes
- Agent never becomes available for interaction
- UI shows agent in a perpetual loading/starting state
- No error messages or feedback provided about the failure

## 4. Reproduction Setup

This repository contains a comprehensive `.openhands/setup.sh` script that:

### 4.1. Environment Setup

- Validates Node.js 20.x installation
- Installs system dependencies (alsa-utils on Linux, sox on macOS)
- Configures npm authentication via .npmrc

### 4.2. Package Installation

- Installs `@llmzy/cli` globally
- Runs `npm ci` to install project dependencies
- Executes `npm run build` to build the project

### 4.3. Environment Configuration

- Sets `GITHUB_WORKFLOW=true` environment variable
- Provides detailed status messages throughout execution

## 5. Steps to Reproduce

### 5.1. Using OpenHands Cloud

1. Open this repository in OpenHands Cloud
2. Click to start a new agent session
3. Wait for agent initialization
4. Observe that the agent never comes online or becomes available for
   interaction
5. The UI remains in a loading/starting state indefinitely

### 5.2. Suspected Causes

The setup script performs several complex operations that may cause startup
failure:

- Global npm package installation (`@llmzy/cli`)
- System dependency installation (requires sudo on Linux)
- .npmrc configuration from environment secrets
- Multiple build processes (`npm ci`, `npm run build`)
- File permission changes and environment variable exports

## 6. Workarounds

### 6.1. Rename Setup Script and Manual Execution

Renamed `setup.sh` to `setup_environment.sh` and instructed the agent to run it
manually before performing other tasks:

- This approach often worked when initiating agents from the OpenHands Cloud UI
- However, it failed when agents were initiated from GitHub issues or pull
  requests
- The agent did not reliably follow manual setup instructions when started from
  GitHub integration

### 6.2. Instruction-Only Setup Script

Attempted to create a minimal `setup.sh` that would echo instructions to the
agent to run the renamed `setup_environment.sh` script:

- This approach also failed to work reliably
- The agent did not consistently follow the echoed instructions

### 6.3. Local Development

Run OpenHands locally where setup script failures don't prevent agent startup
and terminal output is visible for debugging.

## 7. Related Issues

- [GitHub Issue #9197](https://github.com/All-Hands-AI/OpenHands/issues/9197):
  Complex setup.sh scripts prevent OpenHands agents from starting in Cloud
  (this repository reproduces this issue)
- [GitHub Issue #7797](https://github.com/All-Hands-AI/OpenHands/issues/7797):
  Needs clarification - give more visibility into whether setup.sh was
  successful (related visibility issue)
- [OpenHands
  Documentation](https://docs.all-hands.dev/usage/prompting/repository):
  Repository Customization - Setup Script
