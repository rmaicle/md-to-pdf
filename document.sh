#!/usr/bin/env bash



init_document_vars() {
    # Used as paper arguments to script
    declare -g -r ARG_PAPER_A4="a4"
    declare -g -r ARG_PAPER_USLETTER="usletter"

    # Used to check paper size arguments to script
    declare -g -r -a ARG_PAPER_SIZES=(
        ${ARG_PAPER_A4}
        ${ARG_PAPER_USLETTER}
    )

    # Used as font size arguments to script
    declare -g -r ARG_FONT_SIZE_10PT="10"
    declare -g -r ARG_FONT_SIZE_11PT="11"
    declare -g -r ARG_FONT_SIZE_12PT="12"

    # Used to check font size arguments to script
    declare -g -r -a ARG_FONT_SIZES=(
        ${ARG_FONT_SIZE_10PT}
        ${ARG_FONT_SIZE_11PT}
        ${ARG_FONT_SIZE_12PT}
    )

    # Actual values passed to pandoc
    declare -g -r PAPER_A4="a4paper"
    declare -g -r PAPER_US_LETTER="letterpaper"

    declare -g -r FONT_SIZE_10PT="10pt"
    declare -g -r FONT_SIZE_11PT="11pt"
    declare -g -r FONT_SIZE_12PT="12pt"
}
