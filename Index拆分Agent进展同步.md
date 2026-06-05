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
| 当前阶段 | 阶段 7：ViewModel 收敛 |
| 当前步骤 | 已完成阶段 7 首批低风险状态收敛与阶段提交：新增 `IndexViewModel.ets`，集中持久化状态映射、记录深拷贝和选中日期月份同步；`Index.ets` 与 `SettingsPage.ets` 接入 ViewModel；按用户指令跳过编译和构建 |
| 当前分支 | `codex/index-stage7-viewmodel` |
| 最近一次执行时间 | 2026-06-05 10:10:08 |
| 最近一次执行人/Agent | OpenAI Codex Agent |
| 最近一次编译结果 | 已跳过（用户明确要求跳过编译和构建部分） |
| 最近一次回归结果 | 已完成 ViewModel 引用扫描、重复 `copyRecords` 清理确认与 `git diff --check`；未执行真机/手工页面交互回归 |
| 是否存在阻塞 | 否 |
| 阻塞摘要 | 无；构建验证按本次用户指令跳过 |
| 下一步计划 | 阶段 7 待人工/真机回归；如继续推进，再基于回归结果评估是否迁移弹窗状态或新增 `SettingsViewModel.ets` |

---

## 4. 阶段总进度

| 执行顺序 | 阶段 | 名称 | 必做/可选 | 状态 | 最近更新时间 | 备注 |
|---|---|---|---|---|---|---|
| 1 | 阶段 0 | 准备阶段 | 必做 | `[x]` | 2026-06-03 12:40:48 | 已完成基线记录、目录创建、编译验证 |
| 2 | 阶段 1 | 常量与设置页拆分 | 必做 | `[x]` | 2026-06-03 13:05:00 | 已完成常量文件与设置页组件抽离，构建通过 |
| 3 | 阶段 2 | 弹窗拆分 | 必做 | `[x]` | 2026-06-04 15:20:00 | 已完成排除时段编辑弹窗与冲突提示弹窗抽离，构建通过 |
| 4 | 阶段 3 | 主页面展示区拆分 | 必做 | `[x]` | 2026-06-04 15:55:00 | 已完成主页展示区抽离，并修复打卡时间实时更新问题，构建通过 |
| 5 | 阶段 4 | 日历区域拆分 | 必做 | `[x]` | 2026-06-04 18:26:53 | 已完成日历 UI 与计算 service 拆分；构建验证按用户指令跳过 |
| 6 | 阶段 5 | 导入导出与持久化 service 化 | 必做 | `[x]` | 2026-06-05 09:22:49 | 已完成代码拆分、引用扫描与阶段提交；构建验证按用户指令跳过 |
| 7 | 阶段 8 | 收尾优化 | 必做 | `[x]` | 2026-06-05 09:22:49 | 已清理残留 Builder、未使用状态/参数和已迁移纯函数；构建验证按用户指令跳过 |
| 8 | 阶段 6 | 设置页页面化 | 可选 | `[x]` | 2026-06-05 09:43:52 | 已新增独立 `SettingsPage.ets`，主页面通过 `router.pushUrl` 进入设置页，返回后从 preferences 重载状态；构建验证按用户指令跳过 |
| 9 | 阶段 7 | ViewModel 收敛 | 可选 | `[x]` | 2026-06-05 10:10:08 | 已完成首批持久化数据状态映射收敛与阶段提交：新增 `IndexViewModel.ets` 并接入 `Index.ets`、`SettingsPage.ets`；编译/构建按用户指令跳过 |

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
| 阶段状态 | `[x]` |
| 目标分支 | `refactor/index-stage4-calendar` |
| 开始时间 | 2026-06-04 18:09:03 |
| 完成时间 | 2026-06-04 18:26:53 |
| 编译结果 | 已跳过（用户明确要求跳过编译和构建部分） |
| 回归结果 | 已完成代码级迁移检查，未执行真机/手工日历交互回归 |
| 是否允许进入下一阶段 | 是（按用户指令跳过编译/构建后进入阶段 5） |

### 9.2 步骤进度

| 步骤 | 内容 | 状态 | 执行记录 |
|---|---|---|---|
| Step 1 | 创建/切换阶段分支 | `[x]` | 已从 `refactor/index-stage3-main-sections` 新建并切换到 `refactor/index-stage4-calendar` |
| Step 2 | 新建 `CalendarCard.ets` | `[x]` | 已新增折叠态日历卡片组件 |
| Step 3 | 提取折叠态日历 UI | `[x]` | 已将原 `buildCalendarCard()` 的标题、星期行、周视图与滑动手势迁移到组件 |
| Step 4 | 接入折叠态日历入参和回调 | `[x]` | 已接入月份、选中日期、今日按钮缩放、周 slots、展开/今日/滑动/选中日期回调 |
| Step 5 | 新建 `ExpandedCalendarPanel.ets` | `[x]` | 已新增展开态日历面板组件 |
| Step 6 | 提取展开态日历覆盖层 UI | `[x]` | 面板 UI 已迁移；遮罩层仍保留在 `Index.ets` 负责显示与关闭编排 |
| Step 7 | 接入展开态日历入参和回调 | `[x]` | 已接入月份、选中日期、月 rows、关闭、前后月、选中日期回调 |
| Step 8 | 评估是否需要 `DayCell.ets` | `[x]` | 折叠态与展开态共用日期单元格，决定抽出 `DayCell.ets` |
| Step 9 | 如有必要，新增并接入 `DayCell.ets` | `[x]` | 已新增并由 `CalendarCard`、`ExpandedCalendarPanel` 共用 |
| Step 10 | 新建 `IndexCalendarService.ets` | `[x]` | 已新增日历纯计算 service |
| Step 11 | 提取 `buildMonthSlots()` | `[x]` | 已迁移为 `IndexCalendarService.buildMonthSlots()` |
| Step 12 | 提取 `getCurrentWeekSlots()` | `[x]` | 已迁移为 `IndexCalendarService.getCurrentWeekSlots()` |
| Step 13 | 提取 `getExpandedCalendarRows()` | `[x]` | 已迁移为 `IndexCalendarService.getExpandedCalendarRows()` |
| Step 14 | 提取 `getDayCellColor()` | `[x]` | 已迁移为 `IndexCalendarService.getDayCellColor()` |
| Step 15 | 确认 service 不直接修改页面状态 | `[x]` | service 只接收入参并返回 slots/颜色，不持有或修改 `@State` |
| Step 16 | 页面接入日历 service | `[x]` | `Index.ets` 保留事件调度、持久化、动画状态，slot/颜色计算委托给 service |
| Step 17 | 执行日历功能回归 | `[~]` | 已完成代码级检查，未执行真机/手工日历交互回归 |
| Step 18 | 执行阶段编译验证 | `[~]` | 按用户本轮指令跳过编译和构建验证 |
| Step 19 | 提交阶段代码 | `[ ]` |  |

### 9.3 文件变更记录

| 类型 | 文件 | 说明 |
|---|---|---|
| 新增 | `main/src/main/ets/components/index/CalendarCard.ets` | 折叠态日历卡片展示组件 |
| 新增 | `main/src/main/ets/components/index/ExpandedCalendarPanel.ets` | 展开态日历面板展示组件 |
| 新增 | `main/src/main/ets/components/index/DayCell.ets` | 折叠态与展开态共用日期单元格组件 |
| 新增 | `main/src/main/ets/service/IndexCalendarService.ets` | 日历 slots、展开 rows 与日期单元格颜色纯计算 service |
| 修改 | `main/src/main/ets/pages/Index.ets` | 接入日历组件与 service，保留页面状态、动画、持久化和事件调度 |

### 9.4 回归记录

| 验证项 | 状态 | 备注 |
|---|---|---|
| 折叠态日历显示正常 | `[~]` | 已完成代码级迁移检查，未执行真机/手工回归 |
| 展开态日历显示正常 | `[~]` | 已完成代码级迁移检查，未执行真机/手工回归 |
| 日期切换正常 | `[~]` | 选中日期逻辑保留在页面 `selectCalendarDate()`，未执行真机/手工回归 |
| 周切换正常 | `[~]` | 周滑动仍回调页面 `handleCalendarSwipe()`，未执行真机/手工回归 |
| 月切换正常 | `[~]` | 展开态左右滑仍回调页面前后月方法，未执行真机/手工回归 |
| 选中日期高亮正确 | `[~]` | 高亮颜色迁移到 service，未执行真机/手工回归 |
| 节假日/工作日/排除时段显示正确 | `[~]` | 本阶段未改业务规则；当前日历 cell 仍显示打卡点，未执行真机/手工回归 |
| 工程编译通过 | `[~]` | 按用户本轮指令跳过编译和构建验证 |

---

## 10. 阶段 5：导入导出与持久化 service 化进展

### 10.1 阶段状态

| 项目 | 内容 |
|---|---|
| 阶段状态 | `[x]` |
| 目标分支 | `refactor/index-stage5-services` |
| 开始时间 | 2026-06-04 18:26:53 |
| 完成时间 | 2026-06-05 09:22:49 |
| 编译结果 | 已跳过（用户明确要求跳过编译和构建部分） |
| 回归结果 | 已完成代码级引用扫描；未执行真机/手工导入导出与持久化回归 |
| 是否允许进入下一阶段 | 是（阶段 5 已存在提交 `bcc3239`，构建/编译按用户指令跳过） |

### 10.2 步骤进度

| 步骤 | 内容 | 状态 | 执行记录 |
|---|---|---|---|
| Step 1 | 创建/切换阶段分支 | `[x]` | 已从 `refactor/index-stage4-calendar` 新建并切换到 `refactor/index-stage5-services` |
| Step 2 | 梳理 `Index.ets` 中导入导出函数 | `[x]` | 已定位导出、导入、CSV 解析、ZIP 压缩/解压、临时文件清理和导入合并逻辑 |
| Step 3 | 梳理 `Index.ets` 中 preferences 读写函数 | `[x]` | 已定位初始化、加载、保存、清空记录和序列化/反序列化逻辑 |
| Step 4 | 新建 `IndexImportExportService.ets` | `[x]` | 已新增导入导出 service，对外提供 `exportData()`、`importData()`、`mergeRecords()` |
| Step 5 | 提取 CSV 文本生成逻辑 | `[x]` | 已迁移到 `CsvUtils.buildTemplateCsv()` 和 `CsvUtils.buildMonthCsv()` |
| Step 6 | 提取 CSV 解析逻辑 | `[x]` | 已迁移到 `CsvUtils.parseCsvContent()` |
| Step 7 | 提取 ZIP 打包逻辑 | `[x]` | 已迁移到 `IndexImportExportService.exportData()` |
| Step 8 | 提取 ZIP 解包逻辑 | `[x]` | 已迁移到 `IndexImportExportService.importZip()` |
| Step 9 | 提取导入合并逻辑 | `[x]` | 已迁移到 `CsvUtils.mergeRecords()`，service 通过 `mergeRecords()` 暴露 |
| Step 10 | 提取临时文件清理逻辑 | `[x]` | 已迁移到 `IndexImportExportService` 私有清理方法，并用 `finally` 保证执行 |
| Step 11 | 评估是否需要 `CsvUtils.ets` | `[x]` | CSV 生成、解析、分组、合并逻辑较集中，决定新增工具文件 |
| Step 12 | 如有必要，新增并接入 `CsvUtils.ets` | `[x]` | 已新增并接入 `IndexImportExportService` |
| Step 13 | 新建 `IndexPreferencesService.ets` | `[x]` | 已新增 preferences service，并定义 `PersistState` |
| Step 14 | 收敛 preferences key | `[x]` | preferences 名称与 key 已迁移到 `IndexPreferencesService` |
| Step 15 | 提取加载状态接口 | `[x]` | 已提供 `loadState(state)`，页面通过 `applyPersistState()` 回写 `@State` |
| Step 16 | 提取保存状态接口 | `[x]` | 已提供 `persistState(state)` 与 `clearAllRecords()` |
| Step 17 | 重构 `initializeData()` | `[x]` | 页面初始化改为组装 `PersistState`、调用 service 加载、再应用到页面状态 |
| Step 18 | 页面保留 toast/dialog/loading UI 反馈 | `[x]` | 导入导出 service 不直接控制 toast/dialog；页面继续负责成功、失败和空数据提示 |
| Step 19 | 检查 `module.json5` 权限/文件访问配置 | `[~]` | 本轮未新增权限与页面路由配置；继续沿用系统 picker 授权 uri 访问 |
| Step 20 | 执行数据功能回归 | `[~]` | 已完成代码级引用扫描；未执行真机/手工导入导出与持久化回归 |
| Step 21 | 执行阶段编译验证 | `[~]` | 按用户指令跳过编译和构建 |
| Step 22 | 提交阶段代码 | `[x]` | 当前历史已有提交 `bcc3239`（完成重构任务阶段5） |

### 10.3 文件变更记录

| 类型 | 文件 | 说明 |
|---|---|---|
| 新增 | `main/src/main/ets/service/IndexImportExportService.ets` | 导入导出、文件 picker、ZIP 压缩/解压与临时文件清理 service |
| 新增 | `main/src/main/ets/service/IndexPreferencesService.ets` | preferences key、加载、保存、清空记录和持久化序列化 service |
| 新增 | `main/src/main/ets/utils/CsvUtils.ets` | CSV 生成、解析、按月分组与导入合并工具 |
| 修改 | `main/src/main/ets/pages/Index.ets` | 接入导入导出与 preferences service，保留页面状态赋值和 UI 反馈 |
| 删除 | `main/src/main/ets/service/StorageService.ets` | 已由 `IndexPreferencesService.ets` 替代，避免重复持久化实现 |

### 10.4 回归记录

| 验证项 | 状态 | 备注 |
|---|---|---|
| 应用启动后历史数据恢复正常 | `[~]` | 已完成代码级迁移检查，未执行真机/手工回归 |
| 设置项持久化正常 | `[~]` | preferences 读写迁移到 service，未执行真机/手工回归 |
| 导出成功 | `[~]` | 导出流程迁移到 service，未执行真机/手工回归 |
| 导入成功 | `[~]` | 导入流程迁移到 service，未执行真机/手工回归 |
| 导入后数据合并正确 | `[~]` | 合并逻辑迁移到 `CsvUtils.mergeRecords()`，未执行真机/手工回归 |
| 临时文件清理无异常 | `[~]` | 清理逻辑迁移到 service 且保留异常吞掉策略，未执行真机/手工回归 |
| 异常情况下页面有提示 | `[~]` | 页面仍负责 catch 后 toast；未执行真机/手工回归 |
| 工程编译通过 | `[~]` | 按用户指令跳过编译和构建 |

---

## 11. 阶段 8：收尾优化进展

### 11.1 阶段状态

| 项目 | 内容 |
|---|---|
| 阶段状态 | `[x]` |
| 目标分支 | `codex/index-stage8-cleanup` |
| 开始时间 | 2026-06-05 09:22:49 |
| 完成时间 | 2026-06-05 09:22:49 |
| 编译结果 | 已跳过（用户明确要求跳过编译和构建部分） |
| 回归结果 | 已完成代码级引用扫描；未执行真机/手工页面交互回归 |
| 是否允许结束必做拆分 | 是（代码级检查完成；编译/构建与真机/手工回归按用户指令或环境限制未执行） |

### 11.2 步骤进度

| 步骤 | 内容 | 状态 | 执行记录 |
|---|---|---|---|
| Step 1 | 创建/切换阶段分支 | `[x]` | 已从 `refactor/index-stage5-services` 新建并切换到 `codex/index-stage8-cleanup` |
| Step 2 | 清理已废弃 `@Builder` | `[x]` | 已删除 `Index.ets` 中纯转发/未调用 Builder，仅保留 `buildDialogs()`、`buildMainPage()`、`buildSettingsPage()`、`buildExpandedCalendarOverlay()` |
| Step 3 | 清理无用 import | `[x]` | 代码级扫描未发现本轮清理后新增无用 import；组件/service 引用保持现状 |
| Step 4 | 清理无用状态变量 | `[x]` | 已删除只写不读的 `rangeDialogKey` |
| Step 5 | 清理已迁移纯函数 | `[x]` | 已删除页面内已由 `TimeUtils`/`PunchCalculator` 承接的残留纯函数 |
| Step 6 | 清理废弃注释 | `[~]` | 本轮未大范围改动中文注释，仅清理随函数删除的残留注释上下文 |
| Step 7 | 统一组件命名 | `[x]` | 组件仍保持 PascalCase 命名 |
| Step 8 | 统一回调命名 `onXxx` | `[x]` | 本轮扫描未发现新增非 `onXxx` 回调 |
| Step 9 | 统一 service 命名 `IndexXxxService` | `[x]` | `IndexCalendarService`、`IndexImportExportService`、`IndexPreferencesService` 命名一致 |
| Step 10 | 检查职责混杂文件 | `[x]` | `Index.ets` 进一步收敛为页面编排、状态入口与事件调度；service 不控制 toast/dialog |
| Step 11 | 检查过度碎片化文件 | `[x]` | 保留现有组件粒度；`PunchCardSection` 内部 `buildTimeCard()` 仍为组件内私有 UI 片段 |
| Step 12 | 更新最终目录结构文档 | `[x]` | 已在本进展文档记录当前目录结构与职责 |
| Step 13 | 补充组件职责说明 | `[x]` | 已在本进展文档记录组件职责概览 |
| Step 14 | 补充 service 职责说明 | `[x]` | 已在本进展文档记录 service 职责概览 |
| Step 15 | 补充后续扩展建议 | `[x]` | 已记录阶段 6/7 保持可选，并建议按维护成本与状态链路复杂度决定是否进入 |
| Step 16 | 执行全量功能回归 | `[~]` | 未执行真机/手工回归；本轮仅执行代码级引用扫描 |
| Step 17 | 执行最终编译验证 | `[~]` | 按用户指令跳过编译和构建 |
| Step 18 | 提交阶段代码 | `[x]` | 本轮提交阶段 8 收尾分支 |

### 11.3 文件变更记录

| 类型 | 文件 | 说明 |
|---|---|---|
| 新增 |  |  |
| 修改 | `main/src/main/ets/pages/Index.ets` | 内联主页组件编排，删除残留空壳 Builder、未使用状态与已迁移纯函数 |
| 修改 | `main/src/main/ets/components/index/PunchCardSection.ets` | 删除未使用的 `selectedDateKey` 入参 |
| 修改 | `Index拆分Agent进展同步.md` | 同步阶段 5 完成状态与阶段 8 收尾进展 |
| 删除 |  |  |

### 11.4 回归记录

| 验证项 | 状态 | 备注 |
|---|---|---|
| 全量功能回归通过 | `[~]` | 未执行真机/手工回归；本轮仅执行代码级引用扫描 |
| 编译通过 | `[~]` | 按用户指令跳过编译和构建 |
| 无明显无用 import | `[x]` | 已执行旧 Builder、废弃 service、调试输出和残留引用扫描 |
| `Index.ets` 职责收敛 | `[x]` | 页面删除纯转发 Builder 与已迁移纯函数，保留页面编排、状态入口和事件调度 |
| 组件只做展示和回调 | `[x]` | 本轮未向组件加入业务/持久化逻辑，并删除 `PunchCardSection` 未使用入参 |
| service 不直接控制 UI | `[x]` | 本轮未改动 service UI 边界；导入导出和 preferences service 仍不直接控制 toast/dialog |

### 11.5 当前结构与职责概览

| 模块 | 当前职责 |
|---|---|
| `main/src/main/ets/pages/Index.ets` | 页面编排、`@State` 入口、弹窗/覆盖层编排、事件调度、toast/dialog UI 反馈 |
| `main/src/main/ets/components/index` | 首页、设置页和日历展示组件；通过 `onXxx` 回调通知页面处理状态变更 |
| `main/src/main/ets/components/dialogs` | 排除时段编辑与冲突提示弹窗展示；不直接读写页面全局状态 |
| `main/src/main/ets/constants/IndexConstants.ets` | 默认值、星期文案与固定节假日配置 |
| `main/src/main/ets/service` | 时间/工时计算、日历计算、导入导出与 preferences 持久化访问 |
| `main/src/main/ets/utils/CsvUtils.ets` | CSV 生成、解析、分组与导入合并等无状态文本处理 |

后续扩展建议：阶段 6 设置页页面化和阶段 7 ViewModel 收敛仍保持可选，建议仅在覆盖层维护成本或状态传递链路继续升高时进入。

---

## 12. 阶段 6：设置页页面化进展（可选）

### 12.1 是否进入本阶段

| 判断项 | 状态 | 说明 |
|---|---|---|
| 覆盖层逻辑仍然复杂 | `[x]` | 阶段 1 后设置页仍由 `Index.ets` 覆盖层控制，并保留返回、点击重置删除确认、排除时段弹窗入口等页面级状态 |
| 设置页需要独立生命周期 | `[x]` | 设置项、排除时段和数据管理可独立加载/保存 preferences，适合从主页面拆出 |
| 设置页后续会继续扩展 | `[x]` | 当前已有工时设置、排除时段、深色模式和数据管理模块，后续继续扩展时独立页面维护成本更低 |
| 返回/手势/遮罩逻辑维护成本较高 | `[x]` | 已移除设置页覆盖层与手势关闭逻辑，改为系统 router 页面返回 |
| 团队希望统一使用 Navigation/router | `[x]` | 项目通过 `main_pages.json` 配置页面，本阶段沿用 router 页面方案 |
| 是否决定进入本阶段 | 已决定进入并完成 | 基于现有页面配置与覆盖层复杂度，执行阶段 6 |

### 12.2 阶段状态

| 项目 | 内容 |
|---|---|
| 阶段状态 | `[x]` |
| 目标分支 | `refactor/index-stage6-settings-page` |
| 开始时间 | 2026-06-05 09:43:52 |
| 完成时间 | 2026-06-05 09:43:52 |
| 编译结果 | 已跳过（用户明确要求跳过编译和构建部分） |
| 回归结果 | 已完成代码级残留引用扫描与 `git diff --check`；未执行真机/手工页面交互回归 |
| 是否允许进入下一阶段 | 是（阶段 7 仍为可选，建议先补手工回归） |

### 12.3 步骤进度

| 步骤 | 内容 | 状态 | 执行记录 |
|---|---|---|---|
| Step 1 | 确定使用 Navigation 还是 router | `[x]` | 项目当前通过 `main_pages.json` 配置页面，未发现既有 Navigation/NavDestination，采用 router 方案 |
| Step 2 | 新建 `SettingsPage.ets` | `[x]` | 已新增 `main/src/main/ets/pages/SettingsPage.ets` |
| Step 3 | 将设置组件组合进独立页面 | `[x]` | 已在 `SettingsPage.ets` 组合 `SettingsHeader`、工时设置、排除时段、目标工时、深色模式和数据管理组件 |
| Step 4 | 明确设置项状态来源和回写方式 | `[x]` | 设置页通过 `IndexPreferencesService` 读取/保存状态；主页面返回后在 `onPageShow` 重载 preferences |
| Step 5 | 替换 `showSettingsPage` 覆盖层控制 | `[x]` | 已移除 `Index.ets` 中 `showSettingsPage`、`buildSettingsPage()` 与覆盖层手势逻辑，设置入口改为 `router.pushUrl` |
| Step 6 | 处理页面返回按钮 | `[x]` | `SettingsHeader.onBack` 调用 `router.back()` |
| Step 7 | 处理系统返回/手势返回 | `[x]` | `SettingsPage.onBackPress()` 优先关闭设置页弹窗，否则执行 `router.back()` |
| Step 8 | 如需要，检查 `module.json5` 页面配置 | `[x]` | `module.json5` 已指向 `main_pages.json`；已在 `main_pages.json` 增加 `pages/SettingsPage` |
| Step 9 | 执行设置页页面化回归 | `[~]` | 未执行真机/手工页面交互回归；已执行代码级残留引用扫描 |
| Step 10 | 执行阶段编译验证 | `[~]` | 按用户指令跳过编译和构建 |
| Step 11 | 提交阶段代码 | `[x]` | 已提交阶段 6 设置页页面化分支 |

### 12.4 文件变更记录

| 类型 | 文件 | 说明 |
|---|---|---|
| 新增 | `main/src/main/ets/pages/SettingsPage.ets` | 独立设置页面，承接设置组件、排除时段弹窗、数据管理入口和 preferences 回写 |
| 修改 | `main/src/main/ets/pages/Index.ets` | 设置入口改为 router 跳转；返回后通过 `onPageShow` 重载状态；移除设置覆盖层与设置页专属逻辑 |
| 修改 | `main/src/main/resources/base/profile/main_pages.json` | 增加 `pages/SettingsPage` 页面配置 |

---

## 13. 阶段 7：ViewModel 收敛进展（可选）

### 13.1 是否进入本阶段

| 判断项 | 状态 | 说明 |
|---|---|---|
| `Index.ets` 中剩余 `@State` 仍然很多 | `[x]` | 主页面仍保留日期、日历、记录、设置、动画等多组 `@State`，具备首批低风险收敛价值 |
| 多个组件共享复杂状态 | `[x]` | `Index.ets` 与 `SettingsPage.ets` 共享持久化数据状态与 `PersistState` 映射逻辑 |
| 参数传递链路过长 | `[x]` | 日历、汇总、打卡和设置组件均依赖页面层状态透传，首批先收敛持久化状态映射 |
| 后续仍有较大功能扩展 | `[x]` | 设置页页面化后，后续设置模块和数据管理继续扩展时需要更清晰的状态边界 |
| service 和 UI 已基本拆分完成 | `[x]` | 阶段 0-6 与阶段 8 已完成基础组件/service 拆分 |
| 是否决定进入本阶段 | 已决定进入并完成首批低风险迁移 | 先迁移持久化数据状态映射，不迁移动画、高频交互和生命周期敏感状态 |

### 13.2 阶段状态

| 项目 | 内容 |
|---|---|
| 阶段状态 | `[x]` |
| 目标分支 | `codex/index-stage7-viewmodel` |
| 开始时间 | 2026-06-05 10:10:08 |
| 完成时间 | 2026-06-05 10:10:08 |
| 编译结果 | 已跳过（用户明确要求跳过编译和构建部分） |
| 回归结果 | 已完成代码级 ViewModel 引用扫描与 `git diff --check`；未执行真机/手工页面交互回归 |
| 是否完成可选增强 | 是；首批低风险迁移已完成，后续如有必要再扩展 |

### 13.3 步骤进度

| 步骤 | 内容 | 状态 | 执行记录 |
|---|---|---|---|
| Step 1 | 梳理页面展示状态 | `[x]` | 已确认主页面展示状态仍由页面 `@State` 承接，本轮不迁移渲染响应入口 |
| Step 2 | 梳理日历状态 | `[x]` | 已确认日历展开、月份、周偏移和刷新 key 与交互/动画耦合，本轮只迁移选中日期到月份同步辅助逻辑 |
| Step 3 | 梳理设置状态 | `[x]` | 已确认设置页与主页面共享持久化状态：目标工时、上班时间、排除时段、记录、深色模式等 |
| Step 4 | 梳理弹窗状态 | `[x]` | 已确认设置页弹窗状态仍属于局部高频 UI 状态，本轮暂不迁移 |
| Step 5 | 梳理导入导出状态 | `[x]` | 已确认导入导出入口在 `SettingsPage.ets`，数据记录状态纳入首批持久化数据映射收敛 |
| Step 6 | 梳理动画状态 | `[x]` | 已确认 punch/today 动画状态保持页面 `@State`，避免影响动画响应链 |
| Step 7 | 确定首批低风险迁移状态 | `[x]` | 首批迁移范围确定为持久化数据状态映射、记录深拷贝和选中日期月份同步 |
| Step 8 | 新建 `IndexViewModel.ets` | `[x]` | 已新增 `main/src/main/ets/viewmodel/IndexViewModel.ets` |
| Step 9 | 逐组迁移页面状态 | `[x]` | 已将 `Index.ets` 与 `SettingsPage.ets` 的 `PersistState` 创建/应用逻辑接入 `IndexViewModel`；页面暂保留 `@State` 字段 |
| Step 10 | 每迁移一组执行局部验证 | `[x]` | 已执行 `rg` 引用扫描与 `git diff --check`；编译/构建按用户指令跳过 |
| Step 11 | 评估是否需要 `SettingsViewModel.ets` | `[x]` | 暂不新增；设置页弹窗和导入导出反馈仍局部清晰，后续如继续扩展再评估 |
| Step 12 | 如有必要，新增并接入 `SettingsViewModel.ets` | `[~]` | 默认按必要性决定 |
| Step 13 | 执行状态联动回归 | `[~]` | 未执行真机/手工页面交互回归；已完成代码级引用扫描 |
| Step 14 | 执行阶段编译验证 | `[~]` | 按用户明确要求跳过编译和构建 |
| Step 15 | 提交阶段代码 | `[x]` | 本轮提交阶段 7 ViewModel 收敛分支 |

### 13.4 文件变更记录

| 类型 | 文件 | 说明 |
|---|---|---|
| 新增 | `main/src/main/ets/viewmodel/IndexViewModel.ets` | 集中持久化数据状态、`PersistState` 映射、记录深拷贝和选中日期月份同步 |
| 新增 | `main/src/main/ets/viewmodel/SettingsViewModel.ets` | 可选 |
| 修改 | `main/src/main/ets/pages/Index.ets` | 接入 `IndexViewModel`，通过 `updateViewModelState()` / `applyViewModelState()` 收敛持久化状态映射，保留页面 `@State` 响应入口 |
| 修改 | `main/src/main/ets/pages/SettingsPage.ets` | 接入 `IndexViewModel`，复用持久化状态映射与记录深拷贝逻辑 |
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

### 2026-06-05 10:10 执行记录

- 执行阶段：阶段 7：ViewModel 收敛
- 执行步骤：Step 1 - Step 15（Step 13 真机/手工回归未执行，Step 14 编译/构建按用户指令跳过）
- 执行前状态：阶段 6 已完成，当前从 `codex/index-stage6-settings-page` 新建并切换到 `codex/index-stage7-viewmodel`
- 本次完成内容：新增 `IndexViewModel.ets`，集中持久化数据状态、`PersistState` 创建/应用、记录深拷贝和选中日期同步显示月份逻辑；`Index.ets` 与 `SettingsPage.ets` 接入 ViewModel，通过 `updateViewModelState()` / `applyViewModelState()` 复用持久化状态映射；页面层继续保留现有 `@State` 字段，避免一次性迁移动画、高频交互和生命周期敏感状态；评估后暂不新增 `SettingsViewModel.ets`
- 新增文件：`main/src/main/ets/viewmodel/IndexViewModel.ets`
- 修改文件：`main/src/main/ets/pages/Index.ets`、`main/src/main/ets/pages/SettingsPage.ets`、`Index拆分Agent进展同步.md`
- 删除文件：无
- 编译结果：已跳过（用户明确要求跳过编译和构建部分）
- 回归结果：已完成 `rg` ViewModel/重复 `copyRecords` 引用扫描与 `git diff --check`；未执行真机/手工页面交互回归
- 遇到问题：`git diff --check` 提示工作区文件下次触碰时会按 CRLF 处理，未发现空白错误
- 处理方式：记录为 Git 换行提示，不做额外格式化 churn
- 是否存在阻塞：否
- 下一步计划：阶段 7 待人工/真机回归；如后续继续扩展，再基于回归结果评估是否迁移弹窗状态或新增 `SettingsViewModel.ets`

### 2026-06-05 09:43 执行记录

- 执行阶段：阶段 6：设置页页面化
- 执行步骤：Step 1 - Step 11（Step 9 真机/手工回归未执行，Step 10 编译/构建按用户指令跳过）
- 执行前状态：阶段 8 已完成，当前从 `codex/index-stage8-cleanup` 新建 `codex/index-stage6-settings-page`
- 本次完成内容：新增独立 `SettingsPage.ets`，将设置页组件、排除时段弹窗、上班时间选择、数据管理导入/导出/清空入口迁移到独立页面；`Index.ets` 设置入口改为 `router.pushUrl({ url: 'pages/SettingsPage' })`；主页面在 `onPageShow` 中从 preferences 重载设置和记录状态；移除 `Index.ets` 中 `showSettingsPage` 覆盖层、设置页手势关闭逻辑和设置页专属方法；更新 `main_pages.json` 页面配置
- 新增文件：`main/src/main/ets/pages/SettingsPage.ets`
- 修改文件：`main/src/main/ets/pages/Index.ets`、`main/src/main/resources/base/profile/main_pages.json`、`Index拆分Agent进展同步.md`
- 删除文件：无
- 编译结果：已跳过（用户明确要求跳过编译和构建部分）
- 回归结果：已完成代码级残留引用扫描与 `git diff --check`；未执行真机/手工页面交互回归
- 遇到问题：阶段 6 明细文档首次补丁因文本片段不完全一致未套用
- 处理方式：使用 UTF-8 按行定位真实文档内容后，拆成小补丁分段更新
- 是否存在阻塞：否
- 下一步计划：如继续推进，优先进行阶段 6 手工页面回归；阶段 7 ViewModel 收敛仍保持可选

### 2026-06-05 09:22 执行记录

- 执行阶段：阶段 8：收尾优化
- 执行步骤：Step 1 - Step 17（Step 16 真机/手工回归未执行，Step 17 编译/构建按用户指令跳过）
- 执行前状态：阶段 5 已存在提交 `bcc3239`，当前从 `refactor/index-stage5-services` 新建 `codex/index-stage8-cleanup`
- 本次完成内容：清理 `Index.ets` 中纯转发和未调用 Builder；删除只写不读的 `rangeDialogKey`；删除已迁移到 `TimeUtils`/`PunchCalculator` 的页面内纯函数；删除 `PunchCardSection` 未使用入参；补充阶段 8 当前结构、组件职责、service 职责与后续可选扩展建议
- 新增文件：无
- 修改文件：`main/src/main/ets/pages/Index.ets`、`main/src/main/ets/components/index/PunchCardSection.ets`、`Index拆分Agent进展同步.md`
- 删除文件：无
- 编译结果：已跳过（用户明确要求跳过编译和构建部分）
- 回归结果：已完成代码级引用扫描；未执行真机/手工页面交互回归
- 遇到问题：终端默认显示中文时存在乱码，但文件实际为 UTF-8
- 处理方式：使用 UTF-8 读取确认文档与源码真实内容后再通过补丁更新
- 是否存在阻塞：否
- 下一步计划：提交阶段 8 收尾分支；如需要继续可评估是否进入可选阶段 6/7

### 2026-06-04 18:09 执行记录

- 执行阶段：阶段 4：日历区域拆分
- 执行步骤：Step 1 - Step 18（Step 18 构建验证因当前终端环境缺少 Hvigor 命令未完成）
- 执行前状态：阶段 3 已提交，当前从 `refactor/index-stage3-main-sections` 新建 `refactor/index-stage4-calendar`
- 本次完成内容：抽离折叠态日历卡片、展开态日历面板、共用日期单元格；新增日历纯计算 service；`Index.ets` 保留页面状态、动画、持久化和事件调度，仅负责组件编排与调用 service
- 新增文件：`main/src/main/ets/components/index/CalendarCard.ets`、`main/src/main/ets/components/index/ExpandedCalendarPanel.ets`、`main/src/main/ets/components/index/DayCell.ets`、`main/src/main/ets/service/IndexCalendarService.ets`
- 修改文件：`main/src/main/ets/pages/Index.ets`、`Index拆分Agent进展同步.md`
- 删除文件：无
- 编译结果：未完成；当前终端环境执行 `./hvigorw.bat --mode module -p module=main assembleHap` 与 `hvigor --mode module -p module=main assembleHap` 均提示命令不存在
- 回归结果：已完成代码级迁移检查与无残留 builder/import 搜索；未执行真机/手工日历交互回归
- 遇到问题：当前仓库/终端未提供可用 Hvigor 构建入口
- 处理方式：记录为验证环境限制；保留阶段 4 为进行中，等待可用 DevEco/Hvigor 环境执行构建验证
- 是否存在阻塞：否（代码拆分可继续审阅；进入下一阶段前仍需补构建验证）
- 下一步计划：在可用构建环境完成阶段 4 编译验证，修复可能的 ArkTS 编译问题后提交阶段 4 代码

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
| 2026-06-04 18:09 | 阶段 4：日历区域拆分 | `./hvigorw.bat --mode module -p module=main assembleHap` | 未通过 | 当前环境不存在 `hvigorw.bat` | 待可用构建环境验证 |
| 2026-06-04 18:09 | 阶段 4：日历区域拆分 | `hvigor --mode module -p module=main assembleHap` | 未通过 | 当前 PATH 不存在 `hvigor` | 待可用构建环境验证 |
| 2026-06-05 09:22 | 阶段 8：收尾优化 | `rg` 残留引用扫描 | 通过 | 未发现旧 Builder 名称、`rangeDialogKey`、`StorageService`、`ConfirmClearDialog`、调试输出残留 | 已完成 |
| 2026-06-05 09:22 | 阶段 8：收尾优化 | `git diff --check` | 通过 | 无空白错误；仅 Git 提示工作区文件下次触碰时会按 CRLF 处理 | 已完成 |
| 2026-06-05 09:22 | 阶段 8：收尾优化 | 编译/构建 | 已跳过 | 用户明确要求跳过编译和构建部分 | 已记录 |
| 2026-06-05 09:43 | 阶段 6：设置页页面化 | `rg` 残留引用扫描 | 通过 | `Index.ets` 未发现 `showSettingsPage`、`buildSettingsPage`、设置页排除时段弹窗与导入导出方法残留 | 已完成 |
| 2026-06-05 09:43 | 阶段 6：设置页页面化 | `git diff --check` | 通过 | 无空白错误；仅 Git 提示工作区文件下次触碰时会按 CRLF 处理 | 已完成 |
| 2026-06-05 09:43 | 阶段 6：设置页页面化 | 编译/构建 | 已跳过 | 用户明确要求跳过编译和构建部分 | 已记录 |
| 2026-06-05 10:10 | 阶段 7：ViewModel 收敛 | `rg` ViewModel/重复拷贝引用扫描 | 通过 | `Index.ets` 与 `SettingsPage.ets` 已接入 `IndexViewModel`；页面内重复 `copyRecords` 实现已移除 | 已完成 |
| 2026-06-05 10:10 | 阶段 7：ViewModel 收敛 | `git diff --check` | 通过 | 无空白错误；仅 Git 提示工作区文件下次触碰时会按 CRLF 处理 | 已完成 |
| 2026-06-05 10:10 | 阶段 7：ViewModel 收敛 | 编译/构建 | 已跳过 | 用户明确要求跳过编译和构建部分 | 已记录 |
|  |  |  |  |  |  |

---

## 16. 问题与阻塞记录

| 编号 | 发现时间 | 阶段 | 问题描述 | 影响范围 | 当前状态 | 处理结论 |
|---|---|---|---|---|---|---|
| IDX-S4-001 | 2026-06-04 18:09 | 阶段 4：日历区域拆分 | 当前终端环境未提供 `hvigorw.bat` 或 `hvigor` 构建命令 | 阶段 4 编译验证暂无法在当前终端完成 | 待验证 | 代码拆分已完成代码级检查；进入下一阶段前需在 DevEco 或可用 Hvigor 环境补构建验证 |
|  |  |  |  |  |  |  |

---

## 17. 提交记录

| 时间 | 阶段 | 分支 | Commit | 提交说明 | 是否已验证 |
|---|---|---|---|---|---|
| 2026-06-05 09:22 | 阶段 8：收尾优化 | `codex/index-stage8-cleanup` | 本轮提交 | `refactor(index): cleanup split structure` | 已完成代码级扫描；编译/构建按用户指令跳过 |
| 2026-06-05 09:43 | 阶段 6：设置页页面化 | `codex/index-stage6-settings-page` | 已提交 | `refactor(index): extract settings page` | 已完成代码级扫描；编译/构建按用户指令跳过 |
| 2026-06-05 10:10 | 阶段 7：ViewModel 收敛 | `codex/index-stage7-viewmodel` | 本轮提交 | `refactor(index): extract index view model` | 已完成 ViewModel 引用扫描与 `git diff --check`；编译/构建按用户指令跳过 |
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
阶段 8：收尾优化
Step 18：提交阶段 8 收尾分支；如继续推进，先评估是否确有必要进入可选阶段 6/7
```
