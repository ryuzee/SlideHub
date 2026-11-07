module StructuredDataHelper
  # スライド詳細ページ用の schema.org 構造化データ
  def slide_structured_data(slide)
    converted = slide.converted?
    {
      '@context': 'https://schema.org',
      '@type': 'PresentationDigitalDocument',
      name: slide.name,
      description: strip_tags(slide.description).squish.truncate(300),
      url: slide_url(slide.id),
      image: (slide.thumbnail.url_middle if converted),
      thumbnailUrl: (slide.thumbnail.url if converted),
      datePublished: slide.created_at.iso8601,
      dateModified: (slide.updated_at || slide.created_at).iso8601,
      inLanguage: I18n.locale.to_s,
      keywords: slide.tags.map(&:to_s).join(','),
      author: slide_author_structured_data(slide),
      interactionStatistic: slide_view_count_structured_data(slide),
    }.compact
  end

  def slide_view_count_structured_data(slide)
    {
      '@type': 'InteractionCounter',
      interactionType: 'https://schema.org/WatchAction',
      userInteractionCount: slide.total_view,
    }
  end

  def slide_author_structured_data(slide)
    {
      '@type': 'Person',
      name: strip_tags(slide.user_display_name),
      url: user_by_username_url(username: slide.user_username),
    }
  end

  # トップ > カテゴリ > スライド のパンくず
  def slide_breadcrumb_structured_data(slide)
    {
      '@context': 'https://schema.org',
      '@type': 'BreadcrumbList',
      itemListElement: [
        { '@type': 'ListItem', position: 1, name: description_site_name, item: root_url },
        { '@type': 'ListItem', position: 2, name: slide.category_name, item: category_url(slide.category_id) },
        { '@type': 'ListItem', position: 3, name: slide.name, item: slide_url(slide.id) },
      ],
    }
  end

  # トップページ：サイトそのもの（検索結果にサイト名を出すときの手がかりになる）
  def site_structured_data
    {
      '@context': 'https://schema.org',
      '@type': 'WebSite',
      name: description_site_name,
      url: root_url,
      description: site_description,
      inLanguage: I18n.locale.to_s,
    }
  end

  # ユーザーのページ：その人のプロフィール
  def user_profile_structured_data(user)
    url = user_by_username_url(username: user.username)
    person = {
      '@type': 'Person',
      name: strip_tags(user.display_name),
      alternateName: user.username,
      description: strip_tags(user.biography.to_s).squish.presence,
      url: url,
      sameAs: (["https://x.com/#{user.twitter_account}"] if user.twitter_account.present?),
    }.compact
    { '@context': 'https://schema.org', '@type': 'ProfilePage', url: url, mainEntity: person }
  end

  # 一覧のページ（最新・人気・カテゴリ）。description は meta description と同じ文にする
  def collection_structured_data(name:, url:)
    {
      '@context': 'https://schema.org',
      '@type': 'CollectionPage',
      name: name,
      url: canonical_with_page(url),
      description: meta_tags[:description],
      isPartOf: { '@type': 'WebSite', name: description_site_name, url: root_url },
    }.compact
  end

  # トップ > カテゴリ のパンくず
  def category_breadcrumb_structured_data(category)
    {
      '@context': 'https://schema.org',
      '@type': 'BreadcrumbList',
      itemListElement: [
        { '@type': 'ListItem', position: 1, name: description_site_name, item: root_url },
        { '@type': 'ListItem', position: 2, name: category.name, item: category_url(category.id) },
      ],
    }
  end

  def json_ld_tag(data)
    tag.script(json_escape(data.to_json).html_safe, type: 'application/ld+json')
  end
end
