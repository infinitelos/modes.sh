#!/bin/bash

MODEDIR="${HOME}/.modes"
GLOBAL_ALIAS="${HOME}/.aliases"
CURRENT_MODE=""

# Leave empty to load mode after edit, any value to disable autoload
NO_AUTO_LOAD=""

EDITOR="${EDITOR:-vi}"

# Ensure MODEDIR exists
mkdir -p "${MODEDIR}"

function usage {
  cat << EOF
On-demand source script loader
  Usage  :  mode [modename] [action] [action argument]
  List   :  mode
  Load   :  mode <modename>
  Show   :  mode <modename> show
  Edit   :  mode <modename> edit
  Import :  mode <modename> import <othermode>
  Help   :  mode help
EOF
}

function load_mode {
  local mode="$1"
  if [[ -f "${MODEDIR}/${mode}" ]]; then
    unalias -a
    [[ -f "${GLOBAL_ALIAS}" ]] && source "${GLOBAL_ALIAS}"
    source "${MODEDIR}/${mode}"
    echo "Loaded ${mode}"
    CURRENT_MODE="${mode}"
  else
    echo "Error: Mode '${mode}' does not exist"
  fi
}

function edit_mode {
  local mode="$1"
  "${EDITOR}" "${MODEDIR}/${mode}"
}

function list_modes {
  echo "Available Modes:"
  for mode in "${MODEDIR}"/*; do
    mode=$(basename "${mode}")
    if [[ "${mode}" == "${CURRENT_MODE}" ]]; then
      echo " * ${mode} (current)"
    else
      echo "   ${mode}"
    fi
  done
}

function show_mode {
  local mode="$1"
  if [[ -f "${MODEDIR}/${mode}" ]]; then
    cat "${MODEDIR}/${mode}"
  else
    echo "Error: Mode '${mode}' does not exist"
  fi
}

function import_mode {
  local mode="$1"
  local other_mode="$2"
  if [[ -f "${MODEDIR}/${other_mode}" ]]; then
    cat "${MODEDIR}/${other_mode}" >> "${MODEDIR}/${mode}"
    echo "Imported ${other_mode} into ${mode}"
  else
    echo "Error: Mode '${other_mode}' does not exist"
  fi
}

function mode {
  local mode="$1"
  local action="$2"
  local action_arg="$3"

  if [[ -z "${mode}" ]]; then
    list_modes
  elif [[ "${mode}" == "help" ]]; then
    usage
  elif [[ -z "${action}" ]]; then
    load_mode "${mode}"
  elif [[ "${action}" == "edit" ]]; then
    edit_mode "${mode}"
    [[ -z "${NO_AUTO_LOAD}" ]] && load_mode "${mode}"
  elif [[ "${action}" == "show" ]]; then
    show_mode "${mode}"
  elif [[ "${action}" == "import" && -n "${action_arg}" ]]; then
    import_mode "${mode}" "${action_arg}"
  else
    usage
  fi
}
