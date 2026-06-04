# Index.ets 拆分 Agent 执行进展同步表

## 1. 文档用途

本文档用于配合 `Index拆分执行手册.md` 使用，作为 Agent 每次执行拆分任务后的进展同步文档。

Agent 每完成一次操作后，应及时更新本文档中的：

- 当前执行阶段；
- 当前执行步骤；
- 已完成内容；
- 新增/修改/删除文件；
- 编译与回归结果；
- 遇到的问题；
- 下一步计划。

本文档不替代执行手册，只记录实际执行进展。

---

## 2. 状态标记说明

| 标记 | 含义 |
|---|---|
| `[ ]` | 未开始 |
| `[-]` | 进行中 |
| `[x]` | 已完成 |
| `[!]` | 有阻塞或异常 |
| `[~]` | 已跳过或延后 |

---

## 3. 当前总进度快照

> Agent 每次执行后优先更新本节。

| 项目 | 当前状态 |
|---|---|
| 当前阶段 | 阶段 3：主页面展示区拆分 |
| 当前步骤 | 阶段 3 已完成主页头部、汇总区、打卡区与今日按钮组件拆分，待提交后进入阶段 4 |
| 当前分支 | `refactor/index-stage3-main-sections` |
| 最近一次执行时间 | 2026-06-04 15:55:00 |
| 最近一次执行人/Agent | OpenAI Codex Agent |
| 最近一次编译结果 | 成功（阶段 3 修改后执行构建验证通过） |
| 最近一次回归结果 | 已修复打卡时间不实时更新问题并完成编译级验证，未执行真机/手工页面交互回归 |
| 是否存在阻塞 | 否 |
| 阻塞摘要 | 无 |
| 下一步计划 | 提交阶段 3 代码后，进入阶段 4 拆分日历区域组件与日历计算 service |

---

## 4. 阶段总进度

| 执行顺序 | 阶段 | 名称 | 必做/可选 | 状态 | 最近更新时间 | 备注 |
|---|---|---|---|---|---|---|
| 1 | 阶段 0 | 准备阶段 | 必做 | `[x]` | 2026-06-03 12:40:48 | 已完成基线记录、目录创建、编译验证 |
| 2 | 阶段 1 | 常量与设置页拆分 | 必做 | `[x]` | 2026-06-03 13:05:00 | 已完成常量文件与设置页组件抽离，构建通过 |
| 3 | 阶段 2 | 弹窗拆分 | 必做 | `[x]` | 2026-06-04 15:20:00 | 已完成排除时段编辑弹窗与冲突提示弹窗抽离，构建通过 |
| 4 | 阶段 3 | 主页面展示区拆分 | 必做 | `[x]` | 2026-06-04 15:55:00 | 已完成主页展示区抽离，并修复打卡时间实时更新问题，构建通过 |
| 5 | 阶段 4 | 日历区域拆分 | 必做 | `[ ]` |  |  |
| 6 | 阶段 5 | 导入导出与持久化 service 化 | 必做 | `[ ]` |  |  |
| 7 | 阶段 8 | 收尾优化 | 必做 | `[ ]` |  |  |
| 8 | 阶段 6 | 设置页页面化 | 可选 | `[ ]` |  |  |
| 9 | 阶段 7 | ViewModel 收敛 | 可选 | `[ ]` |  |  |

---

## 5. 阶段 0：准备阶段进展

### 5.1 阶段状态

| 项目 | 内容 |
|---|---|
| 阶段状态 | `[x]` |
| 目标分支 | `refactor/index-stage0-prepare` |
| 开始时间 | 2026-06-03 11:57:00 |
| 完成时间 | 2026-06-03 12:40:48 |
| 编译结果 | 成功（新增目录及占位文件后构建通过） |
| 回归结果 | 已建立回归清单，待后续阶段按清单执行 |
| 是否允许进入下一阶段 | 是 |

### 5.2 步骤进度

| 步骤 | 内容 | 状态 | 执行记录 |
|---|---|---|---|
| Step 1 | 确认工作区状态：执行 `git status` | `[x]` | 初始分支为 `refactoring`，工作区仅存在两份拆分说明文档未纳入版本控制。 |
| Step 2 | 创建/切换重构主分支 `refactor/index-split` | `[x]` | 已创建并切换到 `refactor/index-split`。 |
| Step 3 | 记录 `Index.ets` 行数 | `[x]` | `main/src/main/ets/pages/Index.ets` 当前共 2379 行。 |
| Step 4 | 记录当前主要功能列表 | `[x]` | 已根据 `Index.ets` 状态变量与页面结构记录：主页展示、日历展开/折叠、打卡记录、设置页、排除时段、目标工时、深色模式、导入导出与清空。 |
| Step 5 | 记录当前已知问题 | `[x]` | 当前未发现新增问题；保留“单文件体量大、需按阶段拆分”为本次重构背景问题。 |
| Step 6 | 记录当前编译结果 | `[x]` | 准备阶段执行前基线信息已补充，阶段末执行构建验证成功。 |
| Step 7 | 创建 `components/index` 目录 | `[x]` | 已创建，并新增 `.gitkeep` 占位文件。 |
| Step 8 | 创建 `components/dialogs` 目录 | `[x]` | 已创建，并新增 `.gitkeep` 占位文件。 |
| Step 9 | 创建 `constants` 目录 | `[x]` | 已创建，并新增 `.gitkeep` 占位文件。 |
| Step 10 | 创建 `service` 目录 | `[x]` | 目录原已存在，无需新增，保留现状。 |
| Step 11 | 创建 `utils` 目录 | `[x]` | 已创建，并新增 `.gitkeep` 占位文件。 |
| Step 12 | 创建 `viewmodel` 目录 | `[x]` | 已创建，并新增 `.gitkeep` 占位文件。 |
| Step 13 | 整理回归测试清单 | `[x]` | 已整理为：应用启动、主页展示、日历展开折叠切换、打卡/编辑/删除、设置页开关、上班时间、排除时段、目标工时、深色模式、导入/导出/清空数据。 |
| Step 14 | 执行阶段编译验证 | `[x]` | `builtin_execute_build_command` 返回 Build success。 |
| Step 15 | 提交阶段代码 | `[~]` | 本次未执行 git commit，待用户确认或后续统一提交。 |

### 5.3 文件变更记录

| 类型 | 文件/目录 | 说明 |
|---|---|---|
| 新增 | `main/src/main/ets/components/index/.gitkeep` | 为后续首页组件拆分预留目录并确保可纳入版本控制 |
| 新增 | `main/src/main/ets/components/dialogs/.gitkeep` | 为后续弹窗组件拆分预留目录并确保可纳入版本控制 |
| 新增 | `main/src/main/ets/constants/.gitkeep` | 为后续常量抽离预留目录并确保可纳入版本控制 |
| 新增 | `main/src/main/ets/utils/.gitkeep` | 为后续工具方法抽离预留目录并确保可纳入版本控制 |
| 新增 | `main/src/main/ets/viewmodel/.gitkeep` | 为可选 ViewModel 收敛阶段预留目录并确保可纳入版本控制 |
| 修改 | `Index拆分Agent进展同步.md` | 同步阶段 0 的实际执行记录 |
| 删除 |  |  |

### 5.4 阶段问题记录

| 问题 | 影响 | 处理结果 |
|---|---|---|
| 阶段 0 目录创建中 `main/src/main/ets/service` 已预先存在 | 不影响继续执行 | 保持现有目录不变，未重复创建，记录为基线现状 |
| 执行手册与进展同步文档尚未纳入版本控制 | 不影响本阶段实施 | 本次已在阶段记录中说明，待后续按用户要求统一提交 |

---

## 6. 阶段 1：常量与设置页拆分进展

### 6.1 阶段状态

| 项目 | 内容 |
|---|---|
| 阶段状态 | `[x]` |
| 目标分支 | `refactor/index-stage1-settings` |
| 开始时间 | 2026-06-03 12:44:00 |
| 完成时间 | 2026-06-03 13:05:00 |
| 编译结果 | 成功（`builtin_execute_build_command` 返回 Build success） |
| 回归结果 | 已完成编译级验证；设置页打开/交互的手工回归待后续统一执行 |
| 是否允许进入下一阶段 | 是 |

### 6.2 步骤进度

| 步骤 | 内容 | 状态 | 执行记录 |
|---|---|---|---|
| Step 1 | 创建/切换阶段分支 | `[x]` | 已从 `refactor/index-stage0-prepare` 切换并创建 `refactor/index-stage1-settings`。 |
| Step 2 | 新建 `constants/IndexConstants.ets` | `[x]` | 已新增常量文件，抽离节假日、周标题与默认值。 |
| Step 3 | 提取 `HOLIDAYS_2026` | `[x]` | 已迁移至 `IndexConstants.ets`，页面改为常量引用。 |
| Step 4 | 提取 `WEEKDAY_NAMES` | `[x]` | 已迁移至 `IndexConstants.ets`，周标题与日期文案改为常量引用。 |
| Step 5 | 提取 `DEFAULT_TARGET_HOURS` | `[x]` | 已迁移至 `IndexConstants.ets`，状态初始值改为常量。 |
| Step 6 | 提取 `DEFAULT_WORKDAY_START` | `[x]` | 已迁移至 `IndexConstants.ets`，状态初始值改为常量。 |
| Step 7 | 提取 `DEFAULT_RANGE_START` | `[x]` | 已迁移至 `IndexConstants.ets`，新增排除时段默认起始时间改为常量。 |
| Step 8 | 提取 `DEFAULT_RANGE_END` | `[x]` | 已迁移至 `IndexConstants.ets`，新增排除时段默认结束时间改为常量。 |
| Step 9 | 替换 `Index.ets` 中对应常量引用 | `[x]` | 已完成设置页与节假日/星期文案相关替换。 |
| Step 10 | 新建 `SettingsHeader.ets` | `[x]` | 已新增设置页头部组件。 |
| Step 11 | 接入 `SettingsHeader` | `[x]` | 已在 `buildSettingsPage()` 中替换为组件调用。 |
| Step 12 | 新建 `WorkdayStartCard.ets` | `[x]` | 已新增工时开始时间卡片组件。 |
| Step 13 | 接入 `WorkdayStartCard` | `[x]` | 已通过回调方式接入原有时间选择逻辑。 |
| Step 14 | 新建 `ExcludedRangesCard.ets` | `[x]` | 已新增排除时段卡片组件。 |
| Step 15 | 接入 `ExcludedRangesCard` | `[x]` | 已通过回调承接新增、编辑、删除确认与状态重置逻辑。 |
| Step 16 | 新建 `TargetHoursCard.ets` | `[x]` | 已新增目标工时卡片组件。 |
| Step 17 | 接入 `TargetHoursCard` | `[x]` | 已通过 `onChange` 承接原滑块修改逻辑。 |
| Step 18 | 新建 `DarkModeCard.ets` | `[x]` | 已新增深色模式卡片组件。 |
| Step 19 | 接入 `DarkModeCard` | `[x]` | 已通过 `onToggle` 承接原开关逻辑。 |
| Step 20 | 新建 `DataManagementCard.ets` | `[x]` | 已新增数据管理卡片组件。 |
| Step 21 | 接入 `DataManagementCard` | `[x]` | 已通过回调承接导出、导入、清空操作。 |
| Step 22 | 保持设置页覆盖层展示方式不变 | `[x]` | 设置页仍以原覆盖层方式展示，仅替换内部卡片结构。 |
| Step 23 | 执行设置页功能回归 | `[~]` | 已完成编译级验证，未执行真机/手工交互回归。 |
| Step 24 | 执行阶段编译验证 | `[x]` | 构建成功。 |
| Step 25 | 提交阶段代码 | `[~]` | 按当前协作方式暂未执行 git commit。 |

### 6.3 文件变更记录

| 类型 | 文件 | 说明 |
|---|---|---|
| 新增 | `main/src/main/ets/constants/IndexConstants.ets` | 抽离 2026 节假日、星期文案与设置页默认值 |
| 新增 | `main/src/main/ets/components/index/SettingsHeader.ets` | 设置页头部组件 |
| 新增 | `main/src/main/ets/components/index/WorkdayStartCard.ets` | 工时开始时间设置卡片 |
| 新增 | `main/src/main/ets/components/index/ExcludedRangesCard.ets` | 排除时段列表与操作卡片 |
| 新增 | `main/src/main/ets/components/index/TargetHoursCard.ets` | 目标平均工时设置卡片 |
| 新增 | `main/src/main/ets/components/index/DarkModeCard.ets` | 深色模式设置卡片 |
| 新增 | `main/src/main/ets/components/index/DataManagementCard.ets` | 导入导出与清空数据卡片 |
| 修改 | `main/src/main/ets/pages/Index.ets` | 接入新常量与设置页组件，保留原覆盖层和业务逻辑 |

### 6.4 回归记录

| 验证项 | 状态 | 备注 |
|---|---|---|
| 设置页可以正常打开 | `[~]` | 未做手工回归，结构替换后编译通过 |
| 返回按钮可关闭设置页 | `[~]` | 未做手工回归，保留原回调逻辑 |
| 上班时间设置正常 | `[~]` | 未做手工回归，逻辑已透传至原方法 |
| 排除时段增删改正常 | `[~]` | 未做手工回归，逻辑已透传至原方法 |
| 目标工时修改正常 | `[~]` | 未做手工回归，逻辑已透传至原方法 |
| 深色模式切换正常 | `[~]` | 未做手工回归，逻辑已透传至原方法 |
| 导入/导出/清空按钮可触发 | `[~]` | 未做手工回归，逻辑已透传至原方法 |
| 工程编译通过 | `[x]` | Build success |

### 6.5 阶段问题记录

| 问题 | 影响 | 处理结果 |
|---|---|---|
| `Index.ets` 中设置页卡片相关代码与页面主文件耦合较深 | 仅适合做最小改动拆分，不宜在本阶段继续下沉业务逻辑 | 采用“组件接收状态 + 回调透传原逻辑”的方式完成拆分，避免跨阶段调整 service 与弹窗 |
| `builtin_check_editor_errors` 对 `.key()` 标记出非单测可用错误 | 影响编译级校验判断 | 已移除差异文案 Text 上的 `.key()` 调用，复查后无编辑器错误 |

---

## 7. 阶段 2：弹窗拆分进展

### 7.1 阶段状态

| 项目 | 内容 |
|---|---|
| 阶段状态 | `[x]` |
| 目标分支 | `refactor/index-stage2-dialogs` |
| 开始时间 | 2026-06-04 15:05:00 |
| 完成时间 | 2026-06-04 15:20:00 |
| 编译结果 | 成功（`builtin_execute_build_command` 返回 Build success） |
| 回归结果 | 已完成编译级验证；弹窗打开、选择、保存、遮罩关闭的手工回归待后续统一执行 |
| 是否允许进入下一阶段 | 是 |

### 7.2 步骤进度

| 步骤 | 内容 | 状态 | 执行记录 |
|---|---|---|---|
| Step 1 | 创建/切换阶段分支 | `[x]` | 已从 `refactor/index-stage1-settings` 新建并切换到 `refactor/index-stage2-dialogs`。 |
| Step 2 | 新建 `RangeEditDialog.ets` | `[x]` | 已新增排除时段编辑弹窗组件。 |
| Step 3 | 提取排除时段编辑弹窗 UI | `[x]` | 已将 `Index.ets` 中内联编辑弹窗 UI 迁移到组件。 |
| Step 4 | 设计并接入编辑弹窗入参 | `[x]` | 已接入 `darkModeEnabled`、`editRangeIndex`、`rangeStartInput`、`rangeEndInput`。 |
| Step 5 | 设计并接入编辑弹窗回调 | `[x]` | 已接入 `onCancel`、`onConfirm`、`onPickStart`、`onPickEnd`，父页面保留原逻辑。 |
| Step 6 | 确认输入状态仍由父组件持有 | `[x]` | 输入状态仍由 `Index.ets` 的 `@State` 持有，弹窗只展示和触发回调。 |
| Step 7 | 新建 `RangeConflictDialog.ets` | `[x]` | 已新增冲突提示弹窗组件。 |
| Step 8 | 提取冲突提示弹窗 UI | `[x]` | 已将 `Index.ets` 中内联冲突提示 UI 迁移到组件。 |
| Step 9 | 接入冲突弹窗入参与回调 | `[x]` | 已接入 `darkModeEnabled`、`onClose`、`onConfirm`。 |
| Step 10 | 评估是否需要 `ConfirmClearDialog.ets` | `[~]` | 当前清空确认仍为系统弹窗/原逻辑，按手册默认延后，不在阶段 2 拆分。 |
| Step 11 | 如有必要，新增并接入 `ConfirmClearDialog.ets` | `[~]` | 本阶段不新增。 |
| Step 12 | 整理 `Index.ets` 中弹窗分支 | `[x]` | 已移除 `build()` 中弹窗内联 UI，改为调用 `buildDialogs()`。 |
| Step 13 | 收敛到 `buildDialogs()` 或等价方法 | `[x]` | 已新增 `buildDialogs()` 统一编排弹窗组件。 |
| Step 14 | 执行弹窗功能回归 | `[~]` | 已完成编译级验证，未执行真机/手工交互回归。 |
| Step 15 | 执行阶段编译验证 | `[x]` | 构建成功。 |
| Step 16 | 提交阶段代码 | `[~]` | 按当前协作方式暂未执行 git commit。 |

### 7.3 文件变更记录

| 类型 | 文件 | 说明 |
|---|---|---|
| 新增 | `main/src/main/ets/components/dialogs/RangeEditDialog.ets` | 排除时段新增/编辑弹窗组件 |
| 新增 | `main/src/main/ets/components/dialogs/RangeConflictDialog.ets` | 排除时段冲突提示弹窗组件 |
| 新增 | `main/src/main/ets/components/dialogs/ConfirmClearDialog.ets` | 可选，本阶段未新增 |
| 修改 | `main/src/main/ets/pages/Index.ets` | 接入弹窗组件，新增 `buildDialogs()`，保留校验和时间选择逻辑 |

### 7.4 回归记录

| 验证项 | 状态 | 备注 |
|---|---|---|
| 排除时段弹窗可打开 | `[~]` | 未做手工回归，组件接入后编译通过 |
| 开始时间选择可用 | `[~]` | 未做手工回归，回调透传至原 `openRangeTimePicker(true)` |
| 结束时间选择可用 | `[~]` | 未做手工回归，回调透传至原 `openRangeTimePicker(false)` |
| 保存行为正确 | `[~]` | 未做手工回归，回调透传至原 `confirmAddRange()` |
| 取消行为正确 | `[~]` | 未做手工回归，保留原关闭与重置编辑索引逻辑 |
| 冲突弹窗提示正常 | `[~]` | 未做手工回归，展示组件已接入原显示状态 |
| 遮罩关闭逻辑正常 | `[~]` | 未做手工回归，遮罩关闭回调已透传父页面状态更新 |
| 工程编译通过 | `[x]` | Build success |

### 8.5 阶段问题记录

| 问题 | 影响 | 处理结果 |
|---|---|---|
| `TodayTipButton` 使用 `onClick` 作为组件属性名时与 ArkUI `CustomComponent` 基类属性冲突 | 阶段构建失败一次 | 将对外回调属性改名为 `onTap`，重新执行构建后通过 |
| `PunchCardSection` 初版仅接收格式化后的 `startTimeText`、`endTimeText`、`selectedWorkMinutes`，打卡后子组件未稳定触发实时刷新 | 前端打卡时间不能实时更新 | 向组件补充传入 `selectedDateKey`、`records`、`workdayStartTime`、`excludedRanges`，组件内部基于最新记录重新计算展示时间和工时；构建验证通过 |
| 本阶段不拆日历区域，但“今日”按钮位于折叠日历标题区 | 今日按钮与日历卡片存在轻度耦合 | 仅抽离按钮 UI，缩放动画与 `jumpToToday()` 保持在父页面，日历卡片整体留待阶段 4 |

---

## 8. 阶段 3：主页面展示区拆分进展

### 8.1 阶段状态

| 项目 | 内容 |
|---|---|
| 阶段状态 | `[x]` |
| 目标分支 | `refactor/index-stage3-main-sections` |
| 开始时间 | 2026-06-04 15:24:00 |
| 完成时间 | 2026-06-04 15:45:00 |
| 编译结果 | 成功（`builtin_execute_build_command` 返回 Build success） |
| 回归结果 | 已完成编译级验证；主页显示、设置入口、打卡、编辑、删除、汇总与今日按钮手工回归待后续统一执行 |
| 是否允许进入下一阶段 | 是 |

### 8.2 步骤进度

| 步骤 | 内容 | 状态 | 执行记录 |
|---|---|---|---|
| Step 1 | 创建/切换阶段分支 | `[x]` | 已从 `refactor/index-stage2-dialogs` 新建并切换到 `refactor/index-stage3-main-sections`。 |
| Step 2 | 新建 `MainHeader.ets` | `[x]` | 已新增主页头部组件。 |
| Step 3 | 提取并接入主页标题组件 | `[x]` | 已将 `buildMainHeader()` 内联 UI 替换为 `MainHeader`，设置入口通过 `onOpenSettings` 回调透传。 |
| Step 4 | 新建 `SummaryCardsSection.ets` | `[x]` | 已新增汇总卡片区组件。 |
| Step 5 | 提取并接入汇总区容器 | `[x]` | 已将 `buildSummaryCards()` 内联 UI 替换为 `SummaryCardsSection`，汇总数据仍由父页面计算并传入。 |
| Step 6 | 确认 `ForEach` key 未被破坏 | `[x]` | `SummaryCardsSection` 保留 `item.title + '_' + summaryRefreshKey` 作为 key，刷新触发方式不变。 |
| Step 7 | 新建 `PunchCardSection.ets` | `[x]` | 已新增打卡区组件。 |
| Step 8 | 提取并接入打卡区组件 | `[x]` | 已将打卡卡片和时间卡片 UI 迁移至 `PunchCardSection`，打卡、编辑仍回调父页面原方法。 |
| Step 9 | 确认打卡动画状态仍稳定 | `[x]` | `punchCardScale`、`punchButtonGlow` 仍由父页面持有并传入组件，动画状态来源不变。 |
| Step 10 | 新建 `TodayTipButton.ets` | `[x]` | 已新增今日按钮组件；因组件属性名 `onClick` 与基类冲突，最终命名为 `onTap`。 |
| Step 11 | 提取并接入回到今天按钮 | `[x]` | 折叠日历标题区改为调用 `TodayTipButton`，缩放动画与 `jumpToToday()` 仍由父页面处理。 |
| Step 12 | 重组首页布局为组件组合结构 | `[x]` | 主页现由 `MainHeader`、阶段 4 待拆的日历卡片、`PunchCardSection`、`SummaryCardsSection` 组合。 |
| Step 13 | 执行主页功能回归 | `[~]` | 已完成编译级验证，未执行真机/手工交互回归。 |
| Step 14 | 执行阶段编译验证 | `[x]` | 构建成功。 |
| Step 15 | 提交阶段代码 | `[~]` | 按当前协作方式暂未执行 git commit。 |

### 8.3 文件变更记录

| 类型 | 文件 | 说明 |
|---|---|---|
| 新增 | `main/src/main/ets/components/index/MainHeader.ets` | 主页标题、选中日期描述与设置入口组件 |
| 新增 | `main/src/main/ets/components/index/SummaryCardsSection.ets` | 目标/当前平均工时与差异文案汇总区组件 |
| 新增 | `main/src/main/ets/components/index/PunchCardSection.ets` | 当前日期、工时、上下班打卡时间与立即打卡按钮组件 |
| 新增 | `main/src/main/ets/components/index/TodayTipButton.ets` | 折叠日历标题区的“今日”按钮组件 |
| 修改 | `main/src/main/ets/pages/Index.ets` | 接入主页展示区组件，保留业务逻辑、动画状态与日历区域实现 |
| 修改 | `Index拆分Agent进展同步.md` | 同步阶段 3 的实际执行记录 |

### 8.4 回归记录

| 验证项 | 状态 | 备注 |
|---|---|---|
| 主页正常显示 | `[~]` | 未做手工回归，结构替换后编译通过 |
| 设置按钮正常 | `[~]` | 未做手工回归，`onOpenSettings` 透传原状态修改逻辑 |
| 打卡功能正常 | `[~]` | 未做手工回归，`onPunch` 透传至原 `handlePunchNow()` |
| 打卡编辑/删除正常 | `[~]` | 未做手工回归，上下班时间卡片编辑透传至原 `openTimePicker(field)`；删除逻辑未在本阶段改动 |
| 汇总卡片数据正确 | `[~]` | 未做手工回归，汇总计算仍由 `Index.ets` 原方法完成并传入组件 |
| 回到今天按钮行为正确 | `[~]` | 未做手工回归，缩放动画和 `jumpToToday()` 仍由父页面执行 |
| 工程编译通过 | `[x]` | Build success |

---

## 9. 阶段 4：日历区域拆分进展

### 9.1 阶段状态

| 项目 | 内容 |
|---|---|
| 阶段状态 | `[ ]` |
| 目标分支 | `refactor/index-stage4-calendar` |
| 开始时间 |  |
| 完成时间 |  |
| 编译结果 | 未执行 |
| 回归结果 | 未执行 |
| 是否允许进入下一阶段 | 未确认 |

### 9.2 步骤进度

| 步骤 | 内容 | 状态 | 执行记录 |
|---|---|---|---|
| Step 1 | 创建/切换阶段分支 | `[ ]` |  |
| Step 2 | 新建 `CalendarCard.ets` | `[ ]` |  |
| Step 3 | 提取折叠态日历 UI | `[ ]` |  |
| Step 4 | 接入折叠态日历入参和回调 | `[ ]` |  |
| Step 5 | 新建 `ExpandedCalendarPanel.ets` | `[ ]` |  |
| Step 6 | 提取展开态日历覆盖层 UI | `[ ]` |  |
| Step 7 | 接入展开态日历入参和回调 | `[ ]` |  |
| Step 8 | 评估是否需要 `DayCell.ets` | `[ ]` |  |
| Step 9 | 如有必要，新增并接入 `DayCell.ets` | `[~]` | 默认按复杂度决定 |
| Step 10 | 新建 `IndexCalendarService.ets` | `[ ]` |  |
| Step 11 | 提取 `buildMonthSlots()` | `[ ]` |  |
| Step 12 | 提取 `getCurrentWeekSlots()` | `[ ]` |  |
| Step 13 | 提取 `getExpandedCalendarRows()` | `[ ]` |  |
| Step 14 | 提取 `getDayCellColor()` | `[ ]` |  |
| Step 15 | 确认 service 不直接修改页面状态 | `[ ]` |  |
| Step 16 | 页面接入日历 service | `[ ]` |  |
| Step 17 | 执行日历功能回归 | `[ ]` |  |
| Step 18 | 执行阶段编译验证 | `[ ]` |  |
| Step 19 | 提交阶段代码 | `[ ]` |  |

### 9.3 文件变更记录

| 类型 | 文件 | 说明 |
|---|---|---|
| 新增 | `main/src/main/ets/components/index/CalendarCard.ets` |  |
| 新增 | `main/src/main/ets/components/index/ExpandedCalendarPanel.ets` |  |
| 新增 | `main/src/main/ets/components/index/DayCell.ets` | 可选 |
| 新增 | `main/src/main/ets/service/IndexCalendarService.ets` |  |
| 修改 | `main/src/main/ets/pages/Index.ets` |  |

### 9.4 回归记录

| 验证项 | 状态 | 备注 |
|---|---|---|
| 折叠态日历显示正常 | `[ ]` |  |
| 展开态日历显示正常 | `[ ]` |  |
| 日期切换正常 | `[ ]` |  |
| 周切换正常 | `[ ]` |  |
| 月切换正常 | `[ ]` |  |
| 选中日期高亮正确 | `[ ]` |  |
| 节假日/工作日/排除时段显示正确 | `[ ]` |  |
| 工程编译通过 | `[ ]` |  |

---

## 10. 阶段 5：导入导出与持久化 service 化进展

### 10.1 阶段状态

| 项目 | 内容 |
|---|---|
| 阶段状态 | `[ ]` |
| 目标分支 | `refactor/index-stage5-services` |
| 开始时间 |  |
| 完成时间 |  |
| 编译结果 | 未执行 |
| 回归结果 | 未执行 |
| 是否允许进入下一阶段 | 未确认 |

### 10.2 步骤进度

| 步骤 | 内容 | 状态 | 执行记录 |
|---|---|---|---|
| Step 1 | 创建/切换阶段分支 | `[ ]` |  |
| Step 2 | 梳理 `Index.ets` 中导入导出函数 | `[ ]` |  |
| Step 3 | 梳理 `Index.ets` 中 preferences 读写函数 | `[ ]` |  |
| Step 4 | 新建 `IndexImportExportService.ets` | `[ ]` |  |
| Step 5 | 提取 CSV 文本生成逻辑 | `[ ]` |  |
| Step 6 | 提取 CSV 解析逻辑 | `[ ]` |  |
| Step 7 | 提取 ZIP 打包逻辑 | `[ ]` |  |
| Step 8 | 提取 ZIP 解包逻辑 | `[ ]` |  |
| Step 9 | 提取导入合并逻辑 | `[ ]` |  |
| Step 10 | 提取临时文件清理逻辑 | `[ ]` |  |
| Step 11 | 评估是否需要 `CsvUtils.ets` | `[ ]` |  |
| Step 12 | 如有必要，新增并接入 `CsvUtils.ets` | `[~]` | 默认按复杂度决定 |
| Step 13 | 新建 `IndexPreferencesService.ets` | `[ ]` |  |
| Step 14 | 收敛 preferences key | `[ ]` |  |
| Step 15 | 提取加载状态接口 | `[ ]` |  |
| Step 16 | 提取保存状态接口 | `[ ]` |  |
| Step 17 | 重构 `initializeData()` | `[ ]` |  |
| Step 18 | 页面保留 toast/dialog/loading UI 反馈 | `[ ]` |  |
| Step 19 | 检查 `module.json5` 权限/文件访问配置 | `[ ]` |  |
| Step 20 | 执行数据功能回归 | `[ ]` |  |
| Step 21 | 执行阶段编译验证 | `[ ]` |  |
| Step 22 | 提交阶段代码 | `[ ]` |  |

### 10.3 文件变更记录

| 类型 | 文件 | 说明 |
|---|---|---|
| 新增 | `main/src/main/ets/service/IndexImportExportService.ets` |  |
| 新增 | `main/src/main/ets/service/IndexPreferencesService.ets` |  |
| 新增 | `main/src/main/ets/utils/CsvUtils.ets` | 可选 |
| 修改 | `main/src/main/ets/pages/Index.ets` |  |
| 修改 | `main/src/main/module.json5` | 如涉及权限或文件访问配置 |

### 10.4 回归记录

| 验证项 | 状态 | 备注 |
|---|---|---|
| 应用启动后历史数据恢复正常 | `[ ]` |  |
| 设置项持久化正常 | `[ ]` |  |
| 导出成功 | `[ ]` |  |
| 导入成功 | `[ ]` |  |
| 导入后数据合并正确 | `[ ]` |  |
| 临时文件清理无异常 | `[ ]` |  |
| 异常情况下页面有提示 | `[ ]` |  |
| 工程编译通过 | `[ ]` |  |

---

## 11. 阶段 8：收尾优化进展

### 11.1 阶段状态

| 项目 | 内容 |
|---|---|
| 阶段状态 | `[ ]` |
| 目标分支 | `refactor/index-stage8-cleanup` |
| 开始时间 |  |
| 完成时间 |  |
| 编译结果 | 未执行 |
| 回归结果 | 未执行 |
| 是否允许结束必做拆分 | 未确认 |

### 11.2 步骤进度

| 步骤 | 内容 | 状态 | 执行记录 |
|---|---|---|---|
| Step 1 | 创建/切换阶段分支 | `[ ]` |  |
| Step 2 | 清理已废弃 `@Builder` | `[ ]` |  |
| Step 3 | 清理无用 import | `[ ]` |  |
| Step 4 | 清理无用状态变量 | `[ ]` |  |
| Step 5 | 清理已迁移纯函数 | `[ ]` |  |
| Step 6 | 清理废弃注释 | `[ ]` |  |
| Step 7 | 统一组件命名 | `[ ]` |  |
| Step 8 | 统一回调命名 `onXxx` | `[ ]` |  |
| Step 9 | 统一 service 命名 `IndexXxxService` | `[ ]` |  |
| Step 10 | 检查职责混杂文件 | `[ ]` |  |
| Step 11 | 检查过度碎片化文件 | `[ ]` |  |
| Step 12 | 更新最终目录结构文档 | `[ ]` |  |
| Step 13 | 补充组件职责说明 | `[ ]` |  |
| Step 14 | 补充 service 职责说明 | `[ ]` |  |
| Step 15 | 补充后续扩展建议 | `[ ]` |  |
| Step 16 | 执行全量功能回归 | `[ ]` |  |
| Step 17 | 执行最终编译验证 | `[ ]` |  |
| Step 18 | 提交阶段代码 | `[ ]` |  |

### 11.3 文件变更记录

| 类型 | 文件 | 说明 |
|---|---|---|
| 新增 |  |  |
| 修改 |  |  |
| 删除 |  |  |

### 11.4 回归记录

| 验证项 | 状态 | 备注 |
|---|---|---|
| 全量功能回归通过 | `[ ]` |  |
| 编译通过 | `[ ]` |  |
| 无明显无用 import | `[ ]` |  |
| `Index.ets` 职责收敛 | `[ ]` |  |
| 组件只做展示和回调 | `[ ]` |  |
| service 不直接控制 UI | `[ ]` |  |

---

## 12. 阶段 6：设置页页面化进展（可选）

### 12.1 是否进入本阶段

| 判断项 | 状态 | 说明 |
|---|---|---|
| 覆盖层逻辑仍然复杂 | `[ ]` |  |
| 设置页需要独立生命周期 | `[ ]` |  |
| 设置页后续会继续扩展 | `[ ]` |  |
| 返回/手势/遮罩逻辑维护成本较高 | `[ ]` |  |
| 团队希望统一使用 Navigation/router | `[ ]` |  |
| 是否决定进入本阶段 | 未决定 |  |

### 12.2 阶段状态

| 项目 | 内容 |
|---|---|
| 阶段状态 | `[ ]` |
| 目标分支 | `refactor/index-stage6-settings-page` |
| 开始时间 |  |
| 完成时间 |  |
| 编译结果 | 未执行 |
| 回归结果 | 未执行 |
| 是否允许进入下一阶段 | 未确认 |

### 12.3 步骤进度

| 步骤 | 内容 | 状态 | 执行记录 |
|---|---|---|---|
| Step 1 | 确定使用 Navigation 还是 router | `[ ]` |  |
| Step 2 | 新建 `SettingsPage.ets` | `[ ]` |  |
| Step 3 | 将设置组件组合进独立页面 | `[ ]` |  |
| Step 4 | 明确设置项状态来源和回写方式 | `[ ]` |  |
| Step 5 | 替换 `showSettingsPage` 覆盖层控制 | `[ ]` |  |
| Step 6 | 处理页面返回按钮 | `[ ]` |  |
| Step 7 | 处理系统返回/手势返回 | `[ ]` |  |
| Step 8 | 如需要，检查 `module.json5` 页面配置 | `[ ]` |  |
| Step 9 | 执行设置页页面化回归 | `[ ]` |  |
| Step 10 | 执行阶段编译验证 | `[ ]` |  |
| Step 11 | 提交阶段代码 | `[ ]` |  |

### 12.4 文件变更记录

| 类型 | 文件 | 说明 |
|---|---|---|
| 新增 | `main/src/main/ets/pages/SettingsPage.ets` | 可选 |
| 修改 | `main/src/main/ets/pages/Index.ets` |  |
| 修改 | `main/src/main/module.json5` | 如使用 router 且需要配置页面路径 |

---

## 13. 阶段 7：ViewModel 收敛进展（可选）

### 13.1 是否进入本阶段

| 判断项 | 状态 | 说明 |
|---|---|---|
| `Index.ets` 中剩余 `@State` 仍然很多 | `[ ]` |  |
| 多个组件共享复杂状态 | `[ ]` |  |
| 参数传递链路过长 | `[ ]` |  |
| 后续仍有较大功能扩展 | `[ ]` |  |
| service 和 UI 已基本拆分完成 | `[ ]` |  |
| 是否决定进入本阶段 | 未决定 |  |

### 13.2 阶段状态

| 项目 | 内容 |
|---|---|
| 阶段状态 | `[ ]` |
| 目标分支 | `refactor/index-stage7-viewmodel` |
| 开始时间 |  |
| 完成时间 |  |
| 编译结果 | 未执行 |
| 回归结果 | 未执行 |
| 是否完成可选增强 | 未确认 |

### 13.3 步骤进度

| 步骤 | 内容 | 状态 | 执行记录 |
|---|---|---|---|
| Step 1 | 梳理页面展示状态 | `[ ]` |  |
| Step 2 | 梳理日历状态 | `[ ]` |  |
| Step 3 | 梳理设置状态 | `[ ]` |  |
| Step 4 | 梳理弹窗状态 | `[ ]` |  |
| Step 5 | 梳理导入导出状态 | `[ ]` |  |
| Step 6 | 梳理动画状态 | `[ ]` |  |
| Step 7 | 确定首批低风险迁移状态 | `[ ]` |  |
| Step 8 | 新建 `IndexViewModel.ets` | `[ ]` |  |
| Step 9 | 逐组迁移页面状态 | `[ ]` |  |
| Step 10 | 每迁移一组执行局部验证 | `[ ]` |  |
| Step 11 | 评估是否需要 `SettingsViewModel.ets` | `[ ]` |  |
| Step 12 | 如有必要，新增并接入 `SettingsViewModel.ets` | `[~]` | 默认按必要性决定 |
| Step 13 | 执行状态联动回归 | `[ ]` |  |
| Step 14 | 执行阶段编译验证 | `[ ]` |  |
| Step 15 | 提交阶段代码 | `[ ]` |  |

### 13.4 文件变更记录

| 类型 | 文件 | 说明 |
|---|---|---|
| 新增 | `main/src/main/ets/viewmodel/IndexViewModel.ets` | 可选 |
| 新增 | `main/src/main/ets/viewmodel/SettingsViewModel.ets` | 可选 |
| 修改 | `main/src/main/ets/pages/Index.ets` |  |
| 修改 | `main/src/main/ets/pages/SettingsPage.ets` | 如果阶段 6 已执行 |
| 修改 | `main/src/main/ets/components/index/*.ets` | 如涉及参数调整 |

---

## 14. 每次 Agent 执行记录

> Agent 每轮执行结束后，必须在本节追加一条记录，不能覆盖历史记录。

### 执行记录模板

```markdown
### YYYY-MM-DD HH:mm 执行记录

- 执行阶段：
- 执行步骤：
- 执行前状态：
- 本次完成内容：
- 新增文件：
- 修改文件：
- 删除文件：
- 编译结果：
- 回归结果：
- 遇到问题：
- 处理方式：
- 是否存在阻塞：
- 下一步计划：
```

### 历史执行记录

### 2026-06-04 15:20 执行记录

- 执行阶段：阶段 2：弹窗拆分
- 执行步骤：Step 1 - Step 15
- 执行前状态：阶段 1 已完成，当前位于 `refactor/index-stage1-settings`，待进入阶段 2
- 本次完成内容：新建 `refactor/index-stage2-dialogs` 分支；抽离排除时段编辑弹窗与冲突提示弹窗；在 `Index.ets` 中新增 `buildDialogs()` 统一编排；执行编辑器检查与构建验证
- 新增文件：`main/src/main/ets/components/dialogs/RangeEditDialog.ets`、`main/src/main/ets/components/dialogs/RangeConflictDialog.ets`
- 修改文件：`main/src/main/ets/pages/Index.ets`、`Index拆分Agent进展同步.md`
- 删除文件：无
- 编译结果：成功，`builtin_execute_build_command` 返回 Build success
- 回归结果：已完成编译级验证，未执行真机/手工弹窗交互回归
- 遇到问题：无阻塞；命令输出在当前终端环境中显示不完整，但分支状态与构建结果可确认
- 处理方式：通过 `git rev-parse --abbrev-ref HEAD` 与后续状态确认当前分支为 `refactor/index-stage2-dialogs`
- 是否存在阻塞：否
- 下一步计划：提交阶段 2 代码后进入阶段 3，拆分主页展示区组件


---

## 15. 编译与检查记录

| 时间 | 阶段 | 检查方式 | 结果 | 错误摘要 | 处理状态 |
|---|---|---|---|---|---|
| 2026-06-04 15:18 | 阶段 2：弹窗拆分 | `builtin_check_editor_errors` | 通过 | 无 | 已完成 |
| 2026-06-04 15:20 | 阶段 2：弹窗拆分 | `builtin_execute_build_command` | 通过 | Build success | 已完成 |
|  |  |  |  |  |  |

---

## 16. 问题与阻塞记录

| 编号 | 发现时间 | 阶段 | 问题描述 | 影响范围 | 当前状态 | 处理结论 |
|---|---|---|---|---|---|---|
|  |  |  |  |  |  |  |

---

## 17. 提交记录

| 时间 | 阶段 | 分支 | Commit | 提交说明 | 是否已验证 |
|---|---|---|---|---|---|
|  |  |  |  |  |  |

---

## 18. Agent 更新规则

Agent 每次执行后应遵循以下更新规则：

1. 更新“当前总进度快照”；
2. 更新对应阶段的“阶段状态”；
3. 更新对应阶段的“步骤进度”；
4. 更新对应阶段的“文件变更记录”；
5. 如执行了验证，更新对应“回归记录”；
6. 如执行了编译，更新“编译与检查记录”；
7. 如发现问题，更新“问题与阻塞记录”；
8. 如完成提交，更新“提交记录”；
9. 在“每次 Agent 执行记录”中追加本轮执行记录；
10. 不删除历史执行记录，除非用户明确要求整理归档。

---

## 19. 下一步默认计划

当前默认从以下任务开始：

```text
阶段 3：主页面展示区拆分
Step 1：创建/切换阶段分支 refactor/index-stage3-main-sections
```
