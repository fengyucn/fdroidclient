#!/bin/bash
# fdroidclient 自用补丁：幂等检查/应用。上游换新 tag 后先 apply 再构建。
# 用法: projects/fdroidclient/apply-patches.sh check|apply
set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ACTION="${1:-check}"
SRC="$HERE"
PATCHES=("selfuse.patch")   # minSdk 36 + key.properties 签名 + dl.google.com 别名 + .gitignore

gitignore_ensure() {  # 幂等: 签名物料不入 git
    grep -q "^selfuse.jks$" "$SRC/.gitignore" 2>/dev/null || printf '\n# abuild: 本地签名物料不入库\nkey.properties\nselfuse.jks\nlocal.properties\nbuild-*.log\n' >> "$SRC/.gitignore"
}

patch_applied() {
    grep -q "abuild: 自用改装 Android 16+" "$SRC/app/build.gradle.kts" 2>/dev/null &&
        grep -q 'url .https://dl.google.com/dl/android/maven2/.' "$SRC/build.gradle" 2>/dev/null
}

case "$ACTION" in
    check)
        gitignore_ensure
        patch_applied && echo "[ok] fdroidclient selfuse.patch 已应用" || { echo "[fail] fdroidclient 补丁缺失"; exit 1; }
        ;;
    apply)
        gitignore_ensure
        for p in "${PATCHES[@]}"; do
            if patch -d "$SRC" -p1 -R --dry-run -s -f < "$HERE/patches/$p" >/dev/null 2>&1; then
                echo "[ok] $p 已应用"
            elif patch -d "$SRC" -p1 --dry-run -s -f < "$HERE/patches/$p" >/dev/null 2>&1; then
                patch -d "$SRC" -p1 -s -f < "$HERE/patches/$p" && echo "[ok] $p 应用"
            else
                echo "[fail] $p 无法干净应用（上游 build.gradle.kts 变了）— 手工合并后重新生成"; exit 1
            fi
        done
        ;;
    *) echo "用法: $0 check|apply"; exit 2 ;;
esac
