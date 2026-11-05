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
        { '@type': 'ListItem', position: 1, name: ApplicationSetting['site.name'].presence || 'SlideHub', item: root_url },
        { '@type': 'ListItem', position: 2, name: slide.category_name, item: category_url(slide.category_id) },
        { '@type': 'ListItem', position: 3, name: slide.name, item: slide_url(slide.id) },
      ],
    }
  end

  def json_ld_tag(data)
    tag.script(json_escape(data.to_json).html_safe, type: 'application/ld+json')
  end
end
