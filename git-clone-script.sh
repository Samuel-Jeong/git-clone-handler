#!/bin/bash

# 입력된 경로가 디렉토리인지 확인하고 경로를 설정합니다.
clone_path="$1"
if [ -z "$clone_path" ]; then
    echo "Usage: $0 <directory_path>"
    exit 1
fi

if [ ! -d "$clone_path" ]; then
    echo "Invalid directory path."
    exit 1
fi

cd "$clone_path" || exit 1

# GitHub 사용자 이름
github_username="abc"

# GitHub 액세스 토큰 (프라이빗 레포지토리에 접근하기 위해 필요합니다)
github_access_token="abc"

# GitHub API를 사용하여 사용자가 소유한 모든 레포지토리 목록 가져오기
repos_url="https://api.github.com/users/$github_username/repos?per_page=100"
page=1
while true; do
    repos=$(curl -s -H "Authorization: token $github_access_token" "$repos_url&page=$page" | grep -o '"clone_url": "[^"]*' | cut -d'"' -f4)

    # 가져온 레포지토리가 없으면 반복문 종료
    if [ -z "$repos" ]; then
        break
    fi

    # 모든 레포지토리를 클론
    for repo_url in $repos; do
        repo_name=$(echo "$repo_url" | awk -F'/' '{print $NF}' | cut -d'.' -f1)
        echo "Cloning $repo_name..."
        git clone "$repo_url"
    done

    ((page++))
done

echo "All repositories cloned successfully."
