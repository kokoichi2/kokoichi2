#!/bin/bash
set -euo pipefail

FILE_PATH="./strings.txt"
FILE_BASE_PATH="./grass_base.svg"
OUTPUT="grass_output.svg"
OUTPUT_COLOR="grass_output_color.svg"

function make_prefix() {
    cat "$FILE_BASE_PATH" > "$OUTPUT"
}

function make_one_row() {
    {
        # #1 translate 
        echo "<g transform=\"translate($(($1*14)), 0)\">"
        # #2-#7 data-level 
        echo "<rect width=\"10\" height=\"10\" x=\"12\" y=\"0\" rx=\"2\" ry=\"2\" data-level=\"$2\"></rect>"
        echo "<rect width=\"10\" height=\"10\" x=\"12\" y=\"13\" rx=\"2\" ry=\"2\" data-level=\"$3\"></rect>"
        echo "<rect width=\"10\" height=\"10\" x=\"12\" y=\"26\" rx=\"2\" ry=\"2\" data-level=\"$4\"></rect>"
        echo "<rect width=\"10\" height=\"10\" x=\"12\" y=\"39\" rx=\"2\" ry=\"2\" data-level=\"$5\"></rect>"
        echo "<rect width=\"10\" height=\"10\" x=\"12\" y=\"52\" rx=\"2\" ry=\"2\" data-level=\"$6\"></rect>"
        echo "<rect width=\"10\" height=\"10\" x=\"12\" y=\"65\" rx=\"2\" ry=\"2\" data-level=\"$7\"></rect>"
        echo "<rect width=\"10\" height=\"10\" x=\"12\" y=\"78\" rx=\"2\" ry=\"2\" data-level=\"$8\"></rect>"
        echo "</g>"
    } >> "$OUTPUT"
}

function make_svg_end() {
    echo "</g></svg>" >> "$OUTPUT"
}

make_prefix

days=()
while read -r line
do
    count=0
    echo "$line"
    tmp=""
    while [ "$count" -lt "${#line}" ]; do
        
        target="${line:$count:1}"
        if [ "$target" == "*" ]; then
            tmp+="1"
        else
            tmp+="0"
        fi

        count=$((count+1))
    done
    echo "$tmp"
    days+=("$tmp")

done < "$FILE_PATH"

row=0
echo "length: ${#days[0]}"
while [ "$row" -lt "${#days[0]}" ]; do
    make_one_row "$row" "${days[0]:$row:1}" "${days[1]:$row:1}" "${days[2]:$row:1}" "${days[3]:$row:1}" "${days[4]:$row:1}" "${days[5]:$row:1}" "${days[6]:$row:1}"
    row=$((row+1))
done

make_svg_end

# ========== color the svg file ==========
# create 5 colors using: https://colordesigner.io/gradient-generator
LEVEL0=" fill=\"rgb(244, 244, 244)\""
LEVEL1=" fill=\"rgb(36, 169, 49)\""

if [[ -f "${OUTPUT_COLOR}" ]]; then
    echo "${OUTPUT_COLOR} exists."
    rm "${OUTPUT_COLOR}"
    echo "Removed ${OUTPUT_COLOR}"
fi

# paint it
while read -r line
do
    if [[ "${line: -22}" == 'data-level="0"></rect>' ]]; then
        echo "$(echo ${line} | rev | cut -c 9- | rev)${LEVEL0}${line: -8}" >> "${OUTPUT_COLOR}"
    elif [[ "${line: -22}" == 'data-level="1"></rect>' ]]; then
        echo "$(echo ${line} | rev | cut -c 9- | rev)${LEVEL1}${line: -8}" >> "${OUTPUT_COLOR}"
    elif [[ "${line: -22}" == 'data-level="2"></rect>' ]]; then
        echo "$(echo ${line} | rev | cut -c 9- | rev)${LEVEL2}${line: -8}" >> "${OUTPUT_COLOR}"
    elif [[ "${line: -22}" == 'data-level="3"></rect>' ]]; then
        echo "$(echo ${line} | rev | cut -c 9- | rev)${LEVEL3}${line: -8}" >> "${OUTPUT_COLOR}"
    elif [[ "${line: -22}" == 'data-level="4"></rect>' ]]; then
        echo "$(echo ${line} | rev | cut -c 9- | rev)${LEVEL4}${line: -8}" >> "${OUTPUT_COLOR}"
    elif [[ "${line}" =~ .*(Sun|Mon|Tue|Wed|Thu|Fri|Sat).* ]]; then
        # 横の曜日は記載しない！
        echo "Skipped"
        # 必要なら付け加える
        # echo "${line}" >> "${OUTPUT_FILE}"
    else
        echo "${line}" >> "${OUTPUT_COLOR}"
    fi
done < "${OUTPUT}"
