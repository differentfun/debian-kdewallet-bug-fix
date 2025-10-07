#!/usr/bin/env bash
set -euo pipefail

log() {
  printf '[kwallet-fix] %s\n' "$*"
}

confirm() {
  local prompt=${1:-"Proceed?"}
  local response
  read -r -p "$prompt [y/N] " response
  case "${response,,}" in
    y|yes) return 0 ;;
    *) return 1 ;;
  esac
}

require_command() {
  local cmd=$1
  if ! command -v "$cmd" >/dev/null 2>&1; then
    log "Error: required command '$cmd' not found in PATH."
    exit 1
  fi
}

main() {
  if [[ "${EUID}" -eq 0 ]]; then
    log "Error: run this script as a regular user, not root."
    exit 1
  fi

  require_command gpg

  local kwallet_data_dir="${HOME}/.local/share/kwalletd"
  local kwallet_config_file="${HOME}/.config/kwalletrc"
  local timestamp
  timestamp=$(date +'%Y%m%d%H%M%S')

  log "This will archive existing KWallet data and config for a fresh setup."
  if ! confirm "Do you want to continue"; then
    log "Aborted by user."
    exit 0
  fi

  if [[ -e "${kwallet_data_dir}" ]]; then
    local backup_dir="${kwallet_data_dir}.bak-${timestamp}"
    log "Backing up '${kwallet_data_dir}' to '${backup_dir}'."
    mv "${kwallet_data_dir}" "${backup_dir}"
  else
    log "No kwallet data directory found at '${kwallet_data_dir}', skipping."
  fi

  if [[ -e "${kwallet_config_file}" ]]; then
    local backup_config="${kwallet_config_file}.bak-${timestamp}"
    log "Backing up '${kwallet_config_file}' to '${backup_config}'."
    mv "${kwallet_config_file}" "${backup_config}"
  else
    log "No kwallet config file found at '${kwallet_config_file}', skipping."
  fi

  log "KWallet data reset complete."
  log "Next step is to create a fresh GPG key for KWallet."
  if confirm "Run 'gpg --full-generate-key' now"; then
    log "Launching 'gpg --full-generate-key'. Follow the prompts to create the key."
    gpg --full-generate-key
    log "GPG key creation completed."
  else
    log "Skipping GPG key generation. Remember to run 'gpg --full-generate-key' manually."
  fi

  log "All done. Reopen Chrome (or the affected app) to trigger the new KWallet setup."
}

main "$@"
