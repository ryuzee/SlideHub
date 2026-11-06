require 'rails_helper'

RSpec.describe SettingsHelper, type: :helper do
  describe 'settings_links' do
    it "returns '<select>' when setting key is 'site.header_inverse'" do
      ApplicationSetting['site.header_inverse'] = 1
      @setting = ApplicationSetting.unscoped.where("var like 'site.header_inverse'").first
      fields_for('settings[]', @setting, index: nil) do |fh|
        input_tag = generate_form_field(@setting, fh)
        expect(input_tag).to match(/.*<select.*>.*/)
      end
    ensure
      ApplicationSetting['site.header_inverse'] = 0
    end

    it "returns '<select>' when setting key is 'theme'" do
      ApplicationSetting['site.theme'] = 'dark'
      @setting = ApplicationSetting.unscoped.where("var like 'site.theme'").first
      fields_for('settings[]', @setting, index: nil) do |fh|
        input_tag = generate_form_field(@setting, fh)
        expect(input_tag).to match(/.*<select class="form-select".*>.*/)
        %w[default dark white].each do |theme|
          expect(input_tag).to match(/.*#{theme}.*/)
        end
      end
    ensure
      ApplicationSetting['site.theme'] = 'default'
    end

    it "returns '<select>' with 4:3 and 16:9 when setting key is 'site.thumbnail_aspect_ratio'" do
      ApplicationSetting['site.thumbnail_aspect_ratio'] = '16:9'
      @setting = ApplicationSetting.unscoped.where("var like 'site.thumbnail_aspect_ratio'").first
      fields_for('settings[]', @setting, index: nil) do |fh|
        input_tag = generate_form_field(@setting, fh)
        expect(input_tag).to include('<select class="form-select"')
        expect(input_tag).to include('<option value="4:3">4:3</option>')
        expect(input_tag).to include('<option selected="selected" value="16:9">16:9</option>')
      end
    ensure
      ApplicationSetting['site.thumbnail_aspect_ratio'] = '4:3'
    end

    it "returns '<input>' when setting key is 'name'" do
      ApplicationSetting['site.name'] = 'test'
      @setting = ApplicationSetting.unscoped.where("var like 'site.name'").first
      fields_for('settings[]', @setting, index: nil) do |fh|
        input_tag = generate_form_field(@setting, fh)
        expect(input_tag).to match(/.*<input class="form-control" type="text" value="test" .*>.*/)
      end
    ensure
      ApplicationSetting['site.name'] = 'SlideHub'
    end

    it "returns '<textarea>' when setting key is 'center_top'" do
      ApplicationSetting['custom.center_top'] = 'test'
      @setting = ApplicationSetting.unscoped.where("var like 'custom.center_top'").first
      fields_for('settings[]', @setting, index: nil) do |fh|
        input_tag = generate_form_field(@setting, fh)
        expect(input_tag).to match(%r{.*<textarea class="form-control".*cols="30" rows="5".*>.*test</textarea>}m)
      end
    ensure
      ApplicationSetting['custom.center_top'] = ''
    end
  end
end
