#!/usr/bin/env zsh

# Usage:
#   - Default; runs directly in current directory:
#     ./mdtopdf.zsh --latex-only
#   - Pass document name:
#     ./mdtopdf.zsh my_novel --engine xelatex
#   - Pass relative/absolute path:
#     ./mdtopdf.zsh ~/Documents/book_project --draft


# Strict Environment Setup
set -e
set -u
set -o pipefail -o noclobber

declare -r HOME_DIR="$(eval echo ~${USER})"
declare -r SCRIPT_NAME=${0:t}
declare -r SCRIPT_DIR="${0:A:h}"

declare CURRENT_DIR=$(pwd)

# Securely source environment utilities if they exist
for utils in dirstack echo debug; do
    if [[ -f "/usr/local/bin/${utils}.sh" ]]; then
        source "/usr/local/bin/${utils}.sh"
    else
        echo "Missing /usr/local/bin/${utils}.sh"
    fi
done

# Initialize Script Global Variable Options
declare -r PROGRAM_DEFAULT="pandoc"
declare -r PROGRAM_ALT="pandoc-latest"
declare PROGRAM="${PROGRAM_DEFAULT}"
declare -r PANDA_LUA="/usr/local/bin/panda.lua"
declare -r HEADER="Convert markdown files to PDF using Pandoc.\nCopyright (C) 2019-2022 Ricardo Maicle"

# Source module scripts from the same directory as the main script
source "${SCRIPT_DIR}/mdtopdf_parse_args.zsh"
source "${SCRIPT_DIR}/mdtopdf_render_pipeline.zsh"

function main() {
    if ! command -v ${PROGRAM} &> /dev/null ; then
        echo_error "Pandoc not found.\nDownload program from pandoc.org"
        exit 1
    fi

    # Initialize a baseline name fallback string
    declare folder_name="output"

    # --- AUTOMATED DOCUMENT NAMING LOGIC ---
    if [[ $# -gt 0 && "${1}" != --* ]]; then
        declare target_input="${1}"
        shift

        if [[ -d "${target_input}" ]]; then
            cd "${target_input}"
            CURRENT_DIR=$(pwd)
            # Get the clean trailing folder name (e.g. "dev-guide")
            folder_name="${CURRENT_DIR:t}"
            echo "Auto-discovered path. Switching to: ${CURRENT_DIR}"
        elif [[ -d "./${target_input}" ]]; then
            cd "./${target_input}"
            CURRENT_DIR=$(pwd)
            # Get the clean folder name here too
            folder_name="${CURRENT_DIR:t}"
            echo "Found directory matching document: ${CURRENT_DIR}"
        else
            echo_warn "Target directory '${target_input}' not found. Processing in local workspace."
        fi
    else
        # If no folder parameter was supplied, use the current active directory name
        folder_name="${CURRENT_DIR:t}"
    fi

    # Bind the automatically discovered folder name as our default output name
    arg_output_file="${folder_name}"
    # ----------------------------------------

    # Parse remaining standard inputs from CLI flags (e.g., --engine, --draft)
    parse_cli_arguments "$@"

    # Run structural validations & checks
    verify_pandoc_version
    validate_input_and_template_paths

    # Process files
    preprocess_tex_images
    preprocess_markdown_contents

    # Compile
    run_pandoc_compilation
    cleanup_temp_files
}

main "$@"
