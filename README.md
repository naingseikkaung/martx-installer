# MartX POS Installer

Public build-only repository (`naingseikkaung/martx-installer`) for producing the Windows installer from the private app source (`naing-pyae-hlyan/martx-pos`).

GitHub Actions checkouts the private app, then stages and compiles using scripts under **`installer/`**.

App-mode shortcut launchers (`open-app.ps1`, `create-cashier-shortcut.ps1`) live in `installer/` and must stay synced with `martx-pos/packaging/windows/` whenever packaging shortcuts/smoke/Inno change.
