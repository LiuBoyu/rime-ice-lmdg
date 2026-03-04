# rime-ice-lmdg

个人定制版雾凇拼音（Rime，全拼优先）。

仅保留核心目标：

- 长句更顺，减少选词
- 强化学习与联想
- 在雾凇基础上按需挂载 LMDG 词库（低冲击策略）
- 优先用 `*.custom.yaml` 定制，尽量不改上游原文件

当前主要配置：

- `default.custom.yaml`
- `rime_ice.custom.yaml`
- `squirrel.custom.yaml`

LMDG（万象词库）简要说明：

- 基于大规模中文语料构建的词库体系，强调词频、拼音标注与长词覆盖
- 本项目将其作为雾凇词库的补充，按需低冲击挂载，不强制启用
- 项目地址：<https://github.com/amzxyz/RIME-LMDG>

LMDG 相关文件：

- `rime_ice_lmdg.dict.yaml`（雾凇 + LMDG 聚合词典入口）
- `cn_dicts/lmdg/`（LMDG 分词库）
- `repos/sync_lmdg.sh`（同步辅助脚本，非必须）

雾凇原始 README：<https://github.com/iDvel/rime-ice/blob/main/README.md>

## 部署到鼠须管（可直接复制执行）

在本仓库根目录执行：

```bash
# 1) 备份当前 Rime（强烈建议）
mkdir -p "$HOME/Library/Rime.backup.$(date +%Y%m%d-%H%M%S)"
rsync -a "$HOME/Library/Rime/" "$HOME/Library/Rime.backup.$(date +%Y%m%d-%H%M%S)/"

# 2) 清空 Rime 目录
rm -rf "$HOME/Library/Rime"
mkdir -p "$HOME/Library/Rime"

# 3) 从本仓库重新同步最小可用配置（含 LMDG 入口）
rsync -a \
  default.yaml default.custom.yaml \
  rime_ice.schema.yaml rime_ice.dict.yaml rime_ice_lmdg.dict.yaml rime_ice.custom.yaml \
  melt_eng.schema.yaml melt_eng.dict.yaml \
  radical_pinyin.schema.yaml radical_pinyin.dict.yaml \
  symbols_v.yaml custom_phrase.txt \
  squirrel.yaml squirrel.custom.yaml \
  cn_dicts en_dicts lua opencc \
  "$HOME/Library/Rime/"
```

如果你只想部署雾凇原词库（不带 LMDG），可删掉上面命令中的 `rime_ice_lmdg.dict.yaml`，并确保 `rime_ice.custom.yaml` 里 `translator/dictionary` 为 `rime_ice`。

然后在鼠须管里点击“重新部署”。

## 同步 LMDG 词库

`sync_lmdg.sh` 仅作为支撑性辅助工具：

- 用于从 `repos/RIME-LMDG` 同步/更新词库文件
- 不影响你手动维护词库与配置

推荐流程：

1. 将 `RIME-LMDG` 放到 `repos/` 目录（脚本也会在缺失时自动 clone）
2. 运行 `repos/sync_lmdg.sh` 更新 `cn_dicts/lmdg/` 分词库
3. 手动维护 `rime_ice_lmdg.dict.yaml`（按你的策略开关）
4. 手动决定是否切换 `translator/dictionary: rime_ice_lmdg`

使用脚本：`repos/sync_lmdg.sh`

```bash
# 首次（可选）：手动克隆到 repos 目录
git clone https://github.com/amzxyz/RIME-LMDG.git repos/RIME-LMDG

# 给脚本执行权限（首次）
chmod +x repos/sync_lmdg.sh

# 同步最新版本（core：jichu/duoyin/lianxiang/cuoyin）
./repos/sync_lmdg.sh

# 同步指定版本（tag/branch/commit）
./repos/sync_lmdg.sh --version <ref>

# 同步更多词库（core + renming/diming/shici/wuzhong）
./repos/sync_lmdg.sh --profile all
```

脚本特性：

- 中文日志与中文注释
- 若 `repos/RIME-LMDG` 不存在，会自动 clone
- 直接覆盖更新 `cn_dicts/lmdg/`（不创建临时目录和备份目录）
- 仅负责同步词库文件，不改词典入口策略
