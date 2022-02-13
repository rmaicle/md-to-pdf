#!/usr/bin/env bash

# Use the Unofficial Bash Strict Mode
# http://redsymbol.net/articles/unofficial-bash-strict-mode/
set -e
set -u
# Saner programming env: these switches turn some bugs into errors
set -o errexit -o pipefail -o noclobber -o nounset



declare HOME_DIR="$(eval echo ~${USER})"
declare SCRIPTNAME=${0##*/}
declare SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
declare CURRENT_DIR=$(pwd)

source /usr/local/bin/dirstack.sh
source /usr/local/bin/echo.sh



declare PROGRAM="pandoc"
declare HEADER="Script for converting markdown files to PDF.
Copyright (C) 2019-2022 Ricardo Maicle"



if ! command -v pandoc &> /dev/null ; then
    echo_error "Pandoc not found.\nDownload program from pandoc.org"
    exit 1
fi

declare flag_vmtouch_found=0
if command -v vmtouch &> /dev/null ; then
    flag_vmtouch_found=1
    v_pandoc_path="$(command -v pandoc)/pandoc"
    vmtouch -q -t "${v_pandoc_path}"
    vmtouch -q -t "/usr/bin/pdflatex"
fi



declare DEFAULT_MARKDOWN_CONTENT_FILE="markdownlist.txt"
declare DEFAULT_IMAGE_CONTENT_FILE="imagelist.txt"

# Engine: [pdflatex | xelatex | lualatex]
declare DEFAULT_PDF_ENGINE="pdflatex"
declare ALTERNATIVE_PDF_ENGINE="xelatex"

declare -a PDF_ENGINES=(
    "${DEFAULT_PDF_ENGINE}"
    "${ALTERNATIVE_PDF_ENGINE}"
)

# Paper arguments to script
declare PAPER_A4="a4"
declare PAPER_USLETTER="usletter"

declare DEFAULT_PAPER_SIZE="${PAPER_A4}"

declare -a PAPER_SIZES=(
    ${PAPER_A4}
    ${PAPER_USLETTER}
)

# Values passed to pandoc
declare -A PANDOC_PAPER_SIZES=(
    [${PAPER_A4}]="a4paper"
    [${PAPER_USLETTER}]="letterpaper"
)

declare DEFAULT_FONT_SIZE="10"
declare -a FONT_SIZES=(
    "9"
    "${DEFAULT_FONT_SIZE}"
    "11"
    "12"
)

declare DEFAULT_TEMPLATE_DIR="/usr/local/share"
declare DEFAULT_INPUT_DIR="${CURRENT_DIR}"
declare DEFAULT_OUTPUT_DIR="${CURRENT_DIR}"
declare DEFAULT_OUTPUT_FILE="output"
declare DEFAULT_OUTPUT_EXT="pdf"
declare DEFAULT_LATEX_EXT="tex"
declare DEFAULT_TOC_DEPTH="2"

declare DEFAULT_SKIP_FILE_MARKER="x "
declare DEFAULT_PREPROCESSOR_FILE_MARKER="pp-"



#
# Convert specified string argument to lowercase
#
function to_lowercase() {
    echo "$(echo ${1} | tr 'A-Z' 'a-z')"
}

#
# Help text
#
function show_usage() {
cat << EOF
${HEADER}

Converts the contents of markdown input file (${DEFAULT_MARKDOWN_CONTENT_FILE}) and TeX
image file (${DEFAULT_IMAGE_CONTENT_FILE}) using TeX/LaTex template file to PDF format.

Usage:
  ${SCRIPTNAME} [option...]

Options:
  --above-title-rule  offset the title rule display; this is the height
                      above the baseline to raise the rule box; default
                      is 0pt; positive values raises the rule; negative
                      values lowers the rule
  --after-title-rule  vertical space after title rule; default is 5pt;
  --debug             run script in debug mode
  --draft             generate draft version PDF document
  --engine            PDF engine to use; default is ${DEFAULT_PDF_ENGINE}
$(printf '                        %s point\n' ${PDF_ENGINES[@]})
  --fontsize n        body text font point size; default is ${DEFAULT_FONT_SIZE} pt.
$(printf '                        %s point\n' ${FONT_SIZES[@]})
  --gen-latest        use latest installed Pandoc version
  --help              print help and exit
  --image file        input file containing a list of TeX image files to
                      process; default filename is ${DEFAULT_IMAGE_CONTENT_FILE}
  --latex             output LaTeX files
  --markdown file     input file containing a list of markdown files to
                      process; default filename is ${DEFAULT_MARKDOWN_CONTENT_FILE}
  --no-backmatter     do not generate user-supplied backmatter pages
  --no-copyright      do not generate copyright page
  --no-frontmatter    do not generate user-supplied frontmatter pages
  --no-image          do not generate TeX images
  --no-lof            do not generate list of figures
  --no-lot            do not generate list of tables
  --no-toc            do not generate table of contents
  --od dir            output directory; default is current directory
  --of file           output filename appended with .pdf; default is 'output'
  --paper             paper size; default is letter
$(printf '                        %s\n' ${PAPER_SIZES[@]})
  --softcopy          generate E-book format PDF document
  --show-frame        show page margins
  --template file     TeX/LaTeX template file/file path; template files
                      is initially searched in the input directory, then
                      in the default template directory (${DEFAULT_TEMPLATE_DIR});
                      if argument is a relative file path, the search is
                      relative to the input directory
  --toc-depth level   set the number of levels deep to include in the
                      table of contents; default is ${DEFAULT_TOC_DEPTH};
                        0 - chapter
                        1 - section
                        2 - subsection
                        3 - subsubsection
                        4 - paragraph
                        5 - subparagraph
  --verbose           verbose messages
EOF
}



# function show_usage_more() {
# cat << EOF
# Markdown List File Formatting:
#   - frontmatter files are prefixed with 'fm_[a-z]_'
#   - backmatter files are prefixed with 'bm_[a-z]_'
#   - excluded files are prefixed with 'x ', small letter X followed by
#     a space character

#   The following is a minimal example of an input file:

#     00_0_metadata.md
#     fm_a_preface.md
#     01_introduction.md
#     02_structure_layout.md
#     03_formatting.md
#     x bm_a_build_script.md
#     bm_b_license.md
# EOF
# }



arg_paper_size="${DEFAULT_PAPER_SIZE}"
arg_font_size="${DEFAULT_FONT_SIZE}"
arg_markdown_file="${DEFAULT_MARKDOWN_CONTENT_FILE}"
arg_image_file="${DEFAULT_IMAGE_CONTENT_FILE}"
arg_template_file=""
arg_pdf_engine="${DEFAULT_PDF_ENGINE}"
arg_toc_depth="${DEFAULT_TOC_DEPTH}"
arg_output_dir="${DEFAULT_OUTPUT_DIR}"
arg_output_file="${DEFAULT_OUTPUT_FILE}"



flag_draft=0
flag_show_frame=0
flag_latex_output=0
flag_no_images=0
flag_no_backmatter=0
flag_no_frontmatter=0
flag_no_copyright=0
flag_no_toc=0
flag_no_lof=0
flag_no_lot=0



# read the options
OPTIONS_SHORT="v"
OPTIONS_LONG=""
# OPTIONS_LONG+=",above-title-rule:"
# OPTIONS_LONG+=",after-title-rule:"
OPTIONS_LONG+=",debug"
OPTIONS_LONG+=",draft"
OPTIONS_LONG+=",engine"
OPTIONS_LONG+=",fontsize:"
OPTIONS_LONG+=",help"
OPTIONS_LONG+=",image:"
OPTIONS_LONG+=",latex"
OPTIONS_LONG+=",markdown:"
OPTIONS_LONG+=",no-backmatter"
OPTIONS_LONG+=",no-copyright"
OPTIONS_LONG+=",no-frontmatter"
OPTIONS_LONG+=",no-images"
OPTIONS_LONG+=",no-lof"
OPTIONS_LONG+=",no-lot"
OPTIONS_LONG+=",no-toc"
OPTIONS_LONG+=",od:"
OPTIONS_LONG+=",of:"
OPTIONS_LONG+=",paper:"
OPTIONS_LONG+=",show-frame"
OPTIONS_LONG+=",template:"
OPTIONS_LONG+=",toc-depth:"
OPTIONS_TEMP=$(getopt               \
    --options ${OPTIONS_SHORT}      \
    --longoptions ${OPTIONS_LONG}   \
    --name "${SCRIPTNAME}" -- "$@")
# Append unrecognized arguments after --
eval set -- "${OPTIONS_TEMP}"



while true; do
    case "${1}" in
        --debug)            flag_debug_mode=1 ; shift 2 ;;
        --draft)            flag_draft=1 ; shift ;;
        --engine)           arg_pdf_engine="${2}"
                            if [[ ! "${PDF_ENGINES[@]}" =~ "${arg_pdf_engine}" ]]; then
                                echo_error "Unrecognized PDF engine: ${arg_pdf_engine}\nAborting."
                                echo "Use one of: ${PDF_ENGINES[@]}"
                                exit 1
                            fi
                            shift 2
                            ;;
        --font-size)        arg_font_size="${2}"
                            if [[ ! "${FONT_SIZES[@]}" =~ "${arg_font_size}" ]]; then
                                echo_error "Unrecognized paper size: ${arg_font_size}\nAborting."
                                echo "Use one of: ${FONT_SIZES[@]}"
                                exit 1
                            fi
                            shift 2
                            ;;
        --help)             show_usage ; exit ;;
        --image)            arg_image_file="${2}"
                            shift 2
                            if [ ! -f "${arg_image_file}" ]; then
                                echo_error "Image list file not found: ${arg_image_file}\nAborting."
                                exit 1
                            fi
                            ;;
        --latex)            flag_latex_output=1 ; shift ;;
        --markdown)         arg_markdown_file="${2}"
                            shift 2
                            if [ ! -f "${arg_markdown_file}" ]; then
                                echo_error "Markdown list file not found: ${arg_markdown_file}\nAborting."
                                exit 1
                            fi
                            ;;
        --no-backmatter)    flag_no_backmatter=1 ; shift ;;
        --no-copyright)     flag_no_copyright=1 ; shift ;;
        --no-frontmatter)   flag_no_frontmatter=1 ; shift ;;
        --no-lof)           flag_no_lof=0 ; shift ;;
        --no-lot)           flag_no_lot=0 ; shift ;;
        --no-images)        flag_no_images=1 ; shift ;;
        --no-toc)           flag_no_toc=0 ; shift ;;
        --od)               arg_output_dir="${2}"
                            shift 2
                            # Create output directory if it does not exist
                            if [ ! -d "${arg_output_dir}" ]; then
                                mkdir -p "${arg_output_dir}"
                            fi
                            if [ ! -d "${arg_output_dir}" ]; then
                                echo_error "Output directory could not be created: ${arg_output_dir}"
                                exit 1
                            fi
                            # Create absolute path for the output directory
                            pushd "${arg_output_dir}"
                            arg_output_dir=$(pwd)
                            popd
                            ;;
        --of)               arg_output_file="${2}" ; shift 2 ;;
        --paper)            arg_paper_size="${2,,}"
                            shift 2
                            if [[ ! "${PAPER_SIZES[@]}" =~ "${arg_paper_size}" ]]; then
                                echo_error "Unrecognized paper size: ${arg_paper_size}\nAborting."
                                echo "Use one of: ${PAPER_SIZES[@]}"
                                exit 1
                            fi
                            ;;
        --show-frame)       flag_show_frame=1 ; shift ;;
        --template)         arg_template_file="${2}" ; shift 2 ;;
        *)                  break ;;
    esac
done



cat << EOF
${HEADER}

EOF



declare v_input_dir="${DEFAULT_INPUT_DIR}"

declare v_markdown_file="$(basename ${arg_markdown_file})"
declare v_markdown_dir="$(dirname ${arg_markdown_file})"
if [[ ! -z "${v_markdown_dir}" ]]; then
    pushd "${v_markdown_dir}"
    v_input_dir=$(pwd)
    popd
fi
# Create absolute file path for the markdown file
if [ -f "${v_input_dir}/${v_markdown_file}" ]; then
    arg_markdown_file="${v_input_dir}/${v_markdown_file}"
else
    echo_error "Markdown file does not exist: ${v_input_dir}/${v_markdown_file}"
    echo "Current directory: $(pwd)"
    exit 1
fi
# Create absolute file path for the image file
declare v_image_file="$(basename ${arg_image_file})"
# Create absolute file path for the markdown file
if [ -f "${v_input_dir}/${v_image_file}" ]; then
    arg_image_file="${v_input_dir}/${v_image_file}"
else
    flag_no_image=1
fi



# Template file argument may be a filename or a filename with a directory
if [[ $(dirname "${arg_template_file}") == "." ]]; then
    if [ -f "${v_input_dir}/${arg_template_file}" ]; then
        arg_template_file="${v_input_dir}/${arg_template_file}"
    else
        if [ -f "${DEFAULT_TEMPLATE_DIR}/${arg_template_file}" ]; then
            arg_template_file="${DEFAULT_TEMPLATE_DIR}/${arg_template_file}"
        else
            echo_error "Template file: ${2}\n  Not found: ${DEFAULT_TEMPLATE_DIR}\n  Not found: ${v_input_dir}\nAborting."
            exit 1
        fi
    fi
else
    if [ ! ${arg_template_file} != ${arg_template_file#/} ]; then
        if [ ! -f "${CURRENT_DIR}/${arg_template_file}" ]; then
            echo_error "Template file not found: ${CURRENT_DIR}/${arg_template_file}\nAborting."
            exit 1
        fi
        pushd "$(dirname ${CURRENT_DIR}/${arg_template_file})"
        arg_template_file="$(pwd)/$(basename ${arg_template_file})"
        popd
    fi
fi



declare v_output_latex_file="${arg_output_file}.${DEFAULT_LATEX_EXT}"
# v_output_latex_file="${arg_output_dir}/${v_output_latex_file}"
if [ -f "${arg_output_dir}/${v_output_latex_file}" ]; then
    echo_warn "Notice: LaTeX output file exists: ${v_output_latex_file}"
    echo_warn "        Existing file will be overwritten."
fi
declare v_output_file="${arg_output_file}.${DEFAULT_OUTPUT_EXT}"
arg_output_file="${arg_output_dir}/${v_output_file}"
if [ -f "${arg_output_file}" ]; then
    echo_warn "Notice: PDF output file exists: ${arg_output_file}"
    echo_warn "        Existing file will be overwritten."
fi



cat << EOF
Current directory: ${CURRENT_DIR}
Input directory: ${v_input_dir}
Input markdown file: $(basename ${arg_markdown_file})
Input image file: ${arg_image_file}
Template directory: $(dirname ${arg_template_file})
Template file: $(basename ${arg_template_file})
Output directory: ${arg_output_dir}
Output LaTeX file: ${v_output_latex_file}
Output PDF file: ${v_output_file%.*}
PDF Engine: ${arg_pdf_engine}

Paper size: ${PANDOC_PAPER_SIZES[${arg_paper_size}]}
Font size: ${arg_font_size}
ToC Depth: ${arg_toc_depth}

Draft: ${flag_draft}
Show frame: ${flag_show_frame}
LaTeX output: ${flag_latex_output}
No Table of Contents: ${flag_no_toc}
No List of Figures: ${flag_no_lof}
No List of Tables: ${flag_no_lot}
No Backmatter: ${flag_no_backmatter}
No Frontmatter: ${flag_no_frontmatter}
No Copyright: ${flag_no_copyright}

Using $(${PROGRAM} --version | head -n 1)
EOF



output_papersize="--metadata=papersize:${PANDOC_PAPER_SIZES[${arg_paper_size}]}"
output_font_size="--metadata=fontsize:${arg_font_size}"
if [ ${flag_draft} -eq 1 ]; then
    output_draft="--metadata=is_draft:true"
else
    output_draft="--metadata=is_draft:false"
fi
if [ ${flag_show_frame} -eq 1 ]; then
    output_show_frame="--metadata=showframe:true"
else
    output_show_frame="--metadata=showframe:false"
fi
if [ ${flag_no_toc} -eq 1 ]; then
    output_toc_page=""
else
    output_toc_page="--table-of-contents"
fi
output_toc_depth="--toc-depth=${arg_toc_depth}"
if [ ${flag_no_copyright} -eq 1 ]; then
    output_copyright_page="--metadata=with_copyright:false"
else
    output_copyright_page="--metadata=with_copyright:true"
fi

if [ ${flag_no_lof} -eq 1 ]; then
    output_lof_page="--metadata=lof:false"
else
    output_lof_page="--metadata=lof:true"
fi
if [ ${flag_no_lot} -eq 1 ]; then
    output_lot_page="--metadata=lot:false"
else
    output_lot_page="--metadata=lot:true"
fi



# Process image content file
if [ ${flag_no_image} -eq 1 ]; then
    echo "Skipping image content file preprocessing."
else
    v_skip_count=0
    v_found_count=0
    v_tex_files=()
    v_temp_tex_files=()
    echo "Checking existence of TeX files:"
    readarray -t v_temp_tex_files <"${arg_image_file}"
    for file in "${v_temp_tex_files[@]}"; do
        # Skip empty lines
        [[ -z "${file}" ]] && continue
        # Skip entries prefixed with the skip marker
        if [[ "${file:0:2}" == "${DEFAULT_SKIP_FILE_MARKER}" ]]; then
            echo_yellow "  Skipping: ${file:2}"
            v_skip_count=$((${v_skip_count} + 1))
            continue
        fi
        # Check if listed file exists
        if [ ! -f "${v_input_dir}/${file}" ]; then
            echo_red "  Missing TeX file: ${v_input_dir}/${file}"
            exit 1
        fi
        echo_green "  Found: ${file}"
        v_found_count=$((${v_found_count} + 1))
        v_tex_files+=("${v_input_dir}/${file}")
    done
    unset v_temp_tex_files
fi



# Process markdown content file
v_skip_count=0
v_found_count=0
v_base_filename=""
v_temp_source_files=()
v_source_files=()
v_source_fm_files=()
v_source_bm_files=()
echo "Checking existence of markdown files:"
readarray -t v_temp_source_files <"${arg_markdown_file}"
for file in "${v_temp_source_files[@]}"; do
    # Skip empty lines
    [[ -z "${file}" ]] && continue
    # Skip entries prefixed with the skip marker
    if [[ "${file:0:2}" == "${DEFAULT_SKIP_FILE_MARKER}" ]]; then
        echo_yellow "  Skipping:  ${file:2}"
        v_skip_count=$((${v_skip_count} + 1))
        continue
    fi
    # Check if listed file exists
    if [ ! -f "${v_input_dir}/${file}" ]; then
        echo_red "  Missing markdown file: ${v_input_dir}/${file}"
        exit 1
    fi
    # ${file} may contain a directory as in the case for big
    # documentation projects that group markdown files into
    # subdirectories.
    #
    # Get the base filename. If the file does not
    # contain a directory then the result is the same.
    v_base_filename=$(basename ${file})
    # Do not use source files prefixed with 'pp-'.
    # Files prefixed with 'pp-' are assumed to be generated
    # by the preprocessor program (pp).
    if [ "${v_base_filename:0:3}" == "${DEFAULT_PREPROCESSOR_FILE_MARKER}" ]; then
        echo_error "Source files may not begin with 'pp-'."
        echo_error "Please use another filename for ${file}."
        echo_error "Aborting."
        exit 1
    fi
    echo_green "  Found: ${file}"
    v_found_count=$((${v_found_count} + 1))
    # Compare first 5 characters of the filename and determine
    # if it is a frontmatter or backmatter file.
    if [[ "${v_base_filename:0:5}" =~ ^fm_[a-z]_$ ]]; then
        if [ ${flag_no_frontmatter} -eq 0 ]; then
            v_source_fm_files+=("${v_input_dir}/${file}")
        fi
    elif [[ "${v_base_filename:0:5}" =~ ^bm_[a-z]_$ ]]; then
        if [ ${flag_no_backmatter} -eq 0 ]; then
            v_source_bm_files+=("${v_input_dir}/${file}")
        fi
    else
        # Do not prepend directory location yet.
        # The directory is prepended after preprocessing.
        v_source_files+=("${file}")
    fi
done
echo "Found/skipped files: ${v_found_count}/${v_skip_count}"



pushd "${v_input_dir}"



# Pre-process TeX files
if [ ${flag_no_images} -eq 1 ]; then
    echo "Skipping preprocessing of TeX files."
else
    echo "Preprocessing TeX files..."
    # Create temporary directory for pre-processed image files
    [[ ! -d "tex-images" ]] && mkdir "tex-images"
    for file in "${v_tex_files[@]}"; do
        [[ -z "${file}" ]] && continue
        # Get file directory so we can 'cd' to it.
        # It seems that pdflatex must be in the same directory as the
        # input files.
        v_tex_file_dir=$(dirname ${file})
        pushd ${v_tex_file_dir}
        # Argument -draftmode tells pdflatex not to generate PDF file.
        pdflatex                                        \
            -shell-escape                               \
            -draftmode                                  \
            "${file}"
        # WORKAROUND: [pdfTeX 3.14159265-2.6-1.40.20]
        #
        # There seems to be a bug in -output-directory option.
        # Files are not sent to the specified output directory so we
        # are going to manually copy the files into that directory
        # as a work around.

        # basefilename="${file%.*}"

        # Remove directory and file extension
        v_base_filename=$(basename ${file})
        v_base_filename="${v_base_filename%.*}"
        echo_debug "Base Filename: ${v_base_filename}"

        # convert                     \
        #     "${basefilename}.png"   \
        #     -trim                   \
        #     +repage                 \
        #     "${basefilename}.png"

        # convert                                             \
        #     "${INPUT_DIR}/tex-images/${basefilename}.pdf"   \
        #     -colorspace RGB -type truecolor                 \
        #     -density 300                                    \
        #     -quality 100                                    \
        #     -trim                                           \
        #     +repage                                         \
        #     "${basefilename}.png"

        # Force-move .png file from ${v_input_dir}/tex-images directory
        # to current directory

        [ -e "${v_base_filename}.aux" ] && mv -f "${v_base_filename}.aux" ${v_input_dir}/tex-images/
        [ -e "${v_base_filename}.log" ] && mv -f "${v_base_filename}.log" ${v_input_dir}/tex-images/
        [ -e "${v_base_filename}.pdf" ] && mv -f "${v_base_filename}.pdf" ${v_input_dir}/tex-images/
        [ -e "${v_base_filename}.png" ] && mv -f "${v_base_filename}.png" ${v_input_dir}/tex-images/
        popd
    done
fi



# Pre-process frontmatter markdown files
v_pp_fm_files=()
v_include_front_matter=""
v_base_filename_tex=""
if [ ${flag_no_frontmatter} -eq 1 ]; then
    echo "Skipping preprocessing frontmatter markdown files."
else
    echo "Preprocessing frontmatter markdown files..."
    for file in "${v_source_fm_files[@]}"; do
        v_base_filename="${file%.*}"
        v_base_filename_tex="${v_base_filename}.${DEFAULT_LATEX_EXT}"
        if [ -f "${v_base_filename_tex}" ]; then
            rm -f "${v_base_filename_tex}"
        fi
        v_pp_fm_files+=("${v_base_filename_tex}")
        v_include_front_matter+="--include-before-body=${v_base_filename_tex} "
        ${PROGRAM}                                      \
            -L ${HOME_DIR}/.local/bin/panda.lua         \
            ${file}                                     \
            ${output_draft}                             \
            ${output_papersize}                         \
            ${output_font_size}                         \
            ${output_show_frame}                        \
            -f markdown+blank_before_blockquote         \
            -f markdown+blank_before_header             \
            -f markdown+escaped_line_breaks             \
            -f markdown+fancy_lists                     \
            -f markdown+fenced_code_blocks              \
            -f markdown+footnotes                       \
            -f markdown+header_attributes               \
            -f markdown+implicit_figures                \
            -f markdown+inline_code_attributes          \
            -f markdown+line_blocks                     \
            -f markdown+link_attributes                 \
            -f markdown+raw_attribute                   \
            -f markdown+raw_tex                         \
            -f markdown+space_in_atx_header             \
            ${output_toc_page}                          \
            ${output_toc_depth}                         \
            --to=latex                                  \
            --pdf-engine=${arg_pdf_engine}              \
            --markdown-headings=atx                     \
            --top-level-division=chapter                \
            --listings                                  \
            > "${v_base_filename_tex}"
    done
fi



# Pre-process backmatter markdown files
v_pp_bm_files=()
v_include_back_matter=""
if [ ${flag_no_backmatter} -eq 1 ]; then
    echo "Skipping preprocessing backmatter markdown files."
else
    echo "Preprocessing backmatter markdown files..."
    for file in "${v_source_bm_files[@]}"; do
        v_base_filename="${file%.*}"
        v_base_filename_tex="${v_base_filename}.${DEFAULT_LATEX_EXT}"
        if [ -f "${v_base_filename_tex}" ]; then
            rm -f "${v_base_filename_tex}"
        fi
        v_pp_bm_files+=("${v_base_filename_tex}")
        v_include_back_matter+="--include-after-body=${v_base_filename_tex} "
        ${PROGRAM}                                      \
            -L ${HOME_DIR}/.local/bin/panda.lua         \
            ${file}                                     \
            ${output_draft}                             \
            ${output_papersize}                         \
            ${output_font_size}                         \
            ${output_show_frame}                        \
            -f markdown+blank_before_blockquote         \
            -f markdown+blank_before_header             \
            -f markdown+escaped_line_breaks             \
            -f markdown+fancy_lists                     \
            -f markdown+fenced_code_blocks              \
            -f markdown+footnotes                       \
            -f markdown+header_attributes               \
            -f markdown+implicit_figures                \
            -f markdown+inline_code_attributes          \
            -f markdown+line_blocks                     \
            -f markdown+link_attributes                 \
            -f markdown+raw_attribute                   \
            -f markdown+raw_tex                         \
            -f markdown+space_in_atx_header             \
            ${output_toc_page}                          \
            ${output_toc_depth}                         \
            --to=latex                                  \
            --pdf-engine=${arg_pdf_engine}              \
            --markdown-headings=atx                     \
            --top-level-division=chapter                \
            --listings                                  \
            > "${v_base_filename_tex}"
    done
fi



# Pre-process mainmatter markdown files
# Create the images directory where pp will place the generated
# image files. The directory will be deleted after processing.

# echo "Preprocessing markdown files..."
# pushd "${v_input_dir}"
# [[ ! -d "images" ]] && mkdir "images"
# v_pp_files=()
# for file in "${v_source_files[@]}"; do
#     v_pp_file="${file%.*}_pp.md"
#     if [ -f "${v_pp_file}" ]; then
#         rm -f "${v_pp_file}"
#     fi
#     # pp -img=${v_input_dir}/images ${file} > "${v_ppfile}"
#     panda -img=${v_input_dir}/images ${file} > "${v_pp_file}"
#     v_pp_files+=("${v_input_dir}/${v_pp_file}")
#     # echo_debug "  ${v_input_dir}/${ppfile}"
# done
# popd
# unset v_pp_file



# Switch that tells whether to proceed generating the PDF file.
# This is necessary since the LaTeX output may have failed and so
# the PDF generation would likely fail too.
#
# Set to 0 to abort PDF generation.
v_proceed_pdf_gen=1

if [ ${flag_latex_output} -eq 1 ]; then
    echo "Creating Tex/LaTeX file ${v_output_latex_file}..."
    rm -f "${v_output_latex_file}"
    # Pandoc 2.11.2 deprecates --atx-headers,
    # use --markdown-headings=atx instead.
    ${PROGRAM}                                          \
        -L ${HOME_DIR}/.local/bin/panda.lua             \
        ${v_source_files[@]}                            \
        ${v_include_front_matter}                       \
        ${v_include_back_matter}                        \
        --resource-path=${v_input_dir}:${v_input_dir}/tex-images    \
        --template="${arg_template_file}"               \
        ${output_draft}                                 \
        ${output_papersize}                             \
        ${output_font_size}                             \
        ${output_copyright_page}                        \
        ${output_lot_page}                              \
        ${output_lof_page}                              \
        ${output_show_frame}                            \
        -f markdown+blank_before_blockquote             \
        -f markdown+blank_before_header                 \
        -f markdown+escaped_line_breaks                 \
        -f markdown+fancy_lists                         \
        -f markdown+fenced_code_blocks                  \
        -f markdown+footnotes                           \
        -f markdown+grid_tables                         \
        -f markdown+header_attributes                   \
        -f markdown+implicit_figures                    \
        -f markdown+inline_code_attributes              \
        -f markdown+line_blocks                         \
        -f markdown+link_attributes                     \
        -f markdown+multiline_tables                    \
        -f markdown+pipe_tables                         \
        -f markdown+raw_attribute                       \
        -f markdown+raw_tex                             \
        -f markdown+space_in_atx_header                 \
        -f markdown+table_captions                      \
        ${output_toc_page}                              \
        ${output_toc_depth}                             \
        --standalone                                    \
        --to=latex                                      \
        --pdf-engine=${arg_pdf_engine}                  \
        --markdown-headings=atx                         \
        --top-level-division=chapter                    \
        --listings                                      \
        > "${v_output_latex_file}"

    echo -e "\nEnd of Tex/LaTeX file.
    "
    [[ $? -eq 0 ]] && v_proceed_pdf_gen=1

    if [ ${v_proceed_pdf_gen} -eq 1 ]; then
        if [ -f "${v_output_latex_file}" ]; then
            if [[ ! "$(pwd)" == "${arg_output_dir}" ]]; then
                pdflatex "${v_output_latex_file}"
                if [ -f "${v_output_file}" ]; then
                    echo_debug "Output: ${v_output_file}"
                    if [[ ! "$(pwd)" == "${arg_output_dir}" ]]; then
                        mv "${v_output_file}" "${arg_output_file}"
                    fi
                else
                    echo "No output."
                fi
                mv "${v_output_latex_file}" "${arg_output_dir}/${v_output_latex_file}"
            fi
        fi
    fi
fi



if [ ${flag_latex_output} -eq 0 ]; then
    echo "Converting markdown files to ${v_output_file}..."
    # Pandoc 2.11.2 deprecates --atx-headers,
    # use --markdown-headings=atx instead.
    ${PROGRAM}                                          \
        -L ${HOME_DIR}/.local/bin/panda.lua             \
        ${v_source_files[@]}                            \
        ${v_include_front_matter}                       \
        ${v_include_back_matter}                        \
        --resource-path=${v_input_dir}:${v_input_dir}/tex-images    \
        --template="${arg_template_file}"               \
        ${output_draft}                                 \
        ${output_papersize}                             \
        ${output_font_size}                             \
        ${output_copyright_page}                        \
        ${output_lot_page}                              \
        ${output_lof_page}                              \
        ${output_show_frame}                            \
        -f markdown+blank_before_blockquote             \
        -f markdown+blank_before_header                 \
        -f markdown+escaped_line_breaks                 \
        -f markdown+fancy_lists                         \
        -f markdown+fenced_code_blocks                  \
        -f markdown+footnotes                           \
        -f markdown+grid_tables                         \
        -f markdown+header_attributes                   \
        -f markdown+implicit_figures                    \
        -f markdown+inline_code_attributes              \
        -f markdown+multiline_tables                    \
        -f markdown+line_blocks                         \
        -f markdown+link_attributes                     \
        -f markdown+pipe_tables                         \
        -f markdown+raw_attribute                       \
        -f markdown+raw_tex                             \
        -f markdown+space_in_atx_header                 \
        -f markdown+table_captions                      \
        ${output_toc_page}                              \
        ${output_toc_depth}                             \
        --standalone                                    \
        --to=latex                                      \
        --output=${v_output_file}                       \
        --pdf-engine=${arg_pdf_engine}                  \
        --markdown-headings=atx                         \
        --top-level-division=chapter                    \
        --number-sections                               \
        --listings

    if [ -f "${v_output_file}" ]; then
        if [[ ! "$(pwd)" == "${arg_output_dir}" ]]; then
            mv "${v_output_file}" "${arg_output_file}"
        fi
    else
        echo "No output."
    fi
fi

v_base_filename="${v_output_file%.*}"
[ -f "${v_base_filename}.aux" ] && rm "${v_base_filename}.aux"
[ -f "${v_base_filename}.lof" ] && rm "${v_base_filename}.lof"
[ -f "${v_base_filename}.log" ] && rm "${v_base_filename}.log"
[ -f "${v_base_filename}.lot" ] && rm "${v_base_filename}.lot"
if [ ${flag_latex_output} -eq 0 ]; then
    [ -f "${v_base_filename}.tex" ] && rm "${v_base_filename}.tex"
fi
[ -f "${v_base_filename}.toc" ] && rm "${v_base_filename}.toc"

[[ -d "tex-images" ]] && rm -rf  "tex-images"

popd



echo "Cleaning up..."

if [ ${flag_no_frontmatter} -eq 0 ]; then
    for file in "${v_pp_fm_files[@]}"; do
        if [ ${flag_debug_mode} -eq 0 ]; then
            rm -f "${file}"
        fi
    done
fi

if [ ${flag_no_backmatter} -eq 0 ]; then
    for file in "${v_pp_bm_files[@]}"; do
        if [ ${flag_debug_mode} -eq 0 ]; then
            rm -f "${file}"
            rm -f "${file%.*}.md"
        fi
    done
fi

unset v_base_filename
unset v_base_filename_tex
echo "Done."
