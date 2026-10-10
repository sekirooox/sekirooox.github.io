# frozen_string_literal: true

site = ARGV.fetch(0, "_site")
home_path = File.join(site, "index.html")
abort "找不到生成的首页：#{home_path}" unless File.file?(home_path)

home = File.read(home_path, encoding: "UTF-8")
checks = {
  "首页包含个人介绍布局" => home.include?('id="home-profile"'),
  "首页包含累计访问" => home.include?('id="visitor-total-value"'),
  "首页包含十五项国家访问榜" => home.scan(/class="visitor-country(?: |")/).length == 15,
  "首页包含自托管国旗" => home.include?("/assets/vendor/flag-icons/flags/4x3/"),
  "首页不再加载世界地图" => !home.include?("jsvectormap"),
  "首页没有文章列表" => !home.match?(/id=["']post-list|class=["'][^"']*post-list/),
  "首页侧栏面板被专用样式隐藏" => home.include?("/assets/css/home.css"),
  "侧栏包含主题切换按钮" => home.include?('id="mode-toggle"'),
  "侧栏包含 GitHub 入口" => home.include?('href="https://github.com/sekirooox"') && home.include?('aria-label="github"'),
  "侧栏包含邮件入口" => home.include?("mailto:' + ['ml1353578','stu2023.jnu.edu.cn']") && home.include?('aria-label="email"'),
  "侧栏包含 Facebook 入口" => home.include?('href="https://www.facebook.com/profile.php?id=61594827508707"') && home.include?('aria-label="facebook"'),
  "侧栏包含 X 入口" => home.include?('href="https://x.com/MayL2btr"') && home.include?('aria-label="x"'),
  "侧栏关闭 RSS/XML 入口" => !home.include?('aria-label="rss"'),
  "外部社交链接隔离 opener" => home.scan('target="_blank" rel="noopener noreferrer"').length >= 3,
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
checks["递归目录中的文章全部生成"] = generated_posts.length == source_posts.length
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
