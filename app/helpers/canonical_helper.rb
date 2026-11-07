# 検索エンジンに伝える正規の URL（canonical）。
# 同じ内容が別の URL（/users/1 と /:username、/slides/latest と /latest など）でも出るので、
# 各ページで 1 つの URL にそろえる。2 ページ目以降は、そのページ自身を正規の URL にする
module CanonicalHelper
  def canonical(url)
    set_meta_tags canonical: canonical_with_page(url)
  end

  def canonical_with_page(url)
    page = params[:page].to_i
    page > 1 ? "#{url}?page=#{page}" : url
  end
end
