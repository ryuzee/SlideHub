require 'spec_helper'
require 'rails_helper'

RSpec.describe SettingsHelper, type: :helper do
  describe 'settings_links' do
    it "returns '<select>' when setting key is 'site.header_inverse'" do
      begin
        CustomSetting['site.header_inverse'] = 1
        @setting = CustomSetting.unscoped.where("var like 'site.header_inverse'").first
        fields_for('settings[]', @setting, index: nil) do |fh|
          input_tag = generate_form_field(@setting, fh)
          expect(input_tag).to match(/.*<select.*>.*/)
        end
      ensure
        CustomSetting['site.header_inverse'] = 0
      end
    end

    it "returns '<select>' when setting key is 'theme'" do
      begin
        CustomSetting['site.theme'] = 'dark'
        @setting = CustomSetting.unscoped.where("var like 'site.theme'").first
        fields_for('settings[]', @setting, index: nil) do |fh|
          input_tag = generate_form_field(@setting, fh)
          expect(input_tag).to match(/.*<select class="form-control".*>.*/)
          %w[default dark white].each do |theme|
            expect(input_tag).to match(/.*#{theme}.*/)
          end
        end
      ensure
        CustomSetting['site.theme'] = 'default'
      end
    end

    it "returns '<input>' when setting key is 'name'" do
      begin
        CustomSetting['site.name'] = 'test'
        @setting = CustomSetting.unscoped.where("var like 'site.name'").first
        fields_for('settings[]', @setting, index: nil) do |fh|
          input_tag = generate_form_field(@setting, fh)
          expect(input_tag).to match(/.*<input class="form-control" type="text" value="test" .*>.*/)
        end
      ensure
        CustomSetting['site.name'] = 'SlideHub'
      end
    end

    it "returns '<textarea>' when setting key is 'center_top'" do
      begin
        CustomSetting['custom.center_top'] = 'test'
        @setting = CustomSetting.unscoped.where("var like 'custom.center_top'").first
        fields_for('settings[]', @setting, index: nil) do |fh|
          input_tag = generate_form_field(@setting, fh)
          expect(input_tag).to match(%r{.*<textarea class="form-control".*cols="30" rows="5".*>.*test</textarea>}m)
        end
      ensure
        CustomSetting['custom.center_top'] = ''
      end
    end
  end
end
