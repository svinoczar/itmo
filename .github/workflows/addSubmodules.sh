#!/bin/bash

headerPrefix="^${1} "
orgName="${2}"

cat newRepos.tmp | while read line; do 
    if [ -z "$line" ]; then 
        echo line is empty!
    else 
        semester=${line: 1:1}
        repo=$(echo $line | cut -d '-' -f 3)
        ordinals=$(case "$semester" in *1[0-9] | *[04-9]) echo th;; *1) echo st;; *2) echo nd;; *3) echo rd;; esac)
        
        repoLine=$(grep -n "${line}" README.md | cut -d : -f 1) # on which line our repo is
        cat README.md | while read readmeLine; do
            if echo $readmeLine | grep -q -i -o -P "$headerPrefix"; then  # if starts with headerPrefix
                lastHeaderLine=$(grep -n "$readmeLine" README.md | cut -d : -f 1) # finding line
                lastHeader=${readmeLine}
                if [ "$lastHeaderLine" -gt "$repoLine" ]; then 
                    break # if current header is too far, then one before it is the header for the repo
                fi
                echo $lastHeader > header.tmp
            fi
        done
    fi
    header=$(./.github/workflows/formatHeader.sh "$(cat header.tmp)")
    git submodule add -b main https://github.com/${orgName}/${line} ${semester}${ordinals}-semester/${header}/${repo}
    git submodule update --init --recursive
    git add .gitmodules
    git commit -m "adding ${header}/${repo} as a submodule"
done
