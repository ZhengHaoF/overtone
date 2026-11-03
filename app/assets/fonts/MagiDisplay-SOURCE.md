# MagiDisplay-Heavy.otf 来源说明

- **字体**：築豊初号明朝OFL（Tsukuhou Shogo Mincho OFL）
- **作者**：文字魚│Typographish（いおせ）
- **官方发布页**：https://typographish.booth.pm/items/6419033
- **许可证**：SIL Open Font License 1.1（原文见同目录 `OFL-TsukuhouShogoMincho.txt`）
- **发布版本**：1.002（2024/12/25 公开，2025/01/05 与 2025/07/29 修订）
- **构成说明**：假名基于「築豊初号見出しかな」优化；汉字为源流明朝 2.100（源ノ明朝派生）经角立て处理。
- **本项目内的文件**：`MagiDisplay-Heavy.otf` 是官方 OTF 经 pyftsubset 裁剪出的子集，仅含 MAGI 皮肤固定文案所需的 21 个字形（`泛音第壱弐参肆伍陆柒捌玖零拾探` + `0-9` + `.` `:` `-`），保留原字体的版权与许可信息（`--name-IDs='*'`）。实测 `usWeightClass=900`、`fsType=0`（可嵌入）。
- **用途边界**：仅限 `MagiDisplayText(matisse: true)` 的固定文案；新增文案必须先扩展子集字符集，否则字形会回落到 `OvertoneSerif`。
