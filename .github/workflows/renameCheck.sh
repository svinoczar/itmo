#!/bin/bash

orgName=$1
headerPrefix="^$2 "
oldHeaders=".github/workflows/headers.txt"
gitmodules=".gitmodules"
repoRegex="s[0-9]-[a-zA-Z0-9]{1,}-[a-zA-Z0-9]{1,}"


touch readmeDirs.tmp
touch submoduleDirs.tmp

cat README.md | while read readmeLine; do
    # echo $readmeLine
    regexContainsRepo="\(https:\/\/github\.com\/${orgName}\/[a-zA-Z0-9\-]{1,}(\/tree\/main)?\)"
    if [[ "$readmeLine" =~ ^$headerPrefix ]]; then  # if starts with headerPrefix
        header=$(./.github/workflows/formatHeader.sh "$readmeLine")
    fi
    link=$(echo "$readmeLine" | grep -i -o -P "$regexContainsRepo")
    if ! [ -z "$link" ]; then  # if has a repo in it
        fullRepo=$(echo $link | grep -i -o -P "$repoRegex")
        echo $fullRepo -\> $header >> readmeDirs.tmp
    fi
done

cat $gitmodules | while read moduleLine; do
    fullRepoGrep="(?<=url = https:\/\/github\.com\/${orgName}\/)[a-zA-Z0-9\-\.\/]+"
    fullRepo=$(echo $moduleLine | grep -i -o -P "$fullRepoGrep")

    if ! [ -z "$fullRepo" ]; then
        echo $fullRepo -\> $(cat header.tmp) >> submoduleDirs.tmp
    fi
    
    headerGrep="(?<=path = [0-9][a-zA-Z]{2}-semester\/)[a-zA-Z0-9\-\.]+"
    header=$(echo $moduleLine | grep -i -o -P "$headerGrep")
    echo $header > header.tmp
    
done

if [ -s "submoduleDirs.tmp" ]; then
    sort -o readmeDirs.tmp readmeDirs.tmp
    sort -o submoduleDirs.tmp submoduleDirs.tmp

    comm -23 submoduleDirs.tmp readmeDirs.tmp > oldDirs.tmp
    comm -13 submoduleDirs.tmp readmeDirs.tmp > newDirs.tmp

    # repoRegex="s[0-9]-[a-zA-Z0-9]{1,}-[a-zA-Z0-9]{1,}"
    firstOfTwoGrep="(?<=-> )[a-zA-Z0-9\-\.]+(?= ->)"
    lastGrep="(?<=-> )[a-zA-Z0-9\-\.]+$"


    # cat newDirs.tmp | while read line; do
    #     fullRepo=$(echo $line | grep -i -o -P "$repoRegex")
    #     semester=${fullRepo: 1:1}
    #     repo=$(echo $fullRepo | cut -d '-' -f 3)
    #     ordinals=$(case "$semester" in *1[0-9] | *[04-9]) echo th;; *1) echo st;; *2) echo nd;; *3) echo rd;; esac)
    #     semDirName="${semester}${ordinals}-semester"
        
        
    #     cat newDirs.tmp | while read oldLine; do
    #         oldRepo=$(echo $oldLine | grep -i -o -P "$repoRegex")
    #         if [ "$fullRepo" = "$oldRepo" ]; then
    #             echo $oldLine | grep -i -o -P "$lastGrep" > oldDir.tmp
    #             break
    #         fi
    #     done

    cat oldDirs.tmp | while read oldLine; do
        fullRepo=$(echo $oldLine | grep -i -o -P "$repoRegex")
        semester=${fullRepo: 1:1}
        repo=$(echo $fullRepo | cut -d '-' -f 3)
        ordinals=$(case "$semester" in *1[0-9] | *[04-9]) echo th;; *1) echo st;; *2) echo nd;; *3) echo rd;; esac)
        semDirName="${semester}${ordinals}-semester"
        
        echo true > deleted.tmp
        cat newDirs.tmp | while read line; do
            oldRepo=$(echo $line | grep -i -o -P "$repoRegex")
            echo $fullRepo > fullRepo.tmp 
            if [ "$fullRepo" = "$oldRepo" ]; then
                echo false > deleted.tmp
                echo $line | grep -i -o -P "$lastGrep" > newDir.tmp
                break
            fi
        done

        oldDirOnly=$(echo $oldLine | grep -i -o -P "$lastGrep")
        oldDir=${semDirName}/${oldDirOnly}
    
        submoduleName="${oldDir}/${repo}"

        # git submodule deinit $submoduleName

        git config -f .git/config --remove-section submodule.$submoduleName
        git config -f .gitmodules --remove-section submodule.$submoduleName

        git rm --cached -- $submoduleName
        rm -rf $submoduleName   
        rm -rf .git/modules/$submoduleName


        modulesDir=".git/modules/${oldDir}"
        if ! [ "$(ls -A $modulesDir)" ]; then
            rm -r $modulesDir
        fi

        echo deleted $submoduleName

        if ! [ -d $semDirName ]; then
            mkdir $semDirName 
        fi


        if [ "$(cat deleted.tmp)" = "false" ]; then

            newDirOnly=$(cat newDir.tmp)
            newDir=${semDirName}/${newDirOnly}
            echo $fullRepo -\> $oldDir -\> $newDir

            git submodule --quiet add -b main https://github.com/${orgName}/${fullRepo} ${newDir}/${repo}
            git submodule update --init --recursive
            git add .gitmodules
            git commit -am "moving ${fullRepo} submodule from ${oldDirOnly} to ${newDirOnly}"
        
        else
            git add .gitmodules
            git commit -am "removing ${fullRepo} submodule"
        fi

    done

fi

