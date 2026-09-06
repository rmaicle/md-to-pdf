declare v_input_dir="${DEFAULT_INPUT_DIR}"
declare -a v_tex_files
declare -a v_source_files
declare -a v_source_fm_files
declare -a v_source_bm_files
declare -a v_pp_fm_files
declare -a v_pp_bm_files

declare v_include_front_matter=""
declare v_include_back_matter=""
declare v_output_latex_file=""
declare v_output_file=""

# Multi-line safely packed configuration strings
declare md_ext="-f markdown+alerts -f markdown+blank_before_blockquote -f markdown+blank_before_header \
-f markdown+escaped_line_breaks -f markdown+fancy_lists -f markdown+fenced_code_blocks -f markdown+footnotes \
-f markdown+grid_tables -f markdown+header_attributes -f markdown+implicit_figures -f markdown+inline_code_attributes \
-f markdown+multiline_tables -f markdown+line_blocks -f markdown+link_attributes -f markdown+pipe_tables \
-f markdown+raw_attribute -f markdown+raw_tex -f markdown+space_in_atx_header -f markdown+table_captions"

function verify_pandoc_version() {
    declare v_pandoc_version="$(${PROGRAM} --version | head -n 1 | cut -d' ' -f2)"
    if [[ "${v_pandoc_version}" =~ "^3.2.[1-9]" ]] || [[ "${v_pandoc_version}" =~ "^3.[3-9]" ]]; then
        echo "Note: Ensure \pandocbounded macro is safely configured in your custom template layouts."
    fi
}

function validate_input_and_template_paths() {
    # 1. Resolve and Validate Markdown Content File
    if [[ "${arg_markdown_file:h}" != "." ]]; then
        cd "${arg_markdown_file:h}"
        v_input_dir=$(pwd)
        cd "$CURRENT_DIR"
    else
        v_input_dir="${CURRENT_DIR}"
    fi

    # Fail-Safe check for markdown structure index maps
    if [[ ! -f "${v_input_dir}/${arg_markdown_file:t}" ]]; then
        echo_error "Validation Failed: Could not locate your markdown file list!"
        exit 1
    fi
    arg_markdown_file="${v_input_dir}/${arg_markdown_file:t}"

    # 2. Check Optional Image Content File
    if [[ ! -f "${v_input_dir}/${arg_image_file:t}" ]]; then
        flag_no_images=1
    else
        arg_image_file="${v_input_dir}/${arg_image_file:t}"
    fi

    # 3. Intelligent Template Resolution Path Lookups
    if [[ "${arg_template_file:h}" == "." ]]; then
        if [[ -f "${v_input_dir}/${arg_template_file}" ]]; then
            arg_template_file="${v_input_dir}/${arg_template_file}"
        elif [[ -f "${DEFAULT_TEMPLATE_DIR}/${arg_template_file}" ]]; then
            arg_template_file="${DEFAULT_TEMPLATE_DIR}/${arg_template_file}"
        else
            echo_error "Validation Failed: Template document file matching '${arg_template_file}' could not be resolved."
            exit 1
        fi
    fi

    # --- YNAMIC OUTPUT NAMING OVERRIDE LAYER ---
    # If the user did NOT pass a custom filename via the '--of' flag,
    # force the file to match the current target input directory name tail string.
    if [[ "${arg_output_file}" == "output" || -z "${arg_output_file}" ]]; then
        # Extra safeguards to ensure we pull the folder tail name reliably
        declare target_folder_name="${v_input_dir:t}"
        arg_output_file="${target_folder_name}"
    fi
    # -----------------------------------------------

    # 4. Outfile Parameter Initialization
    v_output_latex_file="${arg_output_file}.${DEFAULT_LATEX_EXT}"
    v_output_file="${arg_output_file}.${DEFAULT_OUTPUT_EXT}"
    arg_output_file="${arg_output_dir}/${v_output_file}"

    # Warn the user if they are overwriting previous build generations
    if [[ -f "${arg_output_dir}/${v_output_latex_file}" && ${flag_latex_output} -eq 1 ]]; then
        echo_yellow "Warning: Target LaTeX file exists. Compilation will overwrite: ${v_output_latex_file}"
    fi
    if [[ -f "${arg_output_file}" && ${flag_latex_only_output} -eq 0 ]]; then
        echo_yellow "Warning: Target document asset exists. Compilation will overwrite: ${v_output_file}"
    fi
}

function preprocess_tex_images() {
    [[ ${flag_no_images} -eq 1 ]] && return
    [[ ! -d "${v_input_dir}/tex-images" ]] && mkdir -p "${v_input_dir}/tex-images"

    while IFS= read -r line || [[ -n "$line" ]]; do
        # Trim leading and trailing spaces natively in Zsh
        declare file="${line##[[:space:]]##}"
        file="${file%%[[:space:]]##}"

        # Skip empty lines and entries prefixed with skip markers
        [[ -z "${file}" || "${file}" == "x" || "${file}" =~ ^x[[:space:]]+ ]] && continue

        v_tex_files+=("${v_input_dir}/${file}")

        # Get target asset location context directory path
        declare v_tex_file_dir="${file:h}"
        cd "${v_input_dir}/${v_tex_file_dir}"

        declare bname="${file:t:r}"
        echo "Rendering Vector Graphics Asset [${bname}.tex]..."

        # CRITICAL FIX: Removed '-draftmode' specifically for standalone graphics files
        # to allow pdflatex to generate physical pages so that the conversion library
        # can safely write down the compiled asset.
        pdflatex -shell-escape "${file:t}" >/dev/null 2>&1

        # Safely migrate generated dependencies to asset repository
        for ext in aux log pdf png; do
            [[ -e "${bname}.${ext}" ]] && mv -f "${bname}.${ext}" "${v_input_dir}/tex-images/"
        done

        cd "${v_input_dir}"
    done < "${arg_image_file}"
}

function preprocess_markdown_contents() {
    # Reset tracking arrays cleanly
    v_source_files=()
    v_source_fm_files=()
    v_source_bm_files=()

    while IFS= read -r line || [[ -n "$line" ]]; do
        # Trim leading/trailing spaces natively in Zsh
        declare file="${line##[[:space:]]##}"
        file="${file%%[[:space:]]##}"

        # Skip empty entries or marked files cleanly
        [[ -z "${file}" || "${file}" == "x" || "${file}" =~ ^x[[:space:]]+ ]] && continue
        declare bname="${file:t}"

        # Enforce unified, absolute paths for ALL kept files immediately
        declare absolute_filepath="${v_input_dir}/${file}"

        if [[ "${bname}" =~ "fm_[a-z]_" ]]; then
            if [ ${flag_no_frontmatter} -eq 0 ]; then
                v_source_fm_files+=("${absolute_filepath}")
            fi
        elif [[ "${bname}" =~ "bm_[a-z]_" ]]; then
            if [ ${flag_no_backmatter} -eq 0 ]; then
                v_source_bm_files+=("${absolute_filepath}")
            fi
        else
            v_source_files+=("${absolute_filepath}")
        fi
    done < "${arg_markdown_file}"
}

function run_pandoc_compilation() {
    cd "${v_input_dir}"

    # Core metadata arguments configuration array
    declare -a p_opts=(
        "--metadata=fontsize:${arg_font_size}"
        "--toc-depth=${arg_toc_depth}"
        "--syntax-highlighting=idiomatic"  # Replaces deprecated highlight-style and listings flags
    )
    [[ -n "${arg_paper_size}" ]] && p_opts+=("--metadata=papersize:${arg_paper_size}")
    [[ ${flag_draft} -eq 1 ]] && p_opts+=("--metadata=is_draft=true")
    [[ ${flag_no_copyright} -eq 0 ]] && p_opts+=("--metadata=with_copyright:true")
    [[ ${flag_no_toc} -eq 0 ]] && p_opts+=("--table-of-contents")

    # Render Frontmatter assets securely if populated
    if [[ ${#v_source_fm_files} -gt 0 ]]; then
        for f in "${v_source_fm_files[@]}"; do
            declare texf="${f:r}.${DEFAULT_LATEX_EXT}"
            v_pp_fm_files+=("${texf}")
            v_include_front_matter+="--include-before-body=${texf} "
            ${=PROGRAM} "${f}" "${p_opts[@]}" ${=md_ext} --to=latex >! "${texf}"
        done
    fi

    # Render Backmatter assets securely if populated
    if [[ ${#v_source_bm_files} -gt 0 ]]; then
        for f in "${v_source_bm_files[@]}"; do
            declare texf="${f:r}.${DEFAULT_LATEX_EXT}"
            v_pp_bm_files+=("${texf}")
            v_include_back_matter+="--include-after-body=${texf} "
            ${=PROGRAM} "${f}" "${p_opts[@]}" ${=md_ext} --to=latex >! "${texf}"
        done
    fi

    # Populate build strings dynamically to avoid empty args
    declare -a optional_build_args=()
    [[ -n "${v_include_front_matter}" ]] && optional_build_args+=(${=v_include_front_matter})
    [[ -n "${v_include_back_matter}" ]]  && optional_build_args+=(${=v_include_back_matter})

    # Run primary document structure generation compilation pass
    if [ ${flag_latex_output} -eq 1 ]; then
        echo "Compiling LaTeX Intermediate Output Step..."
        ${=PROGRAM} ${v_source_files} "${optional_build_args[@]}" \
            --resource-path="${v_input_dir}:${v_input_dir}/tex-images" \
            --template="${arg_template_file}" "${p_opts[@]}" ${=md_ext} \
            --standalone --to=latex >! "${v_output_latex_file}"
    fi

    if [ ${flag_latex_only_output} -eq 0 ]; then
        echo "Compiling Markdown sources into target PDF Document Asset..."
        ${=PROGRAM} ${v_source_files} \
            "${optional_build_args[@]}" \
            --resource-path="${v_input_dir}:${v_input_dir}/tex-images" \
            --template="${arg_template_file}" "${p_opts[@]}" ${=md_ext} \
            --standalone --to=latex --output="${v_output_file}"

        if [[ "$(pwd)" != "${arg_output_dir}" ]]; then
            mv "${v_output_file}" "${arg_output_file}"
        fi
    fi
}

function cleanup_temp_files() {
    declare v_base_filename="${v_output_file:r}"

    # Appended '(N)' to allow Zsh to ignore missing files safely without warning
    rm -f "${v_base_filename}".(aux|lof|log|lot|toc)(N)

    if [ ${flag_latex_output} -eq 0 ]; then
        rm -f "${v_base_filename}.tex"(N)
    fi

    [[ -d "tex-images" && ${flag_debug_mode} -eq 0 ]] && rm -rf "tex-images"
    echo "Clean conversion pipeline complete. Enjoy your document!"
}
