#!/usr/bin/env bash

#
# Create PDF documentation
# 2022-11-06 Ricky Maicle
#
# Example:
#   ./build.sh dev-guide
#   ./build.sh dev-g
#

declare -r SCRIPTNAME=${0##*/}
declare -r SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

declare -r DOC_BIN="mdtopdf.sh"
if ! command -v ${DOC_BIN} &> /dev/null
then
    echo_error "File not found: ${DOC_BIN}"
    exit 1
fi

# Engine: [pdflatex | xelatex | lualatex]
declare -r DEFAULT_PDF_ENGINE="pdflatex"
declare -r ALTERNATIVE_PDF_ENGINE="xelatex"

declare -a PDF_ENGINES=(
    "${DEFAULT_PDF_ENGINE}"
    "${ALTERNATIVE_PDF_ENGINE}"
)

declare -r PAPER_A4="a4"
declare -r PAPER_USLETTER="usletter"

declare -r DEFAULT_PAPER_SIZE="${PAPER_A4}"

declare -a PAPER_SIZES=(
    ${PAPER_A4}
    ${PAPER_USLETTER}
)

declare -r DEFAULT_TEMPLATE_DIR="/usr/local/share"
declare -r DEFAULT_TEMPLATE_FILE="template_doc.tex"

declare -r DEFAULT_MARKDOWN_CONTENT_FILE="markdownlist.txt"
declare -r DEFAULT_IMAGE_CONTENT_FILE="imagelist.txt"



declare DOC_TEST="test"
declare DOC_DEV_GUIDE="dev-guide"
declare DOC_CPP_GUIDE="cpp-guide"
declare DOC_GIT_GUIDE="git-guide"
declare DOC_MAIL_GUIDE="mail-guide"
declare DOC_ACCTG_GUIDE="acctg-guide"
declare DOC_COOP_GUIDE="coop-guide"
declare DOC_TOML="spec-toml"

declare -a DOCUMENTS=(
    ${DOC_TEST}
    ${DOC_DEV_GUIDE}
    ${DOC_CPP_GUIDE}
    ${DOC_GIT_GUIDE}
    ${DOC_MAIL_GUIDE}
    ${DOC_ACCTG_GUIDE}
    ${DOC_COOP_GUIDE}
    ${DOC_TOML}
)

declare -A DIR_DOCUMENTS=(
    [${DOC_TEST}]="${DOC_TEST}"
    [${DOC_DEV_GUIDE}]="${DOC_DEV_GUIDE}"
    [${DOC_CPP_GUIDE}]="${DOC_CPP_GUIDE}"
    [${DOC_GIT_GUIDE}]="${DOC_GIT_GUIDE}"
    [${DOC_MAIL_GUIDE}]="${DOC_MAIL_GUIDE}"
    [${DOC_ACCTG_GUIDE}]="${DOC_ACCTG_GUIDE}"
    [${DOC_COOP_GUIDE}]="${DOC_COOP_GUIDE}"
    [${DOC_TOML}]="${DOC_TOML}"
)

declare -A FILENAME_DOCUMENTS=(
    [${DOC_TEST}]="${DOC_TEST}"
    [${DOC_DEV_GUIDE}]="${DOC_DEV_GUIDE}"
    [${DOC_CPP_GUIDE}]="${DOC_CPP_GUIDE}"
    [${DOC_GIT_GUIDE}]="${DOC_GIT_GUIDE}"
    [${DOC_MAIL_GUIDE}]="${DOC_MAIL_GUIDE}"
    [${DOC_ACCTG_GUIDE}]="${DOC_ACCTG_GUIDE}"
    [${DOC_COOP_GUIDE}]="${DOC_COOP_GUIDE}"
    [${DOC_TOML}]="${DOC_TOML}"
)

declare -r OUTPUT_DIR="${SCRIPT_DIR}/../../build/doc"
if [ ! -d "${OUTPUT_DIR}" ]; then
    pushd ${SCRIPT_DIR}/../..
    mkdir build/doc
    popd
fi



source /usr/local/bin/dirstack.sh
source /usr/local/bin/echo.sh



#
# Display script usage
#
function show_usage() {
cat << EOF
Script for creating a document PDF file using LaTeX.

Reads contents of the markdown (${DEFAULT_MARKDOWN_CONTENT_FILE}) and image (${DEFAULT_IMAGE_CONTENT_FILE})
input files, processes them, and outputs the PDF file.

Usage:
  ${SCRIPTNAME} [option...] doc-id

Values for doc-id:
$(printf '  %s\n' ${DOCUMENTS[@]})

Options:
  -h, --help            print help and exit
      --debug           run script in debug mode
      --draft           generate draft version PDF document
      --engine          PDF engine to use; default is ${DEFAULT_PDF_ENGINE}
$(printf '                          %s\n' ${PDF_ENGINES[@]})
      --image file      image input file; default is ${DEFAULT_IMAGE_CONTENT_FILE}
      --latex           output TeX/LaTeX file and generate PDF
      --latex-only      output TeX/LaTeX file and exit
      --markdown file   mardown input file; default is ${DEFAULT_MARKDOWN_CONTENT_FILE}
      --no-image        do not generate TeX images
      --no-frontmatter  do not generate user-supplied frontmatter contents
      --no-backmatter   do not generate user-supplied backmatter contents
      --paper size      paper size; default is ${DEFAULT_PAPER_SIZE}
$(printf '                          %s\n' ${PAPER_SIZES[@]})
      --show-frame      show page margins
      --template        use template file; default is ${DEFAULT_TEMPLATE_FILE}
                        in ${DEFAULT_TEMPLATE_DIR}
      --use-latest      use latest installed Pandoc version

NOTE: Including source files using pp !source(...) is relative to the
      LaTeX/TeX template directory.
EOF
}



# if [[ $# -eq 0 ]] || [[ "${1}" = "--help" ]]; then
#     show_usage
#     exit
# fi

# declare v_doc_out_dir="${SCRIPT_DIR}/out"
# if [ ! -d "${v_doc_out_dir}" ]; then
#     pushd ${SCRIPT_DIR}
#     mkdir out
#     popd
# fi




declare arg_doc=""
declare arg_template="${DEFAULT_TEMPLATE_FILE}"
declare arg_markdown_file="${DEFAULT_MARKDOWN_CONTENT_FILE}"
declare arg_image_file="${DEFAULT_IMAGE_CONTENT_FILE}"
declare arg_pdf_engine="${DEFAULT_PDF_ENGINE}"
declare arg_paper_size="${PAPER_USLETTER}"

declare param_debug=""
declare param_draft=""
declare param_use_latest=""
declare param_no_backmatter=""
declare param_no_frontmatter=""
declare param_no_image=""
declare param_latex=""
declare param_latex_only=""
declare param_show_frame=""



# read the options
declare OPTIONS_SHORT="h"
declare OPTIONS_LONG=""
OPTIONS_LONG+=",debug"
OPTIONS_LONG+=",draft"
OPTIONS_LONG+=",engine:"
OPTIONS_LONG+=",help"
OPTIONS_LONG+=",image:"
OPTIONS_LONG+=",latex"
OPTIONS_LONG+=",latex-only"
OPTIONS_LONG+=",markdown:"
OPTIONS_LONG+=",no-image"
OPTIONS_LONG+=",no-frontmatter"
OPTIONS_LONG+=",no-backmatter"
OPTIONS_LONG+=",paper:"
OPTIONS_LONG+=",show-frame"
OPTIONS_LONG+=",template:"
OPTIONS_LONG+=",use-latest"
OPTIONS_TEMP=$(getopt               \
    --options ${OPTIONS_SHORT}      \
    --longoptions ${OPTIONS_LONG}   \
    --name "${SCRIPTNAME}" -- "$@")
# Append unrecognized arguments after --
eval set -- "${OPTIONS_TEMP}"



while true; do
    case "${1}" in
        --debug)            param_debug="--debug" ; shift ;;
        --draft)            param_draft="--draft" ; shift ;;
        --engine)           arg_pdf_engine="${2,,}"
                            if [[ ! "${PDF_ENGINES[@]}" =~ "${arg_pdf_engine}" ]]; then
                                echo_error "Unrecognized PDF engine: ${arg_pdf_engine}\nAborting."
                                echo "Use one of: ${PDF_ENGINES[@]}"
                                exit 1
                            fi
                            shift 2
                            ;;
        -h|--help)          show_usage ; exit ;;
        --image)            arg_image_file="${2}"
                            shift 2
                            if [ ! -f "${arg_image_file}" ]; then
                                echo_error "Image input file not found: ${arg_image_file}\nAborting."
                                exit 1
                            fi
                            ;;
        --latex)            param_latex="--latex" ; shift ;;
        --latex-only)       param_latex_only="--latex-only" ; shift ;;
        --markdown)         arg_markdown_file="${2}"
                            shift 2
                            if [ ! -f "${arg_markdown_file}" ]; then
                                echo_error "Markdown input file not found: ${arg_markdown_file}\nAborting."
                                exit 1
                            fi
                            ;;
        --no-image)         param_no_image="--no-image" ; shift ;;
        --no-frontmatter)   param_no_frontmatter="--no-frontmatter" ; shift ;;
        --no-backmatter)    param_no_backmatter="--no-backmatter" ; shift ;;
        --paper)            arg_paper_size="${2,,}"
                            shift 2
                            if [[ ! "${PAPER_SIZES[@]}" =~ "${arg_paper_size}" ]]; then
                                echo_error "Unrecognized paper size: ${arg_paper_size}\nAborting."
                                echo "Use one of: ${PAPER_SIZES[@]}"
                                exit 1
                            fi
                            ;;
        --show-frame)       param_show_frame="--show-frame" ; shift ;;
        --template)         arg_template="${2}" ; shift 2 ;;
        --use-latest)       param_use_latest="--use-latest" ; shift ;;
        --)                 shift ; break ;;
        *)                  break ;;
    esac
done

if [[ $# -eq 0 ]]; then
    echo_error "Missing document ID argument."
    echo "Use one of: ${DOCUMENTS[@]}"
    echo_error "Aborting."
    exit 1
fi

arg_doc="${1}"
shift
if [[ ! "${DOCUMENTS[@]}" =~ "${arg_doc}" ]]; then
    echo_error "Unrecognized document ID: ${arg_doc}"
    echo "Use one of: ${DOCUMENTS[@]}"
    echo_error "Aborting."
    exit 1
fi
for doc in "${DOCUMENTS[@]}"; do
    if [[ "${doc}" =~ "${arg_doc}" ]]; then
        # The passed doc-id may be a partial string
        # so, we use the complete id here.
        arg_doc=${doc}
        break
    fi
done

declare v_doc_dir=${DIR_DOCUMENTS[${arg_doc}]}
declare v_doc_out_file=${FILENAME_DOCUMENTS[${arg_doc}]}

${DOC_BIN}                                              \
    ${param_debug}                                      \
    --paper ${arg_paper_size}                           \
    ${param_draft}                                      \
    ${param_use_latest}                                 \
    ${param_show_frame}                                 \
    ${param_no_image}                                   \
    ${param_no_frontmatter}                             \
    ${param_no_backmatter}                              \
    --markdown "${v_doc_dir}/${arg_markdown_file}"      \
    --image "${v_doc_dir}/${arg_image_file}"            \
    --template "${arg_template}"                        \
    ${param_latex}                                      \
    ${param_latex_only}                                 \
    --engine "${arg_pdf_engine}"                        \
    --od ${OUTPUT_DIR}                                  \
    --of ${v_doc_out_file}
