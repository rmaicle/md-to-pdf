#!/usr/bin/env zsh
set -u

arg_markdown_file="markdownlist.txt"

if [[ ! -f "${arg_markdown_file}" ]]; then
    echo "Error: Cannot find ${arg_markdown_file}"
    exit 1
fi

echo "=========================================================="
echo "   Zsh Front/Main/Backmatter Dynamic Category Test"
echo "=========================================================="
echo ""

# Read the file line by line
while IFS= read -r line || [[ -n "$line" ]]; do

    # 1. Trim whitespace
    declare file="${line##[[:space:]]##}"
    file="${file%%[[:space:]]##}"
    [[ -z "${file}" ]] && continue

    # 2. Skip filter
    if [[ "${file}" == "x" ]] || [[ "${file}" =~ ^x[[:space:]]+ ]]; then
        # Trim the 'x' out for a cleaner display
        declare clean_name="${file#x}"
        clean_name="${clean_name##[[:space:]]##}"
        echo "[SKIPPED]       $clean_name"
        continue
    fi

    # 3. Categorization logic using global pattern matches instead of rigid slicing
    if [[ "${file}" =~ "fm_[a-z]_" ]]; then
        echo "[FRONTMATTER]   $file"
    elif [[ "${file}" =~ "bm_[a-z]_" ]]; then
        echo "[BACKMATTER]    $file"
    else
        echo "[MAIN CONTENT]  $file"
    fi

done < "${arg_markdown_file}"
