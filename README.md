# MartX POS Installer

Public build-only repository for producing the Windows installer from the private `martx-pos` source repository.

The workflow is manual-only and reads the private source repository through a fine-grained token stored as a GitHub Actions secret.

The build uses Node.js 24 LTS for both the runner build and bundled runtime. Node.js 26 is the Current release line; Node.js 24 is the supported LTS line recommended for production.

## One-time GitHub setup

Add these to the repository settings:

- Repository variable `SOURCE_REPOSITORY`: `naing-pyae-hlyan/martx-pos`
- Repository secret `SOURCE_REPO_TOKEN`: fine-grained PAT with Contents: Read-only access to only the private source repository

## Build

1. Open **Actions → Build MartX Windows Installer**.
2. Select **Run workflow**.
3. Enter a version such as `1.0.0`.
4. Download the `MartXPOS-Windows-Installer` artifact.

The workflow checks out private source only on the ephemeral runner, stages production dependencies, downloads NSSM, compiles Inno Setup, and uploads the installer. The source is not committed to this public repository.

## Security

- Do not add pull-request triggers or print the token.
- The installer contains the Node backend runtime files needed to run MartX; it is not source-code obfuscation.
- Never include license private keys, `.env` files, databases, or production secrets in the private source package.
