# rime-ice-lmdg

个人定制版雾凇拼音（Rime，全拼优先）。

仅保留核心目标：

- 长句更顺，减少选词
- 强化学习与联想
- 优先用 `*.custom.yaml` 定制，尽量不改上游原文件

当前主要配置：

- `default.custom.yaml`
- `rime_ice.custom.yaml`
- `squirrel.custom.yaml`

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

# 3) 从本仓库重新同步最小可用配置
rsync -a \
  default.yaml default.custom.yaml \
  rime_ice.schema.yaml rime_ice.dict.yaml rime_ice.custom.yaml \
  melt_eng.schema.yaml melt_eng.dict.yaml \
  radical_pinyin.schema.yaml radical_pinyin.dict.yaml \
  symbols_v.yaml custom_phrase.txt \
  squirrel.yaml squirrel.custom.yaml \
  cn_dicts en_dicts lua opencc \
  "$HOME/Library/Rime/"
```

然后在鼠须管里点击“重新部署”。
