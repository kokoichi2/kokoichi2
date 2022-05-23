#!/bin/bash

# tests
# $ echo date -d \'2022-04-03 +3 days\' \'+%Y-%m-%d\' | bash
#  > 2022-04-06

git config user.name kokoichi2
git config user.email kokoichi.64a@gmail.com

# 基準点
START_DAY="2022-04-03"

# if the system clock is set to the UTC, +9 hours
TODAY="$(date -d 'now +9 hours' '+%Y-%m-%d')"
FILE_PATH="auto-commit/strings.txt"
LOG_PATH="logs/auto-commits.txt"

echo "today: ${TODAY}"
# should_commit="false"
col=0
while read -r line
do
    ARR=(${line/// })
    
    count=0
    while [ "$count" -lt "${#line}" ]; do
        
        diff="$((count * 7 + col))"
        target_date="$(echo date -d \'${START_DAY} +${diff} days\' \'+%Y-%m-%d\' | bash)"
        if [[ "${target_date}" == "${TODAY}" ]]; then
            echo "FOUND target date: ${target_date}"
            target="${line:$count:1}"
            if [[ "$target" == "*" ]]; then
                echo "DO today's commit"
                echo "${diff}"
                # ==== commit start =====
                date >> "${LOG_PATH}"
                git add .
                git commit -m "Update"
                git push
                # ==== commit end =====
            fi
        fi
        ((count++))
    done

    # 行数を１増やす
    ((col++))

done < "$FILE_PATH"

