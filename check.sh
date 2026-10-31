#!/bin/bash
# 供 bin/proj-index --audit 调用：确认 fdroidclient 的自用补丁没有在上游更新中丢失。
set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
exec "$HERE/apply-patches.sh" check
