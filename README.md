# 剧情图谱编辑器 (Story Graph Editor)

基于 **Godot 4** 的可视化剧情节点编辑器插件。旨在帮助开发者和剧情策划快速导入、预览、编辑并管理复杂的网状叙事结构。

## ✨ 核心功能

*   **可视化图谱 (Visual Graph)**：基于 Godot 原生的 `GraphEdit`，将线性的 JSON 剧本转化为直观的节点图。
*   **JSON 剧本导入**：通过原生 `EditorFileDialog` 导入外部 `.json` 剧本文件，支持过滤 BOM 并在导入时自动解析。
*   **丰富的节点类型**：支持多种预设节点类型，包括 `scene` (场景), `dialogue` (对话), `choice` (选项), `event` (事件), `condition` (条件分支), `end` (结局) 等，并在图谱中以不同颜色高亮区分。
*   **复杂逻辑解析**：强大的 JSON 解析器，支持读取并转换复杂的嵌套条件（如 `all`, `any`, `not`），物品/线索判断 (`item_owned`, `clue_owned`) 以及对应的各类事件副作用 (`effects`)。
*   **属性检查器 (Inspector)**：点击节点即可在右侧的 Inspector 面板中实时查看和修改节点的基础信息（ID、标题）以及核心剧情文本（Summary 和详细 Text）。
*   **侧边栏概览**：左侧边栏提供当前剧本的剧情节点、角色、变量和场景的快速概览列表。
*   **一键排版**：支持基础的拓扑排序，可以一键将混乱的节点图进行层级自动排版（也可直接继承 JSON 中的原始坐标）。

## 📂 目录结构

*   `addons/story_graph_editor/`：插件核心目录
    *   `importer/`：包含 `StoryJsonImporter`，负责将 JSON 文本反序列化为内部资源对象。
    *   `models/`：包含各类数据结构定义（如 `StoryAsset`, `StoryNode`, `StoryChoice`, `StoryEffect`, `StoryCondition` 等）。
    *   `ui/`：编辑器界面相关的 UI 场景与脚本（如图谱主视图、节点预制体、Inspector 面板等）。
    *   `plugin.gd` / `plugin.cfg`：Godot 插件入口配置文件。
*   `test_story.json`：随附的测试用长剧本（旧庄园失踪调查），包含丰富的逻辑跳转和嵌套条件，可用于直接导入测试。

## 🚀 如何使用

1.  将本项目下载或克隆到本地。
2.  使用 **Godot 4.3+** 打开项目。
3.  在引擎顶部菜单栏点击 **项目 (Project)** -> **项目设置 (Project Settings)** -> **插件 (Plugins)** 标签页。
4.  确保 **Story Graph Editor** 插件已勾选启用。
5.  在编辑器主界面顶部点击新出现的 **Story Graph** 工作区标签。
6.  点击工具栏的 **导入剧本** 按钮，选择项目根目录下的 `test_story.json` 即可体验图谱生成。

## ⚙️ 依赖环境
*   Godot Engine 4.3 或更高版本。
