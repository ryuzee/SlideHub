class SitemapController < ApplicationController
  def index
    @slides = Slide.published.latest
    # 公開中のスライドがあるカテゴリだけ（空のカテゴリは中身がないので検索エンジンに知らせない）
    @categories = Category.where(id: Slide.published.select(:category_id)).order('id asc')
    @pages = Page.order('id asc')
    @users = User.where(id: Slide.published.select(:user_id))

    respond_to do |format| # rubocop:disable Style/SymbolProc -- Rails の定番の書き方のままにする
      format.xml
    end
  end
end
