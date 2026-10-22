# frozen_string_literal: true

require "jekyll"
require "nokogiri"

site = Jekyll::Site.new(Jekyll.configuration("source" => Dir.pwd, "quiet" => true))
source = File.read("_layouts/home-profile.html").sub(/\A---.*?---\s*/m, "")
template = Liquid::Template.parse(source)
render_home = lambda do |posts, stats = { "available" => false }|
  html = template.render!(
    { "site" => { "posts" => posts, "data" => { "visitor_stats" => stats },
                  "avatar" => "/assets/img/avatar.svg", "social" => { "name" => "MayL" } } },
    registers: { site: site }
  )
  Nokogiri::HTML.fragment(html)
end
post = { "title" => "最新笔记", "date" => Time.iso8601("2026-10-22T10:00:00+08:00"),
         "url" => "/posts/latest/", "excerpt" => "<p>正文自动摘要</p>" }
old_pinned = post.merge("date" => Time.iso8601("2026-10-20T10:00:00+08:00"),
                        "title" => "旧的置顶文章", "pin" => true)
latest = render_home.call([post, old_pinned])
summary = render_home.call([post.merge("description" => "<strong>摘要</strong>" + "长文" * 200)]).at_css(".latest-post-summary")
empty = render_home.call([])
stats = { "available" => true, "total_visits" => 10,
          "countries" => [{ "code" => "CN", "name" => "China", "visits" => 10 }],
          "display_countries" => [{ "code" => "US", "source" => "gdp_fallback" }] }
countries = render_home.call([post], stats)
checks = {
  "最新发布日期优先于顺序与置顶" => latest.at_css("#latest-post-title").text.strip == "最新笔记",
  "摘要链接指向文章" => latest.at_css("#latest-post-title a")["href"] == "/posts/latest/",
  "优先显示已有摘要" => render_home.call([post.merge("description" => "**已有摘要**")]).at_css(".latest-post-summary").text == "已有摘要",
  "缺少描述时自动截取正文" => render_home.call([post.merge("description" => "")]).at_css(".latest-post-summary").text == "正文自动摘要",
  "摘要限制长度且不输出 HTML" => summary.text.length <= 260 && summary.element_children.empty?,
  "无文章时显示空状态" => empty.at_css("#latest-post").nil? && !empty.at_css(".latest-post-empty").nil?,
  "统计失败显示不可用状态" => !empty.at_css(".visitor-unavailable").nil?,
  "仅显示真实国家来源" => countries.css(".visitor-country span").map(&:text) == ["CN"],
  "国旗尺寸保持紧凑" => countries.at_css(".visitor-flag")["width"] == "20"
}
failures = checks.reject { |_name, passed| passed }.keys
abort failures.join("\n") unless failures.empty?
puts "首页模板验证通过（#{checks.length} 项）"
