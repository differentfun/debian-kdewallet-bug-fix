# KWallet Reset Helper

This repository provides a small helper script that automates the manual steps required to resolve a recurring KWallet prompt on a fresh Debian 13 KDE (netinst) setup. In that environment, Google Chrome may repeatedly request KDE Wallet access because no RSA key exists yet. Manually deleting the wallet data directories and regenerating a GPG key fixes the problem, and the `fix-kdewallet.sh` script wraps those steps with backups and safety checks.

## What the script does
- Verifies you are running as a regular user and that `gpg` is available.
- Backs up `~/.local/share/kwalletd` and `~/.config/kwalletrc` to timestamped archives.
- Optionally launches `gpg --full-generate-key` so you can create a fresh RSA key for KWallet.

## Usage
```bash
chmod +x fix-kdewallet.sh
./fix-kdewallet.sh
```
Follow the prompts. After completing the GPG key generation, restart Chrome (or any other application that triggers KWallet) so the wallet can be re-created with the new credentials.

## Notes
- The script never deletes data outright; it moves existing KWallet files to backup folders so you can restore them if needed.
- If you skip the automatic GPG key generation step, remember to run `gpg --full-generate-key` manually before relaunching KDE applications.
