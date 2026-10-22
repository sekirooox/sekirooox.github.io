# frozen_string_literal: true

require "uri"

module MaylBlog
  # 从 _config.yml 的 social.links 为关于页社交入口补充 URL。
  # 只接受 HTTPS 且主机名与 contact.yml 声明一致的链接。
  class SocialContactGenerator < Jekyll::Generator
    safe true
    priority :low

    def generate(site)
      social_links = Array(site.config.dig("social", "links")).filter_map do |value|
        parse_https_url(value)
      end

      Array(site.data["contact"]).each do |entry|
        expected_host = entry["social_host"].to_s.downcase
        next if expected_host.empty?

        match = social_links.find { |uri| trusted_host?(uri.host, expected_host) }
        entry["url"] = match&.to_s
      end
    end

    private

    def parse_https_url(value)
      uri = URI.parse(value.to_s)
      return unless uri.is_a?(URI::HTTPS) && uri.host && !uri.userinfo

      uri
    rescue URI::InvalidURIError
      nil
    end

    def trusted_host?(actual_host, expected_host)
      actual = actual_host.to_s.downcase
      actual == expected_host || actual.end_with?(".#{expected_host}")
    end
  end
end
