# frozen_string_literal: true

require "date"
require "time"
require "yaml"

site = ARGV.fetch(0, "_site")
home_path = File.join(site, "index.html")
abort "找不到生成的首页：#{home_path}" unless File.file?(home_path)

home = File.read(home_path, encoding: "UTF-8")
visitor_ranking_ready =
  home.scan(/class="visitor-country(?: |")/).length <= 15 &&
  home.include?('class="visitor-ranking"') &&
  !home.include?("GDP 榜单补位")
visitor_fallback_ready = home.include?('class="visitor-unavailable"')

checks = {
  "首页包含个人介绍布局" => home.include?('id="home-profile"'),
  "首页包含累计访问" => home.include?('id="visitor-total-value"'),
  "首页包含完整访客榜或不可用状态" => visitor_ranking_ready || visitor_fallback_ready,
  "首页不再加载世界地图" => !home.include?("jsvectormap"),
  "首页没有文章列表" => !home.match?(/id=["']post-list|class=["'][^"']*post-list/),
  "首页侧栏面板被专用样式隐藏" => home.include?("/assets/css/home.css"),
  "侧栏不包含主题切换" => !home.include?('id="mode-toggle"'),
  "首页没有个人社交入口" => !home.match?(/aria-label="(?:github|email|facebook|x)"|class="profile-actions"/),
  "首页包含最新文章摘要" => home.include?('id="latest-post"') && home.match?(/class="latest-post-summary">[^<]+<\/p>/),
  "最新文章位于访客足迹上方" => home.index('id="latest-post"').to_i < home.index('class="visitor-card"').to_i,
  "没有分页首页" => !File.exist?(File.join(site, "page2", "index.html")),
  "旧项目地址保留跳转" => File.file?(File.join(site, "skills-github-pages", "index.html"))
}

post_path = Dir.glob(File.join(site, "posts", "**", "index.html")).first
checks["至少生成一篇文章"] = !post_path.nil?
source_posts = Dir.glob(File.join("_posts", "**", "*.{md,markdown,html}"))
generated_posts = Dir.glob(File.join(site, "posts", "**", "index.html"))
checks["文章均按年月目录存放"] = source_posts.all? do |path|
  path.tr("\\", "/").match?(%r{\A_posts/\d{4}/\d{2}/\d{4}-\d{2}-\d{2}-.+\.(?:md|markdown|html)\z})
end
config = YAML.safe_load(File.read("_config.yml"), permitted_classes: [Date, Time])
published_posts = source_posts.select do |path|
  content = File.read(path, encoding: "UTF-8")
  front_matter = content.match(/\A---\s*\r?\n(.*?)\r?\n---\s*\r?\n/m)
  metadata = front_matter ? YAML.safe_load(front_matter[1], permitted_classes: [Date, Time]) || {} : {}
  next false if metadata["published"] == false

  date = metadata["date"] || File.basename(path)[0, 10]
  config["future"] || Time.parse(date.to_s) <= Time.now
end
checks["递归目录中应发布的文章全部生成"] = generated_posts.length == published_posts.length
latest_date = published_posts.map do |path|
  content = File.read(path, encoding: "UTF-8")
  metadata = YAML.safe_load(content.match(/\A---\s*\r?\n(.*?)\r?\n---/m)[1], permitted_classes: [Date, Time])
  Time.parse((metadata["date"] || File.basename(path)[0, 10]).to_s)
end.max
checks["首页自动选择发布日期最新的文章"] = latest_date && home.include?('datetime="' + latest_date.iso8601 + '"')
about = File.read(File.join(site, "about", "index.html"), encoding: "UTF-8")
checks["联系方式集中于关于页"] = about.include?('class="about-contact"') &&
  about.include?("https://github.com/") && about.include?("mailto:") &&
  about.include?("https://x.com/") && about.include?("https://www.facebook.com/")
checks["全站不输出壁纸文件"] = Dir.glob(File.join(site, "**", "wallpaper_full.jpg")).empty?
if post_path
  post = File.read(post_path, encoding: "UTF-8")
  checks["文章页不公开阅读次数"] = !post.include?('id="pageviews"')
  checks["文章页不加载首页国旗资源"] = !post.include?("flag-icons")
end

html_files = Dir.glob(File.join(site, "**", "*.html"))
checks["所有内容页面加载 GoatCounter"] = html_files.all? do |path|
  html = File.read(path, encoding: "UTF-8")
  html.include?('http-equiv="refresh"') || html.include?("gc.zgo.at/count.js")
end

checks["所有页面均无主题切换和侧栏社交入口"] = html_files.all? do |path|
  html = File.read(path, encoding: "UTF-8")
  sidebar = html[/<aside[^>]*id="sidebar".*?<\/aside>/m].to_s
  !html.include?('id="mode-toggle"') && !sidebar.match?(/mailto:|https:\/\/(?:github|x|www\.facebook)\.com/)
end

public_files = Dir.glob(File.join(site, "**", "*.{html,js,json,css}"))
checks["公开文件不含 API Secret 名称或认证头"] = public_files.none? do |path|
  content = File.binread(path)
  content.include?("GOATCOUNTER_API_KEY") || content.include?("Authorization: Bearer")
end

failures = checks.reject { |_name, passed| passed }.keys
if failures.empty?
  puts "站点输出验证通过（#{checks.length} 项）"
else
  warn "站点输出验证失败："
  failures.each { |failure| warn "- #{failure}" }
  exit 1
end
