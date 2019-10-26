#!/usr/bin/env bash

declare INPUT_FILE="filelist.txt"

#
# Display script usage
#
function show_usage() {
cat << EOF
Script for converting markdown files to PDF using LaTeX.

It reads an input file (default is ${INPUT_FILE}) containing a list of
markdown files. The markdown files are pre-processed before converting
them to a PDF file using the specified TeX/LaTex template file.

Usage:
  ${0##*/} [-debug] [option...]
Options:
  -h            print help and exit
  -debug        run script in debug mode
  -draft        generate draft version PDF document
  -softcopy     generate E-book format PDF document
  -papersize    paper size; default is letter
$(printf '                  %s\n' ${ARG_PAPER_SIZES[@]})
  -fontsize n   body text font size; values are in point size;
                  default is 10
$(printf '                  %s\n' ${ARG_FONT_SIZES[@]})
  -showframe    show page margins
  -imagex       do not generate TeX images
  -frontmatterx do not generate user-supplied frontmatter contents
  -backmatterx  do not generate user-supplied backmatter contents
  -i [file]     input file containing the list of markdown files to
                  process; if not specified and this script file is
                  called from another script file, then the current
                  directory is the calling script file's directory
                  and the filelist.txt file is assumed to be there
  -td [dir]     TeX/LaTeX template base directory; absolute path or
                  relative to the directory this shell script is in;
                  this is where template images must be found
  -tf [file]    template file; relative to the TeX/LaTeX template
                  base directory
  -o            output TeX/LaTeX file
  -od [dir]     output directory; default is current directory
  -of [file]    output base filename; default is 'output'
                  default output filename is '<file>.pdf
  -v            verbose messages
Input File Syntax:
  - frontmatter files are prefixed with 'fm_[a-z]_'
  - backmatter files are prefixed with 'bm_[a-z]_'
  - excluded files are prefixed with 'x ', small letter X followed by
    a space character

  The following is a minimal example of an input file:

    00_0_metadata.md
    fm_a_preface.md
    01_introduction.md
    02_structure_layout.md
    03_formatting.md
    x bm_a_build_script.md
    bm_b_license.md
EOF
}



declare -r SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
declare -r CURRENT_DIR=$(pwd)

pushd ${SCRIPT_DIR} > /dev/null
. utility.sh
. document.sh
popd > /dev/null

init_document_vars


echo_debug "SCRIPT_DIR: ${SCRIPT_DIR}"
echo_debug "CURRENT_DIR: ${CURRENT_DIR}"


#declare -r PAPER_SIZE_USLETTER="letterpaper"
#declare -r PAPER_SIZE_A4="a4paper"

declare -r FONT_SIZE_10=10pt
declare -r FONT_SIZE_11=11pt
declare -r FONT_SIZE_12=12pt


output_latex=0
output_draft=""
output_softcopy=""
output_paper=""
output_font_size=""
output_show_frame=""
output_image_generate=1
output_frontmatter_generate=1
output_backmatter_generate=1

if [[ $# -eq 0 ]] || [[ "${1}" = "--help" ]]; then
    show_usage
    exit
fi

if [[ $# -gt 0 ]] && [[ "${1}" = "-debug" ]]; then
    shift
    flag_debug_mode=1
fi

if [[ $# -gt 0 ]] && [[ "${1}" = "-draft" ]]; then
    shift
    output_draft="--metadata=is_draft:true"
fi

if [[ $# -gt 0 ]] && [[ "${1}" = "-softcopy" ]]; then
    shift
    output_softcopy="--metadata=is_softcopy:true"
fi

if [[ $# -gt 0 ]] && [[ "${1}" = "-papersize" ]]; then
    if [[ "${2}" == "${ARG_PAPER_USLETTER}" ]]; then
        output_papersize="--metadata=papersize:${PAPER_US_LETTER}"
    elif [[ "${2}" == "${ARG_PAPER_A4}" ]]; then
        output_papersize="--metadata=papersize:${PAPER_A4}"
    else
        echo "Unknown paper size argument."
        ECHO "Use one of: ${ARG_PAPER_SIZES[@]}"
        echo "Aborting."
        exit 1
    fi
    shift 2
fi

if [[ $# -gt 0 ]] && [[ "${1}" = "-fontsize" ]]; then
    if [[ "${2}" == "${ARG_FONT_SIZE_10PT}" ]]; then
        output_font_size="--metadata=fontsize:${FONT_SIZE_10PT}"
    elif [[ "${2}" == "${ARG_FONT_SIZE_11PT}" ]]; then
        output_font_size="--metadata=fontsize:${FONT_SIZE_11PT}"
    elif [[ "${2}" == "${ARG_FONT_SIZE_12PT}" ]]; then
        output_font_size="--metadata=fontsize:${FONT_SIZE_12PT}"
    else
        echo "Unknown font size argument: ${2}"
        ECHO "Use one of: ${ARG_FONT_SIZES[@]}"
        echo "Aborting."
        exit 1
    fi
    shift 2
fi

if [[ $# -gt 0 ]] && [[ "${1}" = "-showframe" ]]; then
    shift
    output_show_frame="--metadata=showframe:true"
fi

if [[ $# -gt 0 ]] && [[ "${1}" = "-imagex" ]]; then
    shift
    output_image_generate=0
fi

if [[ $# -gt 0 ]] && [[ "${1}" = "-frontmatterx" ]]; then
    shift
    output_frontmatter_generate=0
fi

if [[ $# -gt 0 ]] && [[ "${1}" = "-backmatterx" ]]; then
    shift
    output_backmatter_generate=0
fi


# Determine the full path of the specified input directory.
# If the input directory is not specified, then it defaults to
# the current working directory.


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

if [ ${flag_debug_mode} -eq 1 ]; then
    echo "Script Dir:    ${SCRIPT_DIR}"
    echo "Current Dir:   ${CURRENT_DIR}"
    echo "Input Dir:     ${INPUT_DIR}"
    echo "Input File:    ${INPUT_FILE}"
    echo "Output Dir:    ${OUTPUT_DIR}"
    echo "Output File:   ${OUTPUT_FILENAME}"
    echo "Template Dir:  ${TEMPLATE_DIR}"
    echo "Template File: ${TEMPLATE_FILE}"
fi

# If there is a TeX input file then read its contents

tex_files=()
temp_tex_files=()
if [ -e "${INPUT_DIR}/image.txt" ]; then
    echo "Checking existence of TeX files:"
    readarray -t temp_tex_files <"${INPUT_DIR}/image.txt"
    for file in "${temp_tex_files[@]}"; do
        #exclude_marker=${file:0:2}
        if [[ ! -z "${file}" ]] && [[ "${file:0:2}" != "x " ]]; then
            if [ ! -e "${INPUT_DIR}/${file}" ]; then
                echo "  Missing TeX file: ${INPUT_DIR}/${file}"
                exit 1
            else
                echo "  Found: ${file}"
                tex_files+=("${file}")
            fi
        fi
    done
fi

# Read the markdown input file contents

temp_source_files=()
source_files=()
source_fm_files=()
source_bm_files=()
echo "Checking existence of markdown files:"
readarray -t temp_source_files <"${INPUT_DIR}/${INPUT_FILE}"
for file in "${temp_source_files[@]}"; do
    #exclude_marker=${file:0:2}
    if [[ ! -z "${file}" ]] && [[ "${file:0:2}" != "x " ]]; then
        if [ ! -e "${INPUT_DIR}/${file}" ]; then
            echo "  Missing markdown file: ${INPUT_DIR}/${file}"
            exit 1
        else
            echo "  Found: ${file}"
            # ${file} may contain a directory as in the case of big
            # documentation projects that group markdown files into
            # subdirectories.
            #
            # Let's get the base filename. If the file does not
            # contain a directory then the result is the same.
            base_filename=$(basename ${file})
            file_prefix=${base_filename:0:5}
            if [[ "${file_prefix}" =~ ^fm_[a-z]_$ ]]; then
                source_fm_files+=("${INPUT_DIR}/${file}")
            elif [[ "${file_prefix}" =~ ^bm_[a-z]_$ ]]; then
                source_bm_files+=("${INPUT_DIR}/${file}")
            else
                # Do not prepend directory location yet.
                # The directory is prepended after preprocessing.
                source_files+=("${file}")
            fi
        fi
    fi
done

echo_debug "Frontmatter: ${#source_fm_files[@]}"
echo_debug "Backmatter: ${#source_bm_files[@]}"

# Pre-process TeX files

if [ ${output_image_generate} -eq 1 ]; then
    echo_debug "Preprocessing TeX files..."
    pushd "${INPUT_DIR}"
    if [ ! -d "tex-images" ]; then
        mkdir "tex-images"
    fi
    for file in "${tex_files[@]}"; do
        echo_debug "  ${INPUT_DIR}/${file}"
        # Argument -draftmode tells pdflatex not to generate PDF file.
        # Argument -output-directory is where the outputs are sent.
        pdflatex                            \
            -shell-escape                   \
            -draftmode                      \
            ${file}
        # There seems to be a bug in -output-directory option.
        # Files are not sent to the specified output directory so we
        # are going to manually copy the files into that directory
        # as a work around.
        # pdfTeX 3.14159265-2.6-1.40.20 (TeX Live 2019/Arch Linux)
        basefilename="${file%.*}"
        mv -f "${basefilename}.aux" ./tex-images/
        mv -f "${basefilename}.log" ./tex-images/
        mv -f "${basefilename}.pdf" ./tex-images/
        mv -f "${basefilename}.png" ./tex-images/
    done
    echo_debug "Deleting intermediate files:"
    popd # ${INPUT_DIR}
else
    echo "Skipping preprocessing of TeX files."
fi

# Pre-process frontmatter markdown files

pp_fm_files=()
if [ ${output_frontmatter_generate} == 1 ]; then
    echo_debug "Preprocessing frontmatter markdown files..."
    # Because Pandoc only looks for latex template image files on its
    # "working directory", we must go into the latex templates directory
    pushd "${TEMPLATE_DIR}"
    for file in "${source_fm_files[@]}"; do
        echo_debug "  ${file}"
        basefilename="${file%.*}"
        pp_fm_files+=("${basefilename}.tex")
        pandoc                                          \
            ${file}                                     \
            ${output_draft}                             \
            ${output_softcopy}                          \
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
            -f markdown+raw_tex                         \
            -f markdown+space_in_atx_header             \
            --to=latex                                  \
            --pdf-engine=pdflatex                       \
            --atx-headers                               \
            --toc                                       \
            --top-level-division=chapter                \
            --listings                                  \
            > "${basefilename}.tex"
    done
    popd # ${TEMPLATE_DIR}
fi

include_front_matter=""
if [ ${output_frontmatter_generate} == 1 ]; then
    for file in "${pp_fm_files[@]}"; do
        #include_front_matter+="--include-before-body=${file} "
        include_front_matter+="--include-before-body=${file} "
    done
fi

# Pre-process backmatter markdown files

pp_bm_files=()
if [ ${output_backmatter_generate} == 1 ]; then
    echo_debug "Preprocessing backmatter markdown files..."
    # Because Pandoc only looks for latex template image files on its
    # "working directory", we must go into the latex templates directory
    pushd "${TEMPLATE_DIR}"
    for file in "${source_bm_files[@]}"; do
        echo_debug "  ${file}"
        ppfile="${file%.*}_pp.md"
        pp ${file} > "${ppfile}"
        basefilename="${ppfile%.*}"
        pp_bm_files+=("${basefilename}.tex")
        pandoc                                          \
            ${ppfile}                                   \
            ${output_draft}                             \
            ${output_softcopy}                          \
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
            -f markdown+raw_tex                         \
            -f markdown+space_in_atx_header             \
            --to=latex                                  \
            --pdf-engine=pdflatex                       \
            --atx-headers                               \
            --toc                                       \
            --top-level-division=chapter                \
            --listings                                  \
            > "${basefilename}.tex"
    done
    popd # ${TEMPLATE_DIR}
fi

include_back_matter=""
if [ ${output_backmatter_generate} == 1 ]; then
    for file in "${pp_bm_files[@]}"; do
        include_back_matter+="--include-after-body=${file} "
    done
fi

# Pre-process mainmatter markdown files

echo_debug "Preprocessing markdown files..."
pushd "${INPUT_DIR}"
if [ ! -d "images" ]; then
    mkdir "images"
fi
pp_files=()
for file in "${source_files[@]}"; do
    ppfile="${file%.*}_pp.md"
    pp_files+=("${INPUT_DIR}/${ppfile}")
    echo_debug "  ${INPUT_DIR}/${ppfile}"
    pp ${file} > "${ppfile}"
done
popd # ${INPUT_DIR}

# Because Pandoc only looks for latex template image files on its
# "working directory", we must go into the latex templates directory
pushd "${TEMPLATE_DIR}"

# Switch that tells whether to proceed generating the PDF file.
# This is necessary since the LaTeX output may have failed and so
# the PDF generation would likely fail too.
#
# Set to 0 to abort PDF generation.
proceed_pdf_gen=1

if [ ${output_latex} -eq 1 ]; then
    echo_debug "Creating Tex/LaTeX file ${OUTPUT_LATEX}..."
    rm -f "${OUTPUT_LATEX}"

    pandoc                                          \
        ${pp_files[@]}                              \
        ${include_front_matter}                     \
        ${include_back_matter}                      \
        --resource-path=.:${INPUT_DIR}              \
        --template="${TEMPLATE_FILE}"               \
        ${output_draft}                             \
        ${output_softcopy}                          \
        ${output_papersize}                         \
        ${output_font_size}                         \
        --metadata=lof                              \
        --metadata=lot                              \
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
        -f markdown+raw_tex                         \
        -f markdown+space_in_atx_header             \
        --standalone                                \
        --to=latex                                  \
        --pdf-engine=pdflatex                       \
        --atx-headers                               \
        --toc                                       \
        --top-level-division=chapter                \
        --listings                                  \
        > "${OUTPUT_LATEX}"

    if [ $? -eq 0 ]; then
      proceed_pdf_gen=1
    fi

    if [ ${proceed_pdf_gen} -eq 1 ]; then
        if [ -e "${OUTPUT_LATEX}" ]; then
            echo "Latex: ${OUTPUT_DIR}/${OUTPUT_LATEX}"
            if [[ ! "$(pwd)" == "${OUTPUT_DIR}" ]]; then
                pdflatex "${OUTPUT_LATEX}"
                if [ -e "${OUTPUT_FILENAME}" ]; then
                    echo "Output: ${OUTPUT_DIR}/${OUTPUT_FILENAME}"
                    if [[ ! "$(pwd)" == "${OUTPUT_DIR}" ]]; then
                        mv "${OUTPUT_FILENAME}" "${OUTPUT_DIR}/${OUTPUT_FILENAME}"
                    fi
                else
                    echo "No output."
                fi
                mv "${OUTPUT_LATEX}" "${OUTPUT_DIR}/${OUTPUT_LATEX}"
            fi
        fi
    fi
fi

if [ ${proceed_pdf_gen} -eq 1 ]; then
    echo_debug "Converting markdown files to ${OUTPUT_FILENAME}..."
    pandoc                                          \
        ${pp_files[@]}                              \
        ${include_front_matter}                     \
        ${include_back_matter}                      \
        --resource-path=.:${INPUT_DIR}              \
        --template="${TEMPLATE_FILE}"               \
        ${output_draft}                             \
        ${output_softcopy}                          \
        ${output_papersize}                         \
        ${output_font_size}                         \
        --metadata=lof                              \
        --metadata=lot                              \
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
        -f markdown+raw_tex                         \
        -f markdown+space_in_atx_header             \
        --standalone                                \
        --to=latex                                  \
        --output=${OUTPUT_FILENAME}                 \
        --pdf-engine=pdflatex                       \
        --atx-headers                               \
        --toc                                       \
        --top-level-division=chapter                \
        --listings

    if [ -e "${OUTPUT_FILENAME}" ]; then
        echo "Output: ${OUTPUT_DIR}/${OUTPUT_FILENAME}"
        if [[ ! "$(pwd)" == "${OUTPUT_DIR}" ]]; then
            mv "${OUTPUT_FILENAME}" "${OUTPUT_DIR}/${OUTPUT_FILENAME}"
        fi
    else
        echo "No output."
    fi
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

popd # ${TEMPLATE_DIR}

echo_debug "Deleting matter intermediate files:"
for file in "${pp_files[@]}"; do
    if [ ${flag_debug_mode} -eq 0 ]; then
        rm -f "${file}"
    fi
done

pushd "${INPUT_DIR}"
if [ ${flag_debug_mode} -eq 0 ]; then
    if [ -d "images" ]; then
        rmdir "images"
    fi
fi
popd # ${INPUT_DIR}

if [ ${output_frontmatter_generate} == 1 ]; then
    for file in "${pp_fm_files[@]}"; do
        if [ ${flag_debug_mode} -eq 0 ]; then
            rm -f "${file}"
        fi
    done
fi

if [ ${output_backmatter_generate} == 1 ]; then
    echo_debug "Deleting backmatter intermediate files..."
    for file in "${pp_bm_files[@]}"; do
        if [ ${flag_debug_mode} -eq 0 ]; then
            rm -f "${file}"
            rm -f "${file%.*}.md"
        fi
    done
fi

echo "Done."
