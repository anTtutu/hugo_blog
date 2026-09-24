#!/bin/bash -x

##########################################
# deployGitPages.sh
# deploy the git pages service script
# sed command in Mac, linux please delete the ""
# 2020-09-17
#########################################

GITHUB="anTtutu.github.io"
CODING="anttu.coding.me"
GITEE="anttu.gitee.io"

GITCODE_DIR="./"
HUGO_BLOG_DIR="hugo_blog"
CONFIG_FILE_NAME="config.toml"

# 锚定脚本所在目录（博客源码根目录），避免从其他目录启动时相对路径错乱
BLOG_DIR="$(cd "$(dirname "$0")" && pwd)"

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
# 参数: $1 = 提交注释, $2 = Pages 仓库目录名
function gitAndhugo()
{
    # Pages 仓库不存在时直接终止，避免后续 cp/cd 报一堆错
    if [ ! -d "${BLOG_DIR}/../${GITCODE_DIR}/$2" ]; then
        echo "pages repo directory not found: ${BLOG_DIR}/../${GITCODE_DIR}/$2"
        exit 1
    fi

    # 先拉取远端最新提交，避免本地覆盖文件后再 pull 产生冲突
    cd "${BLOG_DIR}/../${GITCODE_DIR}/$2/" || exit 1
    git pull

    # 回到源码目录，清理旧构建产物并重新构建（rm -rf 容忍 public 不存在，hugo 会重建）
    cd "${BLOG_DIR}" || exit 1
    rm -rf ./public
    hugo
    cp -r ./public/* ../${GITCODE_DIR}/$2/

    # git add / commit / push
    cd ../${GITCODE_DIR}/$2/ || exit 1
    git add .

    # 工作区无变更时不 commit，避免 "nothing to commit" 报错中断流程
    if ! git diff --cached --quiet; then
        git commit -m "$1"
        git push
    else
        echo "no changes to commit in $2, skip push."
    fi

    # 回到博客源码目录（用绝对路径，不再猜测相对层级）
    cd "${BLOG_DIR}" || exit 1
}

# 二次确认
function checkYes()
{
    echo -n "are you sure to deploy hugo blog, please input y or Y :"
    read input
    
    if [ "${input}" = "y" ] || [ "${input}" = "Y" ]; then
        echo "begin to deploy..."	
    else
        echo "exit to this script. bye..."	
        exit 1
    fi
}

# commit and push mine
function commitAndPushMine()
{
    git pull

    git add .

    git commit -m "$1"

    git push
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

    # 锚定到博客源码目录，保证 sed / git / hugo 都在正确目录执行
    cd "${BLOG_DIR}" || exit 1

    # commit and push
    commitAndPushMine "$1"

    # deploy github pages
    hugoDeployGithub "$1" "${GITHUB}"

    # deploy coding me pages
    #hugoDeployCoding "$1" "${CODING}"

    # deploy gitee pages
    #hugoDeployGitee "$1" "${GITEE}"
}

main "$1"
