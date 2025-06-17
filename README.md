# OpenHands Setup.sh Issue Reproduction

This repository reproduces the issue described in issue
[#9197](https://github.com/All-Hands-AI/OpenHands/issues/9197) where a complex
`.openhands/setup.sh` script causes OpenHands agents in Cloud to become
non-functional due to hanging processes. While the agent does start up and come
online, it becomes unable to execute terminal commands properly, complaining
about hanging processes that cannot be interrupted.

## 1. Problem Description

When using OpenHands Cloud with this repository's `.openhands/setup.sh` script,
the agent becomes non-functional due to hanging processes:

### 1.1. Primary Issue: Hanging Processes Block Commands

- Agent starts up and comes online successfully
- When attempting to run terminal commands, the agent reports hanging processes
- The agent cannot interrupt or kill the hanging processes
- All subsequent terminal commands fail due to the hanging process issue

### 1.2. Secondary Issue: No Debugging Visibility

- No access to stdout/stderr from the setup script during initialization
- No visibility into which processes are hanging or why they cannot be killed
- Impossible to debug what specifically is causing the hanging process issue

## 2. Expected Behavior

According to the [OpenHands
documentation](https://docs.all-hands.dev/usage/prompting/repository), the setup
script should:

- Run automatically during agent initialization
- Complete successfully without leaving hanging processes
- Install dependencies, set environment variables, and perform setup tasks
- Allow normal terminal command execution after completion

## 3. Actual Behavior

In OpenHands Cloud with this repository:

- Agent starts up and comes online successfully
- When attempting to run terminal commands, agent reports hanging processes
- Agent tries various interrupt methods (Ctrl+C, Ctrl+Z, Ctrl+D) without success
- All terminal command execution fails due to the hanging process issue

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
3. Wait for agent initialization (agent will come online successfully)
4. Attempt to run any terminal command (e.g., `llmzy --version`)
5. Observe that the agent reports hanging processes and cannot execute commands
6. Note that interrupt attempts (Ctrl+C, Ctrl+Z, etc.) fail to resolve the issue

[View Screenshot: Hanging Process Failure Mode](media/failure-mode.png)

The screenshot shows the typical failure pattern where the agent tries multiple
interrupt approaches but cannot resolve the hanging process issue.

### 5.2. Suspected Causes

The setup script performs several complex operations that may leave hanging
processes:

- Global npm package installation (`@llmzy/cli`) may not complete cleanly
- System dependency installation (requires sudo on Linux) may hang
- .npmrc configuration and npm authentication processes may remain active
- Multiple build processes (`npm ci`, `npm run build`) may leave background
  tasks
- Background processes from dependency installations may not terminate properly

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

Run OpenHands locally where hanging processes from setup scripts don't prevent
terminal command execution and process output is visible for debugging.

## 7. Related Issues

- [GitHub Issue #9197](https://github.com/All-Hands-AI/OpenHands/issues/9197):
  Complex setup.sh scripts cause hanging processes that prevent terminal command
  execution in OpenHands Cloud (this repository reproduces this issue)
- [GitHub Issue #7797](https://github.com/All-Hands-AI/OpenHands/issues/7797):
  Needs clarification - give more visibility into whether setup.sh was
  successful (related visibility issue)
- [OpenHands
  Documentation](https://docs.all-hands.dev/usage/prompting/repository):
  Repository Customization - Setup Script
