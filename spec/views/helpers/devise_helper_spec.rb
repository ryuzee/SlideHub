require 'rails_helper'

RSpec.describe DeviseHelper, type: :helper do
  describe 'bootstrap_devise_error_messages!' do
    let(:user) { User.new }

    before do
      # Devise のビューでは resource がユーザーを返す
      resource = user
      helper.define_singleton_method(:resource) { resource }
    end

    it 'returns an empty string when there is no error' do
      expect(helper.bootstrap_devise_error_messages!).to eq('')
    end

    it 'shows each error in a dismissible alert and escapes the message' do
      user.errors.add(:base, '<script>alert(1)</script>')
      user.errors.add(:base, 'Second error')
      html = helper.bootstrap_devise_error_messages!
      expect(html).to be_html_safe
      expect(html.scan('class="alert alert-danger alert-dismissible"').size).to eq(2)
      expect(html).to include('data-bs-dismiss="alert"')
      expect(html).to include('&lt;script&gt;alert(1)&lt;/script&gt;')
      expect(html).not_to include('<script>')
    end
  end
end
