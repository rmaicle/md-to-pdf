#!/usr/bin/env bash

#
# Display script usage
#
function show_usage() {
    echo "Build script for converting markdown to PDF using LaTeX."
    echo "Usage:"
    echo "  $(basename $0) [option ...]"
    echo "Options:"
    echo "  -h             print help and exit"
    echo "  -d             debug mode"
    echo "  -s [a4 | us]   default is 'us'"
}

# ==============================

debug_mode=0

if [ "$1" = "--help" ]; then
    show_usage
    exit
fi

while getopts :hds: OPTION; do
    case $OPTION in
        h)      show_usage
                exit
                ;;
        d)      debug_mode=1
                ;;
        s)      arg_size="$OPTARG"
                ;;
        \:)     printf "argument missing from -%s option\n" $OPTARG
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

echo "Converting markdown files to PDF file."

files=(
    "cc_by_nc_sa_40.eps"
    "latex-templates/doc/template_doc_us.tex"
    "latex-templates/doc/template_doc_a4.tex"
    "latex-templates/book/template_book_us.tex"
    "latex-templates/book/template_book_a4.tex"
)

doc_files=(
    "metadata.md"
    "source.md"
)

echo "Checking required files..."
for file in "${files[@]}"; do
    if [ ! -e "${file}" ]; then
        echo "  Missing file: ${file}"
        exit 1
    else
        echo "  Found: ${file}"
    fi
done

echo "Checking source markdown files..."
for file in "${doc_files[@]}"; do
    if [ ! -e "${file}" ]; then
        echo "  Missing file: ${file}"
        exit 1
    else
        echo "  Found: ${file}"
    fi
done

if [ -z "${arg_size}" ]; then
    arg_size="us"
fi

template_file=""
if [ "${arg_size}" == "us" ]; then
    template_file="template_doc_us.tex"
elif [ "${arg_size}" == "a4" ]; then
    template_file="template_doc_a4.tex"
else
    echo "Unknown paper size: '${arg_size}'."
    exit 1
fi

output_file+="operations-${arg_size}.pdf"

if [ $debug_mode == 1 ]; then
    echo "Template: $template_file"
    echo "Output:   $output_file"
fi

if [ $# -gt 0 ]; then
    printf "Unknown arguments: %s\n" "$*"
    echo   "Aborting."
    exit 1
fi

echo "Preprocessing..."
pp_files=()
for file in "${doc_files[@]}"; do
    ppfile="${file%.*}_pp.md"
    pp_files+=("${ppfile}")
    echo "  ${ppfile}"
    pp ${file} > "${ppfile}"
done

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

echo "Converting to PDF..."
pandoc                                  \
        -s metadata_pp.md               \
           source_pp.md                 \
        --template=${template_file}     \
        -f markdown+raw_tex+fenced_code_blocks+footnotes+link_attributes+implicit_figures   \
        -t latex                        \
        -o ${output_file}               \
        `#--pdf-engine=pdflatex`        \
        --pdf-engine=xelatex            \
        --toc                           \
        --top-level-division=chapter    \
        --listing

if [ $debug_mode == 0 ]; then
    echo "Cleaning up."
    for file in "${pp_files[@]}"; do
        rm -f "${file}"
    done
fi

echo "Output: ${output_file}"
echo "Done."
