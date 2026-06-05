# ho_work_time_record

HarmonyOS / ArkTS 工时记录应用，用于记录每日上下班打卡时间、计算当日工时和月平均工时，并支持本地数据导入导出。

## 功能

- 首页打卡、编辑上下班时间。
- 周历和月历浏览打卡记录。
- 设置上班起始时间、排除时段、目标平均工时和深色模式。
- CSV / ZIP 导入导出打卡记录。
- Preferences 本地持久化。

## 业务规则

- 少于两次打卡时，当日工时为 0。
- 多次打卡时，当前按最早一次和最晚一次计算。
- 如果最早打卡早于设置的上班起始时间，则从上班起始时间开始计算。
- 排除时段会从工作区间中扣除，例如午休时间。
- 月平均工时按当月有有效工时的记录天数计算。
- 当前版本不内置节假日或工作日规则。

## 目录结构

```text
AppScope/                         应用级配置和资源
main/src/main/ets/pages/          页面入口
main/src/main/ets/components/     页面组件
main/src/main/ets/service/        业务服务、持久化、导入导出
main/src/main/ets/utils/          通用工具
main/src/main/ets/model/          数据模型
main/src/main/ets/constants/      常量
main/src/test/                    本地单元测试
main/src/ohosTest/                设备/能力测试
```

## 数据导入导出

导出会按月份生成 CSV 并压缩为 ZIP。CSV 基本格式如下：

```csv
日期,上班打卡时间,下班打卡时间
2026-06-01,09:00,18:30
```

导入支持 `.csv` 和 `.zip`。同一日期的导入记录会覆盖已有记录。

## 开发

使用 DevEco Studio 打开项目根目录 `D:\coding\ho_work_time_record` 后，可通过 IDE 运行、构建和执行测试。

建议提交前至少检查：

- 本地单元测试。
- 代码检查配置 `code-linter.json5`。
- 首页打卡、设置保存、导入导出三个核心流程。

## 持久化

当前 Preferences 使用带 `schemaVersion` 的 JSON 状态保存主要数据，并保留旧字段读取兼容。首次读取旧格式成功后会自动写回新格式。
