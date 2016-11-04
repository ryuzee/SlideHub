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
#  modified_at    :datetime
#  key            :string(255)      default("")
#  extension      :string(10)       default(""), not null
#  convert_status :integer          default(0)
#  total_view     :integer          default(0), not null
#  page_view      :integer          default(0)
#  download_count :integer          default(0), not null
#  embedded_view  :integer          default(0), not null
#  num_of_pages   :integer          default(0)
#  comments_count :integer          default(0), not null
#

require 'rails_helper'

describe 'Slide' do
  before do
    SlideHub::Cloud::Engine::AWS.configure do |config|
      config.region = 'ap-northeast-1'
      config.aws_access_id = 'aws_access_id'
      config.aws_secret_key = 'aws_secret_key'
      config.bucket_name = 'my-bucket'
      config.image_bucket_name = 'my-image-bucket'
      config.sqs_url = 'https://www.ryuzee.com'
      config.use_s3_static_hosting = '0'
      config.cdn_base_url = ''
    end
  end

  describe 'thumbnail_url' do
    it 'url is valid' do
      FactoryGirl.create(:slide)
      key = Slide.find(1).key
      expect(Slide.find(1).thumbnail_url).to eq("https://my-image-bucket.s3-ap-northeast-1.amazonaws.com/#{key}/thumbnail.jpg")
    end
  end

  describe 'transcript' do
    it 'retrieve transcript and put it into array' do
      allow_any_instance_of(Slide).to receive(:transcript_url).and_return('http://www.example.com/transcript.txt')
      stub_request(:any, 'http://www.example.com/transcript.txt').to_return(
        body: 'a:1:{i:0;s:4:"Test";}',
        status: 200,
      )
      FactoryGirl.create(:slide)
      slide = Slide.find(1)
      expect(slide.transcript).to eq(['Test'])
      expect(slide.transcript_exist?(slide.transcript)).to eq(true)
    end

    it 'try to retrieve transcript, but failed' do
      allow_any_instance_of(Slide).to receive(:transcript_url).and_return('http://www.example.com/transcript.txt')
      stub_request(:any, 'http://www.example.com/transcript.txt').to_return(
        status: 404,
      )
      FactoryGirl.create(:slide)
      slide = Slide.find(1)
      expect(slide.transcript).to eq([])
      expect(slide.transcript_exist?(slide.transcript)).to eq(false)
    end

    it 'check the transcript is empty?' do
      allow_any_instance_of(Slide).to receive(:transcript_url).and_return('http://www.example.com/transcript.txt')
      stub_request(:any, 'http://www.example.com/transcript.txt').to_return(
        body: 'a:1:{i:0;s:0:"";}',
        status: 200,
      )
      FactoryGirl.create(:slide)
      slide = Slide.find(1)
      expect(slide.transcript_exist?(slide.transcript)).to eq(false)
    end
  end

  describe 'transcript_url' do
    it 'url is valid' do
      FactoryGirl.create(:slide)
      key = Slide.find(1).key
      expect(Slide.find(1).transcript_url).to eq("https://my-image-bucket.s3-ap-northeast-1.amazonaws.com/#{key}/transcript.txt")
    end
  end

  describe 'page_list_url' do
    it 'url is valid' do
      FactoryGirl.create(:slide)
      key = Slide.find(1).key
      expect(Slide.find(1).page_list_url).to eq("https://my-image-bucket.s3-ap-northeast-1.amazonaws.com/#{key}/list.json")
    end
  end

  describe 'page_list' do
    it 'returns page list (1 page)' do
      FactoryGirl.create(:slide)
      key = Slide.find(1).key
      expect(Slide.find(1).page_list).to eq(["#{key}/slide-1.jpg"])
    end

    it 'returns page list (10 page)' do
      FactoryGirl.create(:slide)
      slide = Slide.where('slides.id = ?', 1).first
      key = slide.key
      slide.num_of_pages = 10
      slide.save
      expected = ["#{key}/slide-01.jpg", "#{key}/slide-02.jpg", "#{key}/slide-03.jpg",
                  "#{key}/slide-04.jpg", "#{key}/slide-05.jpg", "#{key}/slide-06.jpg",
                  "#{key}/slide-07.jpg", "#{key}/slide-08.jpg", "#{key}/slide-09.jpg", "#{key}/slide-10.jpg"]
      expect(Slide.find(1).page_list).to eq(expected)
    end
  end
end
