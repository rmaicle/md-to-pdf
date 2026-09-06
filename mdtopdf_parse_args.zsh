# Core Configuration Matrix
declare -r DEFAULT_MARKDOWN_CONTENT_FILE="markdownlist.txt"
declare -r DEFAULT_IMAGE_CONTENT_FILE="imagelist.txt"

declare -r DEFAULT_PDF_ENGINE="pdflatex"
declare -r ALTERNATIVE_PDF_ENGINE="xelatex"
declare -a -r PDF_ENGINES=("${DEFAULT_PDF_ENGINE}" "${ALTERNATIVE_PDF_ENGINE}")

declare -r PAPER_A4="a4"
declare -r PAPER_A5="a5"
declare -r PAPER_B5="b5"
declare -r PAPER_LETTER="letter"
declare -r DEFAULT_PAPER_SIZE="${PAPER_A4}"
declare -a -r PAPER_SIZES=("${PAPER_A4}" "${PAPER_A5}" "${PAPER_B5}" "${PAPER_LETTER}")

declare -r DEFAULT_FONT_SIZE="10"
declare -a -r FONT_SIZES=("6" "7" "8" "9" "${DEFAULT_FONT_SIZE}" "11" "12")

declare -r DEFAULT_TEMPLATE_DIR="/usr/local/share"
declare -r DEFAULT_TEMPLATE_FILE="template_doc.tex"
declare -r DEFAULT_INPUT_DIR="${CURRENT_DIR}"
declare -r DEFAULT_OUTPUT_DIR="${CURRENT_DIR}"
declare -r DEFAULT_OUTPUT_FILE="output"
declare -r DEFAULT_OUTPUT_EXT="pdf"
declare -r DEFAULT_LATEX_EXT="tex"
declare -r DEFAULT_TOC_DEPTH="2"

declare -r DEFAULT_SKIP_FILE_MARKER_ONLY="x"
declare -r DEFAULT_SKIP_FILE_MARKER="${DEFAULT_SKIP_FILE_MARKER_ONLY} "
declare -r DEFAULT_PREPROCESSOR_FILE_MARKER="pp-"

# Dynamic Arguments State
declare arg_paper_size="${DEFAULT_PAPER_SIZE}"
declare arg_font_size="${DEFAULT_FONT_SIZE}"
declare arg_markdown_file="${DEFAULT_MARKDOWN_CONTENT_FILE}"
declare arg_image_file="${DEFAULT_IMAGE_CONTENT_FILE}"
declare arg_template_file="${DEFAULT_TEMPLATE_FILE}"
declare arg_pdf_engine="${DEFAULT_PDF_ENGINE}"
declare arg_toc_depth="${DEFAULT_TOC_DEPTH}"
declare arg_output_dir="${DEFAULT_OUTPUT_DIR}"
declare arg_output_file="${DEFAULT_OUTPUT_FILE}"

# Flags
declare flag_draft=3
declare flag_show_frame=0
declare flag_latex_output=0
declare flag_latex_only_output=0
declare flag_no_images=0
declare flag_no_backmatter=0
declare flag_no_frontmatter=0
declare flag_no_copyright=0
declare flag_no_toc=0
declare flag_no_lof=0
declare flag_no_lot=0
declare flag_debug_mode=0

function parse_cli_arguments() {
    while [[ $# -gt 0 ]]; do
        case "${1}" in
            --debug)            flag_debug_mode=1 ; shift ;;
            --draft)            flag_draft=1 ; shift ;;
            --ms)               flag_draft=2 ; shift ;;
            --engine)           arg_pdf_engine="${2:l}"
                                if [[ -z ${(M)PDF_ENGINES:#$arg_pdf_engine} ]]; then
                                    echo_error "Unrecognized PDF engine: ${arg_pdf_engine}\nAborting." ; exit 1
                                fi
                                shift 2 ;;
            --font-size)        arg_font_size="${2}"
                                if [[ -z ${(M)FONT_SIZES:#$arg_font_size} ]]; then
                                    echo_error "Unrecognized font size: ${arg_font_size}\nAborting." ; exit 1
                                fi
                                shift 2 ;;
            --help)             show_usage ; exit 0 ;;
            --image)            arg_image_file="${2}"
                                [[ ! -f "${arg_image_file}" ]] && echo_error "Missing image file" && exit 1
                                shift 2 ;;
            --markdown)         arg_markdown_file="${2}"
                                [[ ! -f "${arg_markdown_file}" ]] && echo_error "Missing markdown file" && exit 1
                                shift 2 ;;
            --latex)            flag_latex_output=1 ; shift ;;
            --latex-only)       flag_latex_only_output=1 ; shift ;;
            --no-backmatter)    flag_no_backmatter=1 ; shift ;;
            --no-copyright)     flag_no_copyright=1 ; shift ;;
            --no-frontmatter)   flag_no_frontmatter=1 ; shift ;;
            --no-images)        flag_no_images=1 ; shift ;;
            --no-lof)           flag_no_lof=1 ; shift ;;
            --no-lot)           flag_no_lot=1 ; shift ;;
            --no-toc)           flag_no_toc=1 ; shift ;;
            --od)               arg_output_dir="${2}"
                                [[ ! -d "${arg_output_dir}" ]] && mkdir -p "${arg_output_dir}"
                                cd "${arg_output_dir}" && arg_output_dir=$(pwd) && cd "$CURRENT_DIR"
                                shift 2 ;;
            --of)               arg_output_file="${2}" ; shift 2 ;;
            --paper-size)       arg_paper_size="${2:l}"
                                if [[ -z ${(M)PAPER_SIZES:#$arg_paper_size} ]]; then
                                    echo_error "Unrecognized paper size: ${arg_paper_size}" ; exit 1
                               fi
                                shift 2 ;;
            --show-frame)       flag_show_frame=1 ; shift ;;
            --template)         arg_template_file="${2}" ; shift 2 ;;
            --toc-depth)        arg_toc_depth="${2}" ; shift 2 ;;
            --use-latest)       if command -v ${PROGRAM_ALT} &> /dev/null ; then PROGRAM="${PROGRAM_ALT}" ; fi
                                shift ;;
            *)                  shift ;;
        esac
    done
}
