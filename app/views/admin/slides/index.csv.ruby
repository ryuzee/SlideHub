require 'csv'

def csv_column_names
  names = [
    t('activerecord.attributes.slide.id'),
    t('activerecord.attributes.slide.name'),
    'URL',
    t('activerecord.attributes.slide.user_id'),
    t('activerecord.attributes.slide.description'),
    t('activerecord.attributes.slide.convert_status'),
    t('activerecord.attributes.slide.page_view'),
    t('activerecord.attributes.slide.embedded_view'),
    t('activerecord.attributes.slide.download_count'),
    t('activerecord.attributes.slide.comments'),
    t('activerecord.attributes.slide.created_at'),
    t('activerecord.attributes.slide.updated_at'),
  ]
  names
end

CSV.generate do |csv|
  csv << csv_column_names
  @slides.each do |slide|
    csv_column_values = [
      slide.id,
      slide.name,
      slide_url(slide.id),
      slide.user_id,
      slide.description,
      slide.page_view,
      slide.convert_status_i18n,
      slide.embedded_view,
      slide.download_count,
      slide.comments.count,
      slide.created_at,
      slide.updated_at,
    ]
    csv << csv_column_values
  end
end
