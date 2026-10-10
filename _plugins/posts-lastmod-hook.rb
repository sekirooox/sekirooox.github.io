#!/usr/bin/env ruby
#
# Check for changed posts

Jekyll::Hooks.register :posts, :post_init do |post|

  # Posts live in year/month subdirectories. Follow renames so reorganizing a
  # post does not discard its existing Git-based modification history.
  commit_num = `git log --follow --format="%H" -- "#{ post.path }"`.lines.length

  if commit_num.to_i > 1
    lastmod_date = `git log -1 --follow --pretty="%ad" --date=iso -- "#{ post.path }"`
    post.data['last_modified_at'] = lastmod_date
  end

end
