#!/usr/bin/env bash
debug=${1:-false}

# Load help lib if not already loaded.
if [ -z ${libloaded+x} ]; then
  source ./lib.sh
fi

echo -e "Installing dart"

echo -e "\tSetting up asdf"
asdf plugin-add dart https://github.com/patoconnor43/asdf-dart.git
# asdf where dart

# Set the containing directory for later use
versions_dir="${HOME}/.dotfiles/installer/versions/dart"

# Read given file line by line
function read_file {
  local file_path="${versions_dir}"
  while read -r line; do
    echo -e "${line}"
  done <"${file_path}"
}

# Install list of versions one by one
function install_versions {
  local versions_list=$(read_file)
  for version in ${versions_list}; do
    echo -e "\t\tInstalling ${version}"
    asdf install dart ${version} >/dev/null 2>&1
    local status=$?
    if [ ${status} -ne "0" ]; then
      echo "Last exit code was ${status} for 'asdf install dart ${version}'. Please run manually. Aborting."
      exit 1
    fi
  done
  # Set the latest version as global
  set_global ${version}
}

function set_global {
  local latest_version=${1}
  echo -e "\tSetting ${latest_version} as global"
  asdf global dart ${latest_version} >/dev/null 2>&1
}

echo -e "\tInstalling versions"
install_versions
