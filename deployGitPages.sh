#!/bin/bash

##########################################
# deployGitPages.sh
# deploy the git pages service script
# sed command in Mac, linux please delete the ""
# 2020-09-17
#########################################

GITHUB="anTtutu.github.io"
CODING="anttu.coding.me"
GITEE="anttu.gitee.io"

GITCODE_DIR="GitCode"
HUGO_BLOG_DIR="hugo_blog"
CONFIG_FILE_NAME="config.toml"

# deploy github
function hugoDeployGithub()
{
    # delete baseURL #
    sed -i "" '/^#.*baseURL/s/^#//g' ${CONFIG_FILE_NAME}

    # modify config.yml   github\coding\gitee
    sed -i "" '2,3s/^/#/g' ${CONFIG_FILE_NAME}

    gitAndhugo "$1" "$2"
}

# deploy coding me
function hugoDeployCoding()
{
    # delete baseURL #
    sed -i "" '/^#.*baseURL/s/^#//g' ${CONFIG_FILE_NAME}

    # modify config.yml   github\coding\gitee
    sed -i "" '1,1s/^/#/g' ${CONFIG_FILE_NAME}
    sed -i "" '3,3s/^/#/g' ${CONFIG_FILE_NAME}

    gitAndhugo "$1" "$2"
}

# deploy gitee
function hugoDeployGitee()
{
    # delete baseURL #
    sed -i "" '/^#.*baseURL/s/^#//g' ${CONFIG_FILE_NAME}

    # modify config.yml   github\coding\gitee
    sed -i "" '1,2s/^/#/g' ${CONFIG_FILE_NAME}

    gitAndhugo "$1" "$2"
}

# git and hugo command
function gitAndhugo()
{
    # hugo and copy public to project
    hugo
    cp -r ./public/*  ../${GITCODE_DIR}/$2/

    # git pull
    cd ../${GITCODE_DIR}/$2/
    git pull

    # git add
    git add .

    # git commit and push
    git commit -m "$1"
    git push

    # back to hugo dir
    cd ../../${HUGO_BLOG_DIR}/ 
}

# 二次确认
function checkYes()
{
    echo -n "are you sure to deploy hugo blog, please input y or Y :"
    read input
    
    if [ ${input} == "y" ] || [ ${input} == "Y" ]; then
        echo "begin to deploy..."	
    else
        echo "exit to this script. bye..."	
        exit 1
    fi
}

function main()
{
    # 检验入参，需要增加提交注释
    if [ -z "$1" ] ; then
        echo "please input commit message."
        exit 1;
    fi

    # 二次确认 
    checkYes

    # deploy github pages
    hugoDeployGithub "$1" "${GITHUB}"

    # deploy coding me pages
    hugoDeployCoding "$1" "${CODING}"

    # deploy gitee pages
    hugoDeployGitee "$1" "${GITEE}"
}

main $1
