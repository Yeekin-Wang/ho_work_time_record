# Index.ets 拆分执行手册

## 1. 手册目标

本文档基于根目录下的 `Index拆分任务清单.md` 细化而来，用于指导 `main/src/main/ets/pages/Index.ets` 的渐进式拆分实施。

本手册重点回答：

- 每个阶段开始前要确认什么；
- 每个阶段按什么顺序执行；
- 每个阶段应该修改哪些文件；
- 每个阶段如何验证；
- 每个阶段如何提交与回滚；
- 哪些事情不能在当前阶段顺手做。

核心原则：

> 先低风险拆 UI，再抽离纯逻辑与 service，最后视情况做页面化和 ViewModel 化。

---

## 2. 适用范围

适用于当前 HarmonyOS 工程中 `Index.ets` 的拆分重构，默认路径如下：

```text
main/src/main/ets/pages/Index.ets
```

建议新增目录：

```text
main/src/main/ets/components/index
main/src/main/ets/components/dialogs
main/src/main/ets/constants
main/src/main/ets/service
main/src/main/ets/utils
main/src/main/ets/viewmodel
```

---

## 3. 执行总规则

### 3.1 阶段执行规则

1. 严格按阶段推进，不跨阶段混改。
2. 每个阶段完成后必须编译验证。
3. 每个阶段完成后单独提交。
4. 如果某阶段出现明显回归，优先回滚该阶段，不继续叠加修改。
5. 每次拆分优先保证行为一致，再考虑命名和结构优化。
6. 可选阶段不作为首轮拆分目标。

### 3.2 单阶段工作闭环

每个阶段都按以下闭环执行：

```text
建立子分支
  ↓
确认当前基线
  ↓
执行本阶段拆分
  ↓
本地编译检查
  ↓
功能回归验证
  ↓
清理无用代码
  ↓
提交代码
  ↓
记录阶段结论
```

### 3.3 推荐 Git 分支命名

```text
refactor/index-split
refactor/index-stage0-prepare
refactor/index-stage1-settings
refactor/index-stage2-dialogs
refactor/index-stage3-main-sections
refactor/index-stage4-calendar
refactor/index-stage5-services
refactor/index-stage8-cleanup
refactor/index-stage6-settings-page   # 可选
refactor/index-stage7-viewmodel        # 可选
```

### 3.4 推荐提交格式

```text
refactor(index): prepare split directories and baseline
refactor(index): extract constants and settings components
refactor(index): extract dialog components
refactor(index): extract main page sections
refactor(index): extract calendar components and calculation service
refactor(index): extract import export and preferences services
refactor(index): cleanup split structure
```

---

## 4. 阶段总览与推荐执行顺序

| 执行顺序 | 阶段 | 名称 | 是否必做 | 目标 |
|---|---|---|---|---|
| 1 | 阶段 0 | 准备阶段 | 必做 | 建立基线、目录、分支、回归清单 |
| 2 | 阶段 1 | 常量与设置页拆分 | 必做 | 快速降低 `Index.ets` 文件长度 |
| 3 | 阶段 2 | 弹窗拆分 | 必做 | 清理 `build()` 中的内联弹窗 |
| 4 | 阶段 3 | 主页面展示区拆分 | 必做 | 将主页 UI 组件化 |
| 5 | 阶段 4 | 日历区域拆分 | 必做 | 分离复杂日历 UI 与纯计算逻辑 |
| 6 | 阶段 5 | 导入导出与持久化 service 化 | 必做 | 抽离 IO、文件和存储逻辑 |
| 7 | 阶段 8 | 收尾优化 | 必做 | 清理残余代码、统一命名、补充文档 |
| 8 | 阶段 6 | 设置页页面化 | 可选 | 覆盖层升级为独立页面或导航节点 |
| 9 | 阶段 7 | ViewModel 收敛 | 可选 | 收敛复杂状态管理 |

---

## 5. 阶段 0：准备阶段执行手册

### 5.1 阶段目标

在正式修改 `Index.ets` 之前，建立可验证、可回滚的重构环境。

### 5.2 开始前检查

- 当前工程可正常打开；
- 当前工作区没有无关未提交修改；
- 当前 `Index.ets` 功能表现已知；
- 团队已确认按阶段提交。

### 5.3 执行步骤

#### Step 1：确认工作区状态

```powershell
git status
```

如果有无关修改，先提交或暂存。

#### Step 2：创建重构主分支

```powershell
git checkout -b refactor/index-split
```

如主分支已存在，则切换：

```powershell
git checkout refactor/index-split
```

#### Step 3：记录 `Index.ets` 基线

建议记录以下内容：

- 当前 `Index.ets` 行数；
- 当前主要功能列表；
- 当前已知问题；
- 当前编译结果；
- 当前关键页面截图或录屏。

可使用命令查看行数：

```powershell
(Get-Content main/src/main/ets/pages/Index.ets).Count
```

#### Step 4：创建目录

```powershell
New-Item -ItemType Directory -Force -Path main/src/main/ets/components/index
New-Item -ItemType Directory -Force -Path main/src/main/ets/components/dialogs
New-Item -ItemType Directory -Force -Path main/src/main/ets/constants
New-Item -ItemType Directory -Force -Path main/src/main/ets/service
New-Item -ItemType Directory -Force -Path main/src/main/ets/utils
New-Item -ItemType Directory -Force -Path main/src/main/ets/viewmodel
```

#### Step 5：整理回归测试清单

至少覆盖：

- 应用启动；
- 主页展示；
- 日历展开、折叠、切换；
- 打卡、编辑、删除；
- 设置页打开和关闭；
- 上班时间设置；
- 排除时段增删改；
- 目标工时修改；
- 深色模式切换；
- 导入、导出、清空数据。

### 5.4 阶段产出

- 分支已创建；
- 目录已创建；
- 基线已记录；
- 回归清单已建立。

### 5.5 验证标准

- 工程编译通过；
- 应用仍可运行；
- 没有引入业务代码修改。

### 5.6 建议提交

```powershell
git add .
git commit -m "refactor(index): prepare split directories and baseline"
```

### 5.7 禁止事项

- 不修改 `Index.ets` 业务逻辑；
- 不新增组件代码；
- 不调整路由、状态管理或 service。

---

## 6. 阶段 1：常量与设置页拆分执行手册

### 6.1 阶段目标

先拆最稳定、边界最清晰的内容：常量和设置页 UI 卡片。目标是快速降低 `Index.ets` 长度，同时不改变设置页展示方式。

### 6.2 建议修改文件

新增：

```text
main/src/main/ets/constants/IndexConstants.ets
main/src/main/ets/components/index/SettingsHeader.ets
main/src/main/ets/components/index/WorkdayStartCard.ets
main/src/main/ets/components/index/ExcludedRangesCard.ets
main/src/main/ets/components/index/TargetHoursCard.ets
main/src/main/ets/components/index/DarkModeCard.ets
main/src/main/ets/components/index/DataManagementCard.ets
```

修改：

```text
main/src/main/ets/pages/Index.ets
```

### 6.3 推荐执行顺序

#### Step 1：创建阶段分支

```powershell
git checkout refactor/index-split
git checkout -b refactor/index-stage1-settings
```

#### Step 2：提取常量

在 `IndexConstants.ets` 中提取：

- `HOLIDAYS_2026`
- `WEEKDAY_NAMES`
- `DEFAULT_TARGET_HOURS`
- `DEFAULT_WORKDAY_START`
- `DEFAULT_RANGE_START`
- `DEFAULT_RANGE_END`

执行要点：

1. 先只移动字面量常量；
2. 不修改计算逻辑；
3. 在 `Index.ets` 中使用 import 引入；
4. 编译确认无命名冲突。

#### Step 3：拆 `SettingsHeader`

从 `Index.ets` 中找到 `buildSettingsHeader()`。

组件职责：

- 展示设置页标题；
- 展示返回按钮；
- 根据深色模式调整样式；
- 点击返回时通过 `onBack` 回调通知父组件。

父组件保留状态：

- `showSettingsPage`
- `darkModeEnabled`

#### Step 4：拆 `WorkdayStartCard`

从 `buildSettingsWorkdayStartCard()` 提取。

组件职责：

- 展示上班时间；
- 提供修改入口；
- 不直接修改父页面状态。

回调建议：

```text
onChange
onOpenPicker
```

如果当前代码只有一个入口，优先保持原行为，不强行增加多余回调。

#### Step 5：拆 `ExcludedRangesCard`

从 `buildExcludedRangesCard()` 提取。

组件职责：

- 展示排除时段列表；
- 展示新增、编辑、删除入口；
- 展示删除确认状态。

注意：

- `confirmDeleteIndex` 优先仍由 `Index.ets` 持有；
- 组件只负责根据入参展示确认 UI；
- 删除、确认删除、取消删除都通过回调交给父组件。

#### Step 6：拆 `TargetHoursCard`

从 `buildTargetHoursCard()` 提取。

组件职责：

- 展示目标工时；
- 修改时通过 `onChange` 回调通知父组件。

#### Step 7：拆 `DarkModeCard`

从 `buildDarkModeCard()` 提取。

组件职责：

- 展示深色模式开关；
- 开关变化时触发 `onToggle`。

注意：

- 不在组件内部持久化深色模式；
- 持久化逻辑仍留在父页面或后续 service 阶段处理。

#### Step 8：拆 `DataManagementCard`

从 `buildDataManagementCard()` 提取。

组件职责：

- 展示导入、导出、清空入口；
- 点击后触发父组件回调。

注意：

- 不在本阶段拆导入导出 service；
- 不移动文件 IO 逻辑。

#### Step 9：集成设置页

在 `Index.ets` 中用组件替换原有 `@Builder` 调用。

保留：

- 设置页覆盖层模式；
- 原有状态变量；
- 原有事件处理函数；
- 原有导入导出逻辑。

### 6.4 验证标准

- 设置页能正常打开；
- 返回按钮能关闭设置页；
- 上班时间设置正常；
- 排除时段新增、编辑、删除正常；
- 目标工时修改正常；
- 深色模式切换正常；
- 导入、导出、清空按钮能触发原逻辑；
- 工程编译通过。

### 6.5 建议提交

可拆成两个提交：

```powershell
git add main/src/main/ets/constants main/src/main/ets/pages/Index.ets
git commit -m "refactor(index): extract index constants"
```

```powershell
git add main/src/main/ets/components/index main/src/main/ets/pages/Index.ets
git commit -m "refactor(index): extract settings components"
```

### 6.6 回滚策略

如果设置页出现明显回归：

1. 先回滚设置组件提交；
2. 保留常量提取提交；
3. 如果常量也导致问题，再回滚常量提交。

### 6.7 禁止事项

- 不引入 ViewModel；
- 不把设置页改成独立页面；
- 不拆导入导出 service；
- 不改变设置页交互流程。

---

## 7. 阶段 2：弹窗拆分执行手册

### 7.1 阶段目标

把 `build()` 中直接书写的弹窗 UI 提取成独立组件，降低主页面构建函数复杂度。

### 7.2 建议修改文件

新增：

```text
main/src/main/ets/components/dialogs/RangeEditDialog.ets
main/src/main/ets/components/dialogs/RangeConflictDialog.ets
main/src/main/ets/components/dialogs/ConfirmClearDialog.ets   # 可选
```

修改：

```text
main/src/main/ets/pages/Index.ets
```

### 7.3 推荐执行顺序

#### Step 1：创建阶段分支

```powershell
git checkout refactor/index-split
git checkout -b refactor/index-stage2-dialogs
```

如果阶段 1 尚未合入主分支，应先合并阶段 1。

#### Step 2：拆 `RangeEditDialog`

提取排除时段编辑弹窗。

组件入参建议：

```text
darkModeEnabled
editRangeIndex
rangeStartInput
rangeEndInput
```

回调建议：

```text
onCancel
onConfirm
onPickStart
onPickEnd
```

执行要点：

1. 父组件继续持有输入状态；
2. 弹窗组件负责展示和触发回调；
3. 保存校验逻辑优先保留在父组件；
4. 时间选择逻辑优先保留在父组件。

#### Step 3：拆 `RangeConflictDialog`

提取冲突提示弹窗。

组件入参建议：

```text
darkModeEnabled
```

回调建议：

```text
onConfirm
onClose
```

执行要点：

- 不在弹窗内部判断冲突；
- 冲突判断仍由父页面或后续 service 负责；
- 弹窗只展示提示和按钮。

#### Step 4：评估 `ConfirmClearDialog`

如果当前清空确认使用系统弹窗且逻辑简单，可以暂不拆。

判断标准：

- 如果清空确认 UI 已有自定义遮罩和按钮，可拆；
- 如果只是调用系统 `showDialog`，可保留；
- 如果团队希望统一弹窗风格，再新增 `ConfirmClearDialog.ets`。

#### Step 5：整理 `buildDialogs()`

在 `Index.ets` 中建立或整理弹窗区域构建方法，例如：

```text
buildDialogs()
```

该方法只做弹窗编排，不承载复杂逻辑。

### 7.4 验证标准

- 排除时段弹窗可打开；
- 开始时间选择正常；
- 结束时间选择正常；
- 保存行为正确；
- 取消行为正确；
- 冲突提示弹窗正常；
- 遮罩关闭逻辑正常；
- 工程编译通过。

### 7.5 建议提交

```powershell
git add main/src/main/ets/components/dialogs main/src/main/ets/pages/Index.ets
git commit -m "refactor(index): extract dialog components"
```

### 7.6 禁止事项

- 不在弹窗组件中直接读写页面全局状态；
- 不把校验、持久化、导入导出逻辑塞进弹窗；
- 不修改排除时段业务规则。

---

## 8. 阶段 3：主页面展示区拆分执行手册

### 8.1 阶段目标

将主页核心展示区拆成组件，使 `Index.ets` 从 UI 细节承载者变成页面编排器。

### 8.2 建议修改文件

新增：

```text
main/src/main/ets/components/index/MainHeader.ets
main/src/main/ets/components/index/SummaryCardsSection.ets
main/src/main/ets/components/index/PunchCardSection.ets
main/src/main/ets/components/index/TodayTipButton.ets
```

修改：

```text
main/src/main/ets/pages/Index.ets
```

### 8.3 推荐执行顺序

#### Step 1：创建阶段分支

```powershell
git checkout refactor/index-split
git checkout -b refactor/index-stage3-main-sections
```

#### Step 2：拆 `MainHeader`

提取 `buildMainHeader()`。

组件职责：

- 展示主页标题；
- 展示当前选中日期描述；
- 提供设置入口。

回调：

```text
onOpenSettings
```

#### Step 3：拆 `SummaryCardsSection`

提取 `buildSummaryCards()`。

建议第一轮把 Daily、Weekly、Monthly 卡片保留在同一文件内。

执行要点：

1. 不急着拆成三个单独文件；
2. 确认 `records`、`excludedRanges` 等数据传递完整；
3. 确认 `ForEach` key 稳定；
4. 汇总计算逻辑如暂时复杂，可先保留原函数位置，等阶段 4/5 再抽离。

#### Step 4：拆 `PunchCardSection`

提取打卡区 UI。

回调建议：

```text
onPunch
onEditPunch
onRemovePunch
```

执行要点：

- 打卡数据修改仍由父页面处理；
- 动画状态优先由父页面持有；
- 组件只根据当前状态展示。

#### Step 5：拆 `TodayTipButton`

提取回到今天按钮。

回调：

```text
onClick
```

执行要点：

- 缩放动画状态可先由父组件传入；
- 不在按钮组件内部修改选中日期。

#### Step 6：重组首页布局

建议最终结构接近：

```text
Index.ets
  ├─ MainHeader
  ├─ Scroll
  │   ├─ CalendarCard（阶段 4 再拆）
  │   ├─ SummaryCardsSection
  │   └─ PunchCardSection
  └─ TodayTipButton
```

本阶段暂不拆日历区域。

### 8.4 验证标准

- 主页正常显示；
- 设置按钮正常；
- 汇总数据正确；
- 打卡正常；
- 打卡编辑、删除正常；
- 回到今天按钮正常；
- 深色模式下样式正常；
- 工程编译通过。

### 8.5 建议提交

建议拆成两个提交：

```powershell
git add main/src/main/ets/components/index/MainHeader.ets main/src/main/ets/components/index/SummaryCardsSection.ets main/src/main/ets/pages/Index.ets
git commit -m "refactor(index): extract header and summary section"
```

```powershell
git add main/src/main/ets/components/index/PunchCardSection.ets main/src/main/ets/components/index/TodayTipButton.ets main/src/main/ets/pages/Index.ets
git commit -m "refactor(index): extract punch section and today button"
```

### 8.6 禁止事项

- 不拆日历；
- 不迁移打卡业务逻辑；
- 不重写汇总算法；
- 不调整数据结构。

---

## 9. 阶段 4：日历区域拆分执行手册

### 9.1 阶段目标

拆分复杂日历区域，并把纯计算逻辑提取到 service，降低 UI 和计算逻辑耦合。

### 9.2 建议修改文件

新增：

```text
main/src/main/ets/components/index/CalendarCard.ets
main/src/main/ets/components/index/ExpandedCalendarPanel.ets
main/src/main/ets/components/index/DayCell.ets              # 可选
main/src/main/ets/service/IndexCalendarService.ets
```

修改：

```text
main/src/main/ets/pages/Index.ets
```

### 9.3 推荐执行顺序

#### Step 1：创建阶段分支

```powershell
git checkout refactor/index-split
git checkout -b refactor/index-stage4-calendar
```

#### Step 2：先拆 UI，不动算法

优先提取折叠日历 UI 到 `CalendarCard.ets`。

组件入参：

```text
displayYear
displayMonth
selectedDateKey
records
excludedRanges
darkModeEnabled
calendarWeekOffset
```

回调：

```text
onDateSelected
onToggleExpand
onSwipe
onMonthChange
```

执行要点：

- 第一轮允许继续调用父页面传入的计算结果或函数；
- 先让 UI 拆分稳定；
- 不同时重写日期计算。

#### Step 3：拆展开态日历

提取展开覆盖层到 `ExpandedCalendarPanel.ets`。

执行要点：

- 展开和折叠选中日期逻辑保持一致；
- 月切换、滑动回调仍交给父页面；
- 关闭逻辑由 `onClose` 通知父页面。

#### Step 4：评估是否拆 `DayCell`

如果日历单元格存在以下情况，建议拆：

- UI 层级较深；
- 样式判断很多；
- 折叠态和展开态都重复使用；
- 节假日、工作日、选中态、打卡状态展示逻辑重复。

如果只是少量样式判断，可先不拆，避免文件过度碎片化。

#### Step 5：提取纯计算 service

在 `IndexCalendarService.ets` 中提取纯函数，例如：

```text
buildMonthSlots()
getCurrentWeekSlots()
getExpandedCalendarRows()
getDayCellColor()
```

service 约束：

- 不直接访问页面 `@State`；
- 不直接修改状态；
- 不弹 toast；
- 不操作 UI；
- 输入明确，输出明确；
- 优先使用明确类型，避免 `any`。

#### Step 6：页面接入 service

在 `Index.ets` 中：

1. 保留事件入口；
2. 保留状态变化；
3. 用 service 返回值替换原纯计算函数；
4. 删除已迁移的纯函数。

### 9.4 验证标准

- 折叠态日历显示正常；
- 展开态日历显示正常；
- 日期点击正常；
- 周切换正常；
- 月切换正常；
- 选中态高亮正确；
- 节假日显示正确；
- 工作日显示正确；
- 排除时段显示正确；
- 工程编译通过。

### 9.5 建议提交

建议拆成两个提交：

```powershell
git add main/src/main/ets/components/index/CalendarCard.ets main/src/main/ets/components/index/ExpandedCalendarPanel.ets main/src/main/ets/pages/Index.ets
git commit -m "refactor(index): extract calendar components"
```

```powershell
git add main/src/main/ets/service/IndexCalendarService.ets main/src/main/ets/pages/Index.ets
git commit -m "refactor(index): extract calendar calculation service"
```

### 9.6 禁止事项

- 不把页面事件调度迁到 service；
- 不让 service 修改页面状态；
- 不在同一提交里同时拆 UI、重写算法、改数据结构；
- 不引入 ViewModel。

---

## 10. 阶段 5：导入导出与持久化 service 化执行手册

### 10.1 阶段目标

将文件处理、CSV/ZIP 处理、Preferences 存储访问等逻辑从 `Index.ets` 中抽离，让页面只保留事件入口和 UI 反馈。

### 10.2 建议修改文件

新增：

```text
main/src/main/ets/service/IndexImportExportService.ets
main/src/main/ets/service/IndexPreferencesService.ets
main/src/main/ets/utils/CsvUtils.ets       # 可选
```

修改：

```text
main/src/main/ets/pages/Index.ets
```

如已有权限或文件访问配置，需要检查：

```text
main/src/main/module.json5
```

### 10.3 推荐执行顺序

#### Step 1：创建阶段分支

```powershell
git checkout refactor/index-split
git checkout -b refactor/index-stage5-services
```

#### Step 2：梳理页面中的 IO 函数

在 `Index.ets` 中标记以下逻辑：

- 导出入口；
- 导入入口；
- CSV 生成；
- CSV 解析；
- ZIP 打包；
- ZIP 解包；
- 临时文件清理；
- 数据合并；
- Preferences 读取；
- Preferences 写入。

#### Step 3：提取 `IndexImportExportService`

service 对外建议只暴露少量高层接口，例如：

```text
exportData(...)
importData(...)
```

执行要点：

- 具体参数根据现有数据结构设计；
- 异常通过返回结果或 throw 交给页面处理；
- 不在 service 内直接展示 toast；
- 不在 service 内直接控制弹窗；
- 文件 picker、UIContext、Context 的来源必须清晰。

#### Step 4：按需提取 `CsvUtils`

如果 CSV 处理函数较多，可提取到 `utils/CsvUtils.ets`。

`CsvUtils` 只做纯文本处理：

- CSV 转数据；
- 数据转 CSV；
- 字段转义；
- 行解析；
- 数据合并辅助。

#### Step 5：提取 `IndexPreferencesService`

将 preferences key、默认值、异常处理收敛到 service。

service 对外建议：

```text
loadState(...)
saveState(...)
```

执行要点：

- 默认值统一从 `IndexConstants.ets` 获取；
- 加载失败要返回安全默认值；
- 保存失败要向页面返回异常或结果；
- 页面仍负责把结果赋值给 `@State`。

#### Step 6：改造 `initializeData()`

页面初始化流程建议变成：

```text
aboutToAppear
  ↓
initializeData
  ↓
IndexPreferencesService.loadState
  ↓
页面赋值 @State
  ↓
刷新汇总/日历
```

#### Step 7：页面保留 UI 反馈

`Index.ets` 中仍保留：

- `handleExport()`；
- `handleImport()`；
- toast 展示；
- dialog 展示；
- loading 状态；
- 导入成功后的状态刷新。

### 10.4 权限与配置检查

如果导入导出涉及用户文件选择、媒体库或公共目录访问，需要根据当前 SDK 和实际实现检查权限配置。

可能涉及：

```text
main/src/main/module.json5
```

注意：

- HarmonyOS NEXT 对文件访问权限和用户授权模型较严格；
- 如果使用系统 picker，优先通过 picker 授权的 uri 访问；
- 不要假设可以直接访问任意公共路径；
- 具体权限需根据当前 SDK 文档确认。

### 10.5 验证标准

- 应用启动后历史数据恢复正常；
- 设置项持久化正常；
- 导出成功；
- 导入成功；
- 导入后数据合并正确；
- 临时文件清理无异常；
- 异常情况下页面有提示；
- 工程编译通过。

### 10.6 建议提交

```powershell
git add main/src/main/ets/service/IndexPreferencesService.ets main/src/main/ets/pages/Index.ets
git commit -m "refactor(index): extract preferences service"
```

```powershell
git add main/src/main/ets/service/IndexImportExportService.ets main/src/main/ets/utils main/src/main/ets/pages/Index.ets
git commit -m "refactor(index): extract import export service"
```

### 10.7 禁止事项

- 不在 service 中直接控制 UI；
- 不在 service 中持有页面状态；
- 不把所有业务函数一次性塞进一个巨大 service；
- 不在本阶段引入 ViewModel。

---

## 11. 阶段 8：收尾优化执行手册

### 11.1 阶段目标

主体拆分完成后，对结构、命名、残余代码和文档进行整理。

> 注意：任务清单中阶段 8 排在最后，但实际推荐在必做拆分完成后、可选阶段之前执行。

### 11.2 建议修改文件

可能涉及：

```text
main/src/main/ets/pages/Index.ets
main/src/main/ets/components/index/*.ets
main/src/main/ets/components/dialogs/*.ets
main/src/main/ets/constants/*.ets
main/src/main/ets/service/*.ets
main/src/main/ets/utils/*.ets
README.md 或新增重构说明文档
```

### 11.3 推荐执行顺序

#### Step 1：创建阶段分支

```powershell
git checkout refactor/index-split
git checkout -b refactor/index-stage8-cleanup
```

#### Step 2：清理 `Index.ets`

检查并删除：

- 已废弃的 `@Builder`；
- 无用 import；
- 无用状态变量；
- 已迁移的纯函数；
- 废弃注释；
- 重复样式片段。

#### Step 3：统一命名

检查命名是否一致：

- 组件统一 PascalCase；
- 回调统一 `onXxx`；
- service 统一 `IndexXxxService`；
- 常量统一全大写下划线；
- 工具函数命名表达输入输出含义。

#### Step 4：检查拆分粒度

重点检查两类问题：

1. 仍然职责混杂的文件；
2. 拆得过碎、维护成本变高的文件。

如果某些组件只有几行且没有复用价值，可以考虑合并回父组件或同类组件文件中。

#### Step 5：补充文档

建议补充：

- 最终目录结构；
- 每个组件职责；
- 每个 service 职责；
- 后续可选优化方向；
- 已知未处理问题。

### 11.4 验证标准

- 全量功能回归通过；
- 编译通过；
- 无明显无用 import；
- `Index.ets` 只保留页面编排、状态入口、事件调度；
- 组件只做展示和回调；
- service 不直接控制 UI。

### 11.5 建议提交

```powershell
git add .
git commit -m "refactor(index): cleanup split structure"
```

### 11.6 禁止事项

- 不在收尾阶段引入新的大功能；
- 不在收尾阶段大改状态模型；
- 不在收尾阶段重写业务规则。

---

## 12. 阶段 6：设置页页面化执行手册（可选）

### 12.1 是否进入本阶段

只有满足以下至少一项时，才建议进入：

- 设置页覆盖层逻辑仍然复杂；
- 设置页需要独立生命周期；
- 设置页后续会继续扩展多个模块；
- 设置页返回、手势、遮罩逻辑维护成本较高；
- 团队希望统一使用 Navigation 或 router 管理页面。

如果当前覆盖层已经稳定，可以不做本阶段。

### 12.2 建议修改文件

可能新增：

```text
main/src/main/ets/pages/SettingsPage.ets
```

可能修改：

```text
main/src/main/ets/pages/Index.ets
main/src/main/module.json5   # 如使用 router 且需要配置页面路径，需根据项目结构确认
```

### 12.3 推荐执行顺序

#### Step 1：确定导航方案

优先根据项目已有结构选择：

- 如果项目已经使用 `Navigation/NavDestination`，优先继续使用 Navigation；
- 如果项目当前使用 `router`，可以沿用 router；
- 不建议为了设置页单独引入完全不同的导航体系。

#### Step 2：新建 `SettingsPage.ets`

将阶段 1 已拆出的设置组件组合到独立页面中。

#### Step 3：迁移状态来源

需要明确：

- 设置项状态从哪里传入；
- 修改后如何回写；
- 返回主页后如何刷新；
- 是否依赖 preferences service。

#### Step 4：替换 `showSettingsPage`

将覆盖层控制迁移为页面跳转控制。

#### Step 5：处理返回逻辑

包括：

- 系统返回；
- 页面返回按钮；
- 手势返回；
- 未保存状态处理。

### 12.4 验证标准

- 主页可进入设置页；
- 设置页可返回主页；
- 设置项修改正常；
- 深色模式正常；
- 数据管理入口正常；
- 页面切换动画符合预期；
- 工程编译通过。

### 12.5 禁止事项

- 不和 ViewModel 收敛放在同一阶段；
- 不同时改设置项持久化规则；
- 不强行引入新的导航体系。

---

## 13. 阶段 7：ViewModel 收敛执行手册（可选）

### 13.1 是否进入本阶段

只有满足以下多数条件时才建议进入：

- `Index.ets` 中剩余 `@State` 仍然很多；
- 多个组件共享复杂状态；
- 参数传递链路过长；
- 后续仍有较大功能扩展；
- service 和 UI 已经基本拆分完成。

如果只是为了“看起来架构更完整”，不建议进入本阶段。

### 13.2 建议修改文件

可能新增：

```text
main/src/main/ets/viewmodel/IndexViewModel.ets
main/src/main/ets/viewmodel/SettingsViewModel.ets   # 可选
```

修改：

```text
main/src/main/ets/pages/Index.ets
main/src/main/ets/pages/SettingsPage.ets            # 如果阶段 6 已执行
main/src/main/ets/components/index/*.ets
```

### 13.3 推荐执行顺序

#### Step 1：梳理状态分类

建议分为：

- 页面展示状态；
- 日历状态；
- 设置状态；
- 弹窗状态；
- 导入导出状态；
- 动画状态。

#### Step 2：确定首批迁移状态

优先迁移低风险状态，例如：

- 设置相关普通值；
- 弹窗显示状态；
- 日历显示年月等。

暂缓迁移：

- 动画状态；
- 高频变化状态；
- 与生命周期强相关状态。

#### Step 3：建立 `IndexViewModel`

要求：

- 类型明确；
- 状态职责清晰；
- 不直接控制 UI；
- 不和 service 职责混淆。

#### Step 4：逐步替换页面状态

一次只迁移一组状态，每迁移一组都要验证。

#### Step 5：评估 `SettingsViewModel`

只有设置页逻辑已经足够独立时再拆第二个 ViewModel。

### 13.4 验证标准

- 页面刷新正常；
- 子组件联动正常；
- 不出现观察链异常；
- 设置项修改正常；
- 日历切换正常；
- 弹窗显示正常；
- 工程编译通过。

### 13.5 禁止事项

- 不一次性迁移全部状态；
- 不把 service 变成 ViewModel；
- 不把 UIContext、toast、dialog 塞进 ViewModel；
- 不和页面化阶段混做。

---

## 14. 全阶段回归测试手册

每个阶段完成后至少执行一次本清单。

### 14.1 主页面

- [ ] 应用可以正常启动；
- [ ] 主标题显示正常；
- [ ] 当前日期描述正确；
- [ ] 设置入口可点击；
- [ ] 汇总区显示正常；
- [ ] 打卡区显示正常；
- [ ] 回到今天按钮显示和行为正常。

### 14.2 日历

- [ ] 折叠态日历显示正常；
- [ ] 展开态日历显示正常；
- [ ] 点击日期可切换选中日期；
- [ ] 周切换正常；
- [ ] 月切换正常；
- [ ] 今日高亮正常；
- [ ] 选中日期高亮正常；
- [ ] 节假日样式正常；
- [ ] 工作日样式正常；
- [ ] 排除时段影响显示正常。

### 14.3 打卡

- [ ] 新增打卡正常；
- [ ] 编辑打卡正常；
- [ ] 删除打卡正常；
- [ ] 打卡后汇总刷新正常；
- [ ] 切换日期后数据正确。

### 14.4 设置页

- [ ] 设置页打开正常；
- [ ] 设置页关闭正常；
- [ ] 上班时间设置正常；
- [ ] 排除时段新增正常；
- [ ] 排除时段编辑正常；
- [ ] 排除时段删除正常；
- [ ] 目标工时修改正常；
- [ ] 深色模式切换正常。

### 14.5 弹窗

- [ ] 排除时段编辑弹窗正常；
- [ ] 时间选择正常；
- [ ] 保存正常；
- [ ] 取消正常；
- [ ] 冲突弹窗正常；
- [ ] 遮罩点击逻辑正常。

### 14.6 数据

- [ ] 应用重启后历史数据恢复正常；
- [ ] 设置项持久化正常；
- [ ] 导出成功；
- [ ] 导入成功；
- [ ] 导入后数据合并正确；
- [ ] 清空逻辑正常；
- [ ] 异常场景有提示。

### 14.7 编译检查

每个阶段完成后执行工程编译。

如果使用 DevEco Studio：

- 执行 Build；
- 检查 Problems 面板；
- 启动预览或模拟器运行。

---

## 15. 回滚手册

### 15.1 何时回滚

出现以下情况建议回滚当前阶段：

- 编译错误短时间无法修复；
- 核心功能明显回归；
- 状态链路混乱；
- 某阶段改动扩散到非目标范围；
- 需要修改业务规则才能继续。

### 15.2 回滚方式

如果阶段尚未提交：

```powershell
git status
git restore .
```

如果阶段已经提交但未合并：

```powershell
git checkout refactor/index-split
git branch -D refactor/index-stageX-xxx
```

如果阶段提交已合并，需要 revert：

```powershell
git revert <commit-id>
```

### 15.3 回滚后处理

- 记录回滚原因；
- 缩小下次改动范围；
- 优先恢复到上一个可运行阶段；
- 不在问题未定位前继续推进后续阶段。

---

## 16. 阶段验收模板

每完成一个阶段，建议记录以下内容：

```markdown
## 阶段 X 验收记录

### 完成时间
- 日期：
- 执行人：

### 修改摘要
- 

### 新增文件
- 

### 修改文件
- 

### 编译结果
- [ ] 通过
- [ ] 不通过，原因：

### 回归结果
- [ ] 主页面通过
- [ ] 日历通过
- [ ] 设置页通过
- [ ] 弹窗通过
- [ ] 数据导入导出通过

### 已知问题
- 

### 是否允许进入下一阶段
- [ ] 是
- [ ] 否，原因：
```

---

## 17. 最终目标状态

重构完成后，推荐结构如下：

```text
main/src/main/ets
├─ pages
│  ├─ Index.ets
│  └─ SettingsPage.ets                    # 可选
├─ components
│  ├─ index
│  │  ├─ MainHeader.ets
│  │  ├─ SettingsHeader.ets
│  │  ├─ WorkdayStartCard.ets
│  │  ├─ ExcludedRangesCard.ets
│  │  ├─ TargetHoursCard.ets
│  │  ├─ DarkModeCard.ets
│  │  ├─ DataManagementCard.ets
│  │  ├─ SummaryCardsSection.ets
│  │  ├─ PunchCardSection.ets
│  │  ├─ TodayTipButton.ets
│  │  ├─ CalendarCard.ets
│  │  ├─ ExpandedCalendarPanel.ets
│  │  └─ DayCell.ets                       # 可选
│  └─ dialogs
│     ├─ RangeEditDialog.ets
│     ├─ RangeConflictDialog.ets
│     └─ ConfirmClearDialog.ets            # 可选
├─ constants
│  └─ IndexConstants.ets
├─ service
│  ├─ IndexCalendarService.ets
│  ├─ IndexImportExportService.ets
│  └─ IndexPreferencesService.ets
├─ utils
│  └─ CsvUtils.ets                         # 可选
└─ viewmodel
   ├─ IndexViewModel.ets                   # 可选
   └─ SettingsViewModel.ets                # 可选
```

最终职责划分：

| 模块 | 职责 |
|---|---|
| `Index.ets` | 页面编排、状态入口、事件调度、UI 反馈 |
| `components/index` | 首页和设置页展示组件 |
| `components/dialogs` | 弹窗展示组件 |
| `constants` | 默认值、固定文案、固定配置 |
| `service` | 纯计算、导入导出、持久化访问 |
| `utils` | 无状态工具函数 |
| `viewmodel` | 可选状态收敛 |

---

## 18. 最终结论

本次拆分不应追求一次性架构升级，而应按以下优先级推进：

1. 先拆常量和设置页；
2. 再拆弹窗；
3. 再拆主页展示区；
4. 再拆日历 UI 和纯计算；
5. 再拆导入导出与持久化 service；
6. 最后清理命名和文档；
7. 设置页页面化与 ViewModel 收敛只在确有必要时执行。

这样可以在最小风险下，把 `Index.ets` 从“大型一体化页面”逐步演进为：

```text
页面编排器 + 展示组件 + 弹窗组件 + 纯计算 service + IO service
```

从而显著提升可维护性、可测试性和后续扩展能力。
