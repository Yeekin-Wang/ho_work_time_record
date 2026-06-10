# ho_work_time_record

`ho_work_time_record` 是一个 HarmonyOS / ArkTS 工时记录应用，用于记录每天的上班、下班打卡时间，并根据可配置规则计算当日工时、当月平均工时和目标差距。

## 功能概览

- 首页快捷打卡：记录当前时间为所选日期的一次打卡记录。
- 打卡时间编辑：可手动调整所选日期的上班、下班时间。
- 周历 / 月历查看：默认展示当前周，可展开为月历，并在日期上标记打卡次数。
- 工时汇总：展示目标平均工时、当前月平均工时，以及与目标的差距。
- 规则配置：支持设置上班起算时间、排除时段和每日目标工时。
- 主题模式：支持浅色、深色、跟随系统。
- 数据管理：支持 CSV / ZIP 导入导出，以及清空打卡记录。
- 本地持久化：使用 Preferences 保存打卡记录、设置项、主题和当前显示状态。

## 业务规则

- 同一天少于两次打卡时，当日有效工时为 0。
- 同一天多次打卡时，使用最早一次作为上班时间、最晚一次作为下班时间参与计算。
- 如果最早打卡时间早于设置的上班起算时间，则从上班起算时间开始计算。
- 排除时段会从有效工作区间中扣除，例如午休 `12:00-13:00`。
- 当月平均工时只统计当月有效工时大于 0 的日期。
- 目标工时范围限制在 6 到 12 小时之间，并保留 1 位小数。
- 当前版本未内置节假日、调休或工作日规则。

## 页面说明

- `pages/Index`：主打卡页，包含顶部信息、周历/月历、打卡卡片和月度汇总。
- `pages/SettingsPage`：设置页，包含上班起算时间、排除时段、目标工时、主题模式和数据管理。
- `pages/CustomTimePickerDialog`：自定义时间选择弹窗，用于编辑打卡时间和设置时间段。

## 数据导入导出

导出会按月份生成 CSV 文件，并打包为 ZIP。无打卡记录时会导出一份导入模板。

CSV 基本格式：

```csv
日期,上班打卡时间,下班打卡时间
2026-06-01,09:00,18:30
```

导入规则：

- 支持选择 `.csv` 或 `.zip` 文件。
- ZIP 内会解析所有 `.csv` 文件。
- 日期格式为 `YYYY-MM-DD`，时间格式为 `HH:mm`。
- 以 `#` 开头的说明行会被忽略。
- 同一天导入记录会覆盖本地已有记录。
- 如果某天只有一次打卡，下班时间可留空。

## 持久化

应用通过 `@kit.ArkData` 的 Preferences 保存数据，首选使用带 `schemaVersion` 的 JSON 状态：

- 当前选中日期和展示月份。
- 目标平均工时。
- 上班起算时间。
- 排除时段列表。
- 每日打卡记录。
- 主题模式。

`IndexPreferencesService` 保留了旧字段读取逻辑，首次读取旧格式成功后会自动写回为新 JSON 格式。

## 项目结构

```text
AppScope/                              应用级配置和图标资源
main/src/main/ets/pages/               页面入口
main/src/main/ets/components/index/    首页和设置页组件
main/src/main/ets/components/dialogs/  弹窗组件
main/src/main/ets/service/             工时计算、日历、状态、主题、导入导出等服务
main/src/main/ets/model/               数据模型
main/src/main/ets/utils/               通用工具，例如 CSV 解析和生成
main/src/main/ets/constants/           默认值和常量
main/src/main/resources/               字符串、颜色、媒体等模块资源
main/src/test/                         本地单元测试
main/src/ohosTest/                     设备 / Ability 测试
```

## 开发环境

- HarmonyOS 工程模型：`modelVersion` 为 `6.1.0`。
- 目标 SDK：`6.1.0(23)`。
- 支持设备类型：phone、tablet、2in1。
- 测试依赖：`@ohos/hypium`、`@ohos/hamock`。

使用 DevEco Studio 打开项目根目录：

```text
D:\coding\ho_work_time_record
```

然后通过 IDE 完成同步、构建、运行和测试。

## 测试关注点

当前本地测试覆盖了以下核心逻辑：

- `TimeUtils`：时间解析、日期校验。
- `PunchCalculator`：工时计算、排除时段扣除、月平均工时。
- `CsvUtils`：CSV 解析、注释行忽略、同日期导入覆盖合并。

提交前建议至少检查：

- 本地单元测试。
- 首页打卡、编辑时间、切换日期。
- 设置页保存上班起算时间、排除时段、目标工时和主题模式。
- CSV / ZIP 导入导出。
- 清空记录是否只删除打卡数据，不影响设置项。
