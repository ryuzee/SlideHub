require 'rails_helper'

describe 'Dashboard' do
  describe 'Creating "Dashboard" model' do
    it 'has collect methods' do
      create(:default_user)
      create(:default_category)
      create(:slide)
      dashboard = Dashboard.new
      expect(dashboard.slide_count).to be_integer
      expect(dashboard.user_count).to be_integer
      expect(dashboard.conversion_failed_count).to be_integer
      expect(dashboard.comment_count).to be_integer
      expect(dashboard.page_view).to be_integer
      expect(dashboard.download_count).to be_integer
      expect(dashboard.embedded_view).to be_integer
      expect(dashboard.latest_slides.class.to_s).to eq 'Slide::ActiveRecord_Relation'
      expect(dashboard.popular_slides.class.to_s).to eq 'Slide::ActiveRecord_Relation'
    end
  end
end
