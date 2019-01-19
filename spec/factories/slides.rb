# == Schema Information
#
# Table name: slides
#
#  id             :integer          not null, primary key
#  user_id        :integer          not null
#  name           :string(255)      not null
#  description    :text(65535)      not null
#  downloadable   :boolean          default(FALSE), not null
#  category_id    :integer          not null
#  created_at     :datetime         not null
#  updated_at     :datetime
#  object_key     :string(255)      default("")
#  extension      :string(10)       default(""), not null
#  convert_status :integer          default("not_converted")
#  total_view     :integer          default(0), not null
#  page_view      :integer          default(0)
#  download_count :integer          default(0), not null
#  embedded_view  :integer          default(0), not null
#  num_of_pages   :integer          default(0)
#  comments_count :integer          default(0), not null
#  private        :boolean          default(FALSE), not null
#

FactoryBot.define do
  factory :slide, class: Slide do
    name { 'Hoge' }
    description { 'FUGA' }
    sequence(:object_key) { |n| "abcdefg#{n}" }
    extension { '.pdf' }
    convert_status { Slide.convert_statuses[:converted] }
    num_of_pages { 1 }
    sequence(:created_at, 1) { |i| Time.zone.now - i.days }
    downloadable { true }
    tag_list { 'Sushi,Toro' }

    association :user, factory: :default_user
    association :category, factory: :default_category
  end
end
