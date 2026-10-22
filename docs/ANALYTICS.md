# GoatCounter 访问统计与国家榜单

## 当前设计

- 线上站点使用 `mayl.goatcounter.com`，`_config.yml` 中的 `analytics.goatcounter.id: mayl` 让 GoatCounter 在生产环境跟踪全站。
- `pageviews.provider` 保持为空，因此文章标题下不公开阅读次数。
- 首页以紧凑区域显示累计访问数及最多 15 个真实来源的国旗和两位国家/地区代码，具体访问次数放在悬停提示中。数据是 GitHub Actions 在构建前读取的快照，浏览器不会接触 API Token。
- Pull Request 使用 `test/fixtures/visitor-stats.json` 测试数据，只验证页面布局。测试数据带有 `fixture: true` 标记。
- 公开文件只含国家级汇总，不含 IP、城市、设备标识、浏览器或单次访问明细。

统计开始时间固定为 `2026-09-26T00:00:00+08:00`。GoatCounter 的 `visit` 大致把八小时内对同一路径的重复访问视为同一次访问，因此累计访问不是刷新次数，也不是永久唯一用户数。国家和地区由访问 IP 推断，VPN、代理、运营商出口和共享网络都会影响准确性；GoatCounter 不会把 IP 写入本站公开数据。

## 创建 API Token 和 GitHub Secret

1. 登录 <https://mayl.goatcounter.com/>，从用户菜单打开 **API**。
2. 创建专用于部署的 Token，只授予 **read sites** 和 **read statistics** 权限。
3. 打开 GitHub 仓库 **Settings → Secrets and variables → Actions**。
4. 新建 Repository secret，名称必须是 `GOATCOUNTER_API_KEY`，值为刚创建的 Token。

Token 只能保存在 GitHub Actions Secret 中。不要把它放进 `_config.yml`、本地数据文件、提交记录、Issue 或构建日志。工作流通过请求头使用 Token，脚本的成功和错误输出不会打印它。

## 数据生成与发布

`tools/fetch-visitor-stats.rb` 在生产构建前调用：

- `/api/v0/stats/total` 获取累计访问数；
- `/api/v0/stats/locations` 按页读取全部国家和地区；
- 校验 HTTP 状态、JSON 结构、非负计数和 ISO 3166-1 alpha-2 国家代码；
- 合并重复国家代码，将无法识别的代码计入“未知地区”；
- 原子写入 `_data/visitor_stats_generated.json`。

脚本保留全部国家汇总及兼容字段 `display_countries`。首页直接使用按访问量排序的 `countries`，最多展示 15 项，不再显示 GDP 补位项。国旗来自仓库内固定的 `flag-icons 7.5.0` SVG，不会向第三方图片服务发送访客请求。

生成文件被 `.gitignore` 排除，只存在于当次 Actions 工作区和最终静态站点中。工作流只在推送到 `main` 或手动运行时读取真实数据，没有定时任务。要单独刷新首页数字，在仓库 **Actions → Build and Deploy → Run workflow** 中选择 `main` 运行。

本地预览默认显示统计不可用状态。需要检查完整布局时，可以临时复制测试数据：

```powershell
Copy-Item test/fixtures/visitor-stats.json _data/visitor_stats_generated.json
./tools/preview.ps1
```

测试文件已被忽略，不应提交。完成检查后可删除 `_data/visitor_stats_generated.json`。

## 失败策略与排查

缺少 Token、401、403、429、服务异常、非法 JSON 或字段不符合约定时，抓取脚本以非零状态退出。部署工作流最多重试三次，仍失败时使用内置不可用状态继续构建，不会伪造零访问数据。

- **缺少 Token**：确认 Secret 名称精确为 `GOATCOUNTER_API_KEY`，并且运行事件是 `main` 推送或手动执行。PR 不读取 Secret。
- **401**：重新创建 Token 或检查复制值是否完整。
- **403**：确认 Token 同时具有 read sites 和 read statistics 权限。
- **429**：等待一段时间后手动重新运行；脚本按页请求且低于正常 API 使用频率。
- **5xx 或连接失败**：查看 GoatCounter 服务状态，稍后重新运行。
- **首页数字没有变化**：统计只随部署更新；确认最新 `Build and Deploy` 已成功完成，并硬刷新浏览器。
- **后台有数据但榜单没有对应国家**：部分访问可能没有可用国家代码，会归入未知地区；检查 Actions 的统计准备步骤是否成功。

本地运行抓取器会访问真实 API，应只在临时环境变量中提供 Token：

```powershell
$env:GOATCOUNTER_API_KEY = "仅在当前终端设置的值"
ruby tools/fetch-visitor-stats.rb _data/visitor_stats_generated.json
Remove-Item Env:GOATCOUNTER_API_KEY
```

## 官方资料

- [GoatCounter API](https://www.goatcounter.com/help/api)
- [GoatCounter 隐私设计](https://www.goatcounter.com/help/privacy)
- [访问计数说明](https://www.goatcounter.com/help/visitor-counter)
