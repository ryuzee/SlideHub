# サブドメインごとにホストが変わるため、Sitemapの絶対URLを動的に出す
class RobotsController < ApplicationController
  skip_before_action :authenticate_user!, raise: false

  def index
    render plain: robots_body, content_type: 'text/plain'
  end

  private

    def robots_body
      # ログイン必須のサイトはクロールさせない
      return "User-agent: *\nDisallow: /\n" if Rails.application.config.slidehub.login_required == '1'

      <<~ROBOTS
        User-agent: *
        Disallow: /admin/
        Disallow: /users/sign_in
        Disallow: /users/sign_up
        Disallow: /users/password

        Sitemap: #{sitemap_url}
      ROBOTS
    end
end
