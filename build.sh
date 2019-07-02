#!/usr/bin/env bash

#
# Display script usage
#
function show_usage() {
    echo "Build script for converting markdown files to PDF using LaTeX."
    echo "Usage:"
    echo "  $(basename $0) [option ...]"
    echo "Options:"
    echo "  -h          print help and exit"
    echo "  -d          debug mode"
    echo "  -i [dir]    input directory; default is 'source' in the"
    echo "                current directory"
    echo "  -o [prefix] output filename prefix; default is 'output'"
    echo "                output filename is '<prefix>-[a4|us].pdf"
    echo "  -s [a4|us]  default is 'us'"
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

debug_mode=0

arg_input_dir="source"
arg_prefix=""

input_file="source.txt"


if [ "$1" = "--help" ]; then
    show_usage
    exit
fi

while getopts :hdi:o:s: OPTION; do
    case $OPTION in
        h)      show_usage
                exit
                ;;
        d)      debug_mode=1
                ;;
        i)      arg_input_dir="${OPTARG}"
                ;;
        o)      arg_prefix="${OPTARG}"
                ;;
        s)      arg_size="${OPTARG}"
                ;;
        \:)     printf "argument missing from -%s option\n" ${OPTARG}
                show_usage
                exit 2
                ;;
        \?)     show_usage
                exit 2
                ;;
    #esac >&2
    esac
done
shift $(($OPTIND - 1))

declare -r SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
declare -r CURRENT_DIR=$(pwd)
pushd ${arg_input_dir}
declare -r INPUT_DIR=$(pwd)
popd
output_file_prefix=$(basename ${INPUT_DIR})
if [ ! -z "${arg_prefix}" ]; then
    output_file_prefix="${arg_prefix}"
fi

if [ ${debug_mode} == 1 ]; then
    echo "Current Dir: ${CURRENT_DIR}"
    echo "Script Dir:  ${SCRIPT_DIR}"
    echo "Input Dir:   ${INPUT_DIR}"
fi

if [ -z "${arg_size}" ]; then
    arg_size="all"
fi

# The graphic file cc_by_nc_sa_40.eps is used by latex template file
# and is placed in under the latex template base directory. Pandoc only
# looks for latex template image files on Pandoc's "working directory".
files=(
    "${SCRIPT_DIR}/latex-templates/cc_by_nc_sa_40.eps"
    "${SCRIPT_DIR}/latex-templates/doc/template_doc_us.tex"
    "${SCRIPT_DIR}/latex-templates/doc/template_doc_a4.tex"
    "${SCRIPT_DIR}/latex-templates/book/template_book_us.tex"
    "${SCRIPT_DIR}/latex-templates/book/template_book_a4.tex"
    "${INPUT_DIR}/${input_file}"
)

echo "Converting markdown files to PDF file."

echo "Checking required files..."
for file in "${files[@]}"; do
    if [ ! -e "${file}" ]; then
        echo "  Missing file: ${file}"
        exit 1
    else
        if [ ${debug_mode} == 1 ]; then
            echo "  Found: ${file}"
        fi
    fi
done
echo "Done"

readarray -t source_files <"${INPUT_DIR}/${input_file}"

echo "Checking source markdown files:"
for file in "${source_files[@]}"; do
    if [ ! -e "${INPUT_DIR}/${file}" ]; then
        echo "  Missing file: ${INPUT_DIR}/${file}"
        exit 1
    else
        echo "  Found: ${file}"
    fi
done
echo "Done"

if [ $# -gt 0 ]; then
    printf "Unknown arguments: %s\n" "$*"
    echo   "Aborting."
    exit 1
fi

echo "Preprocessing..."
pushd ${INPUT_DIR}
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

declare -a  paper_sizes=()

if [ "${arg_size}" == "a4" ]; then
    paper_sizes+=("a4")
elif [ "${arg_size}" == "us" ]; then
    paper_sizes+=("us")
elif [ "${arg_size}" == "all" ]; then
    paper_sizes+=("a4")
    paper_sizes+=("us")
fi

# Because Pandoc only looks for latex template image files on its
# "working directory", we must go into the latex templates base directory
pushd ${SCRIPT_DIR}/latex-templates

for element in "${paper_sizes[@]}"; do
    template_file=""
    if [ "${element}" == "us" ]; then
        template_file="${SCRIPT_DIR}/latex-templates/doc/template_doc_us.tex"
    elif [ "${element}" == "a4" ]; then
        template_file="${SCRIPT_DIR}/latex-templates/doc/template_doc_a4.tex"
    fi

    output_file="${output_file_prefix}-${element}.pdf"

    if [ ${debug_mode} == 1 ]; then
        echo "Template: ${template_file}"
        echo "Output:   ${output_file}"
    fi

    echo "Converting to PDF (${element})..."
    pandoc                                  \
            -s ${pp_files[@]}               \
            --resource-path=.:${INPUT_DIR}  \
            --template="${template_file}"   \
            -f markdown+raw_tex             \
            -f markdown+fenced_code_blocks  \
            -f markdown+footnotes           \
            -f markdown+link_attributes     \
            -f markdown+implicit_figures    \
            -t latex                        \
            -o ${output_file}               \
            `#--pdf-engine=pdflatex`        \
            --pdf-engine=xelatex            \
            --toc                           \
            --top-level-division=chapter    \
            --listing

    if [ -e "${output_file}" ]; then
        echo "Output: ${output_file}"
        mv ${output_file} ${CURRENT_DIR}/${output_file}
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

done

popd

if [ ${debug_mode} == 0 ]; then
    echo "Cleaning up."
    for file in "${pp_files[@]}"; do
        rm -f "${file}"
    done
fi

echo "Done."
