#!/usr/bin/env bash
set -euo pipefail

# =========================================================
# 从 RIME-LMDG 同步词库到当前 rime-ice-lmdg 项目
# - 若不存在源码仓库，自动 clone 到 repos/RIME-LMDG
# - 同步到 cn_dicts/lmdg/
# - 支持 latest（默认 wanxiang 分支）或指定版本
# =========================================================

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd -P)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd -P)"

SOURCE_REPO="$ROOT_DIR/repos/RIME-LMDG"
TARGET_REPO="$ROOT_DIR"
REPO_URL="https://github.com/amzxyz/RIME-LMDG.git"
VERSION="latest"                 # latest 或 tag/branch/commit
LATEST_REF="origin/wanxiang"     # latest 对应的默认分支
PROFILE="core"                   # core | all
LMDG_DIR_REL="cn_dicts/lmdg"

usage() {
  cat <<'EOF'
用法：
  bash repos/sync_lmdg.sh [选项]

选项：
  --source-repo <路径>          RIME-LMDG 仓库路径（默认 ./repos/RIME-LMDG）
  --target-repo <路径>          目标仓库路径（默认当前项目根目录）
  --repo-url <地址>             自动 clone 时使用的仓库地址
  --version <ref|latest>        指定 tag/branch/commit 或 latest
  --latest-ref <ref>            latest 对应分支（默认 origin/wanxiang）
  --profile <core|all>          core=4个词库；all=增加人名/地名/诗词/物种
  -h, --help                    显示帮助
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --source-repo) SOURCE_REPO="${2:-}"; shift 2 ;;
    --target-repo) TARGET_REPO="${2:-}"; shift 2 ;;
    --repo-url) REPO_URL="${2:-}"; shift 2 ;;
    --version) VERSION="${2:-}"; shift 2 ;;
    --latest-ref) LATEST_REF="${2:-}"; shift 2 ;;
    --profile) PROFILE="${2:-}"; shift 2 ;;
    -h|--help) usage; exit 0 ;;
    *) echo "❌ 未知参数: $1"; usage; exit 1 ;;
  esac
done

abs_path() {
  local p="$1"
  (cd "$p" 2>/dev/null && pwd -P) || return 1
}

TARGET_REPO="$(abs_path "$TARGET_REPO")" || { echo "❌ 目标路径不可访问: $TARGET_REPO"; exit 1; }
[[ -d "$TARGET_REPO/.git" ]] || { echo "❌ 目标仓库不是 git 仓库: $TARGET_REPO"; exit 1; }

if [[ ! -d "$SOURCE_REPO/.git" ]]; then
  echo "==> 未发现 RIME-LMDG，本地自动克隆到: $SOURCE_REPO"
  mkdir -p "$(dirname "$SOURCE_REPO")"
  git clone "$REPO_URL" "$SOURCE_REPO"
fi

SOURCE_REPO="$(abs_path "$SOURCE_REPO")" || { echo "❌ 源路径不可访问: $SOURCE_REPO"; exit 1; }
[[ -d "$SOURCE_REPO/.git" ]] || { echo "❌ 源仓库不是 git 仓库: $SOURCE_REPO"; exit 1; }

CORE_FILES=(jichu duoyin lianxiang cuoyin)
EXTRA_FILES=(renming diming shici wuzhong)
FILES=()

if [[ "$PROFILE" == "core" ]]; then
  FILES=("${CORE_FILES[@]}")
elif [[ "$PROFILE" == "all" ]]; then
  FILES=("${CORE_FILES[@]}" "${EXTRA_FILES[@]}")
else
  echo "❌ --profile 仅支持 core 或 all"
  exit 1
fi

echo "==> 拉取源仓库版本信息..."
git -C "$SOURCE_REPO" fetch --tags --prune origin >/dev/null 2>&1 || true

if [[ "$VERSION" == "latest" ]]; then
  REF="$LATEST_REF"
else
  REF="$VERSION"
fi

git -C "$SOURCE_REPO" rev-parse --verify "$REF^{commit}" >/dev/null 2>&1 || {
  echo "❌ 找不到版本: $REF"
  exit 1
}

COMMIT="$(git -C "$SOURCE_REPO" rev-parse --short "$REF^{commit}")"

DST_LMDG="$TARGET_REPO/$LMDG_DIR_REL"

mkdir -p "$DST_LMDG"

echo "==> 源仓库:      $SOURCE_REPO"
echo "==> 目标仓库:    $TARGET_REPO"
echo "==> 同步版本:    $REF ($COMMIT)"
echo "==> 同步策略:    $PROFILE"
echo "⚠ 当前为直接覆盖模式：不创建临时目录，不自动备份"

echo "==> 开始同步词库到 $LMDG_DIR_REL ..."
for f in "${FILES[@]}"; do
  src_spec="$REF:dicts/$f.dict.yaml"
  dst_file="$DST_LMDG/lmdg_${f}.dict.yaml"

  if ! git -C "$SOURCE_REPO" cat-file -e "$src_spec" 2>/dev/null; then
    echo "❌ 源版本中不存在文件: dicts/$f.dict.yaml"
    exit 1
  fi

  git -C "$SOURCE_REPO" show "$src_spec" > "$dst_file"
  perl -0777 -i -pe "s/^name:\s*${f}\s*$/name: lmdg_${f}/m" "$dst_file"

  echo "  ✔ $LMDG_DIR_REL/lmdg_${f}.dict.yaml"
done

echo
echo "✅ 同步完成"
echo "   - 版本: $REF ($COMMIT)"
echo "   - 输出目录: $LMDG_DIR_REL"
echo "👉 下一步：在鼠须管执行「重新部署」"
