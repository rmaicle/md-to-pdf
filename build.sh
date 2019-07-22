#!/usr/bin/env bash

#
# Display script usage
#
function show_usage() {
    echo "Script for converting markdown files to PDF using LaTeX."
    echo "It reads the input file source.txt in some input directory"
    echo "reads the markdown files specified in the input file,"
    echo "pre-process and converts them to PDF a file using the"
    echo "specified TeX/LaTex template files."
    echo ""
    echo "Usage:"
    echo "  $(basename $0) [option ...]"
    echo "Options:"
    echo "  -h          print help and exit."
    echo "  -i [dir]    input directory; default is current directory;"
    echo "                if this script file is called from another"
    echo "                script file, then the directory of the calling"
    echo "                script is the current directory."
    echo "  -td [dir]   TeX/LaTeX template base directory; absolute path or"
    echo "                relative to the script directory; this is where"
    echo "                template images must be found."
    echo "  -tf [file]  template file; relative to the TeX/LaTeX template"
    echo "                base directory."
    echo "  -o          output Latex file."
    echo "  -od [dir]   output directory; default is current directory."
    echo "  -of [file]  output base filename; default is 'output'"
    echo "                default output filename is '<file>.pdf."
    echo "  -v          verbose messages."
}

# ==============================

# Silence pushd and popd commands

pushd () {
    command pushd "$@" > /dev/null
}

popd () {
    command popd "$@" > /dev/null
}

# ==============================

declare -r SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
declare -r CURRENT_DIR=$(pwd)

debug_mode=0
output_latex=0

if [[ "${1}" = "--help" ]] || [[ $# -eq 0 ]]; then
    show_usage
    exit
fi

if [[ $# -gt 0 ]] && [[ "${1}" = "-d" ]]; then
    shift
    debug_mode=1
fi

# Determine the full path of the specified input directory.
# If the input directory is not specified, then it defaults to
# the current working directory.

INPUT_FILE="source.txt"
INPUT_DIR="${CURRENT_DIR}"
if [[ $# -gt 0 ]] && [[ "${1}" == "-i" ]]; then
    arg_input_file="${2}"
    shift 2
    if [ -z "${arg_input_file}" ]; then
        echo "Error: Input file is not specified."
        exit 1
    else
        if [ -f "${arg_input_file}" ]; then
            INPUT_FILE="$(basename ${arg_input_file})"
            arg_input_dir="$(dirname ${arg_input_file})"
            pushd "${arg_input_dir}"
            INPUT_DIR=$(pwd)
            popd
        else
            echo "Error: Input file does not exist: ${arg_input_file}"
            echo "Current directory: $(pwd)"
            exit 1
        fi
    fi
fi

# Determine the full path of the specified template directory.

TEMPLATE_DIR="${SCRIPT_DIR}"
if [ $# -gt 0 ]; then
    if [[ "${1}" == "-td" ]]; then
        arg_template_dir="${2}"
        shift 2
        if [ -z "${arg_template_dir}" ]; then
            echo "Error: Template directory is not specified."
            exit 1
        else
            pushd "${SCRIPT_DIR}"
            if [ -d "${arg_template_dir}" ]; then
                pushd "${arg_template_dir}"
                TEMPLATE_DIR=$(pwd)
                popd
            else
                echo "Error: Template directory does not exist: ${arg_template_dir}"
                echo "Current directory: $(pwd)"
                popd
                exit 1
            fi
            popd
        fi
    fi
else
    echo "Error: Missing template directory argument."
    exit 1
fi

TEMPLATE_FILE=""
if [ $# -gt 0 ]; then
    if [[ "${1}" == "-tf" ]]; then
        arg_template_file="${2}"
        shift 2
        if [ -z "${arg_template_file}" ]; then
            echo "Error: Template file is not specified."
            exit 1
        else
            pushd "${TEMPLATE_DIR}"
            if [ -e "${arg_template_file}" ]; then
                TEMPLATE_FILE="${arg_template_file}"
            else
                echo "Error: Template file does not exist: ${arg_template_file}"
                exit 1
            fi
            popd
        fi
    fi
else
    echo "Error: Missing template file argument."
    exit 1
fi

if [[ $# -gt 0 ]] && [[ "${1}" == "-o" ]]; then
    shift
    output_latex=1
fi

# Determine the full path of the specified output directory.
# If the output directory is not specified, then it defaults to
# the current working directory.

OUTPUT_DIR="${CURRENT_DIR}"
if [[ $# -gt 0 ]] && [[ "${1}" == "-od" ]]; then
    arg_output_dir="${2}"
    shift 2
    if [ ! -z "${arg_output_dir}" ]; then
        if [ -d "${arg_output_dir}" ]; then
            pushd "${arg_output_dir}"
            OUTPUT_DIR=$(pwd)
            popd
        else
            echo "Error: Output directory does not exist: ${arg_output_dir}"
            echo "Current directory: $(pwd)"
            exit 1
        fi
    fi
fi

OUTPUT_FILENAME="output.pdf"
OUTPUT_LATEX="output.tex"
if [[ $# -gt 0 ]] && [[ "${1}" == "-of" ]]; then
    arg_output_file="${2}"
    shift 2
    if [ -z "${arg_output_file}" ]; then
        echo "Error: Output file is not specified."
        exit 1
    else
        pushd "${OUTPUT_DIR}"
        OUTPUT_FILENAME="${arg_output_file}.pdf"
        OUTPUT_LATEX="${arg_output_file}.tex"
        if [ -e "${arg_output_file}" ]; then
            echo "Notice: Output file exists: ${arg_output_file}"
            echo "        Existing file will be overwritten."
        fi
        popd
    fi
fi

if [ ${debug_mode} == 1 ]; then
    echo "Script Dir:    ${SCRIPT_DIR}"
    echo "Current Dir:   ${CURRENT_DIR}"
    echo "Input Dir:     ${INPUT_DIR}"
    echo "Input File:    ${INPUT_FILE}"
    echo "Output Dir:    ${OUTPUT_DIR}"
    echo "Output File:   ${OUTPUT_FILENAME}"
    echo "Template Dir:  ${TEMPLATE_DIR}"
    echo "Template File: ${TEMPLATE_FILE}"
fi

# Read the input file contents

source_files=()
temp_source_files=()
readarray -t temp_source_files <"${INPUT_DIR}/${INPUT_FILE}"
for file in "${temp_source_files[@]}"; do
    if [ ! -z "${file}" ]; then
        source_files+=("${file}")
    fi
done

echo "Checking existence of markdown files:"
for file in "${source_files[@]}"; do
    if [ ! -e "${INPUT_DIR}/${file}" ]; then
        echo "  Missing markdown file: ${INPUT_DIR}/${file}"
        exit 1
    else
        echo "  Found: ${file}"
    fi
done
echo "Done"

# Pre-process markdown files

echo "Preprocessing markdown files..."
pushd "${INPUT_DIR}"
if [ ! -d "images" ]; then
    mkdir "images"
fi
pp_files=()
for file in "${source_files[@]}"; do
    ppfile="${file%.*}_pp.md"
    pp_files+=("${INPUT_DIR}/${ppfile}")
    if [ ${debug_mode} == 1 ]; then
        echo "  ${INPUT_DIR}/${ppfile}"
    fi
    pp ${file} > "${ppfile}"
done
popd
echo "Done"

# Because Pandoc only looks for latex template image files on its
# "working directory", we must go into the latex templates directory
pushd "${TEMPLATE_DIR}"

if [ ${output_latex} -eq 1 ]; then
    echo "Creating Tex/LaTeX file ${OUTPUT_LATEX}..."
    rm -f ${OUTPUT_LATEX}

    pandoc                              \
        ${pp_files[@]}                  \
        --standalone                    \
        --resource-path=.:${INPUT_DIR}  \
        --template="${TEMPLATE_FILE}"   \
        -f markdown+raw_tex             \
        -f markdown+escaped_line_breaks \
        -f markdown+fenced_code_blocks  \
        -f markdown+fancy_lists         \
        -f markdown+footnotes           \
        -f markdown+link_attributes     \
        -f markdown+implicit_figures    \
        -t latex                        \
        --toc                           \
        --top-level-division=chapter    \
        --listings                      \
        > "${OUTPUT_LATEX}"

    if [ -e "${OUTPUT_LATEX}" ]; then
        echo "Latex: ${OUTPUT_DIR}/${OUTPUT_LATEX}"
        if [[ ! "$(pwd)" == "${OUTPUT_DIR}" ]]; then
            mv ${OUTPUT_LATEX} ${OUTPUT_DIR}/${OUTPUT_LATEX}
        fi
    fi
fi

echo "Converting markdown files to ${OUTPUT_FILENAME}..."
pandoc                              \
    ${pp_files[@]}                  \
    --standalone                    \
    --resource-path=.:${INPUT_DIR}  \
    --template="${TEMPLATE_FILE}"   \
    -f markdown+raw_tex             \
    -f markdown+escaped_line_breaks \
    -f markdown+fenced_code_blocks  \
    -f markdown+fancy_lists         \
    -f markdown+footnotes           \
    -f markdown+link_attributes     \
    -f markdown+implicit_figures    \
    -t latex                        \
    -o ${OUTPUT_FILENAME}           \
    `#--pdf-engine=pdflatex`        \
    --pdf-engine=xelatex            \
    --toc                           \
    --top-level-division=chapter    \
    --listings

if [ -e "${OUTPUT_FILENAME}" ]; then
    echo "Output: ${OUTPUT_DIR}/${OUTPUT_FILENAME}"
    if [[ ! "$(pwd)" == "${OUTPUT_DIR}" ]]; then
        mv ${OUTPUT_FILENAME} ${OUTPUT_DIR}/${OUTPUT_FILENAME}
    fi
else
    echo "No output."
fi

# Other arguments to pandoc:
#
#   --pdf-engine=[pdflatex | xelatex]
#   --verbose
#     Give verbose debugging output. Currently this only has an effect
#     with PDF output.
#   --log=FILE
#     Write log messages in machine-readable JSON format to
#     FILE. All messages above DEBUG level will be written,
#     regardless of verbosity settings (--verbose, --quiet).

# Use --pdf-engine=xelatex when markdown file contains Ñ character.

popd

if [ ${debug_mode} == 0 ]; then
    echo "Cleaning up."
    for file in "${pp_files[@]}"; do
        rm -f "${file}"
    done
fi

echo "Done."
