# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  email                  :string(32)       not null
#  display_name           :string(128)      not null
#  password               :string(255)      default(""), not null
#  admin                  :boolean          default(FALSE), not null
#  disabled               :boolean          default(FALSE)
#  created_at             :datetime         not null
#  updated_at             :datetime
#  biography              :text(65535)
#  slides_count           :integer          default(0)
#  encrypted_password     :string(255)      default(""), not null
#  reset_password_token   :string(255)
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0), not null
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :string(255)
#  last_sign_in_ip        :string(255)
#  avatar_file_name       :string(255)
#  avatar_content_type    :string(255)
#  avatar_file_size       :integer
#  avatar_updated_at      :datetime
#

require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  let!(:default_user) { create(:default_user) }

  describe 'When the user has logged in' do
    before do
      login_by_user default_user
    end

    describe 'GET /users/index' do
      it 'shows all of my slides, including private ones' do
        public_slide = create(:slide, user: default_user)
        private_slide = create(:slide, user: default_user, private: true)
        get 'index'
        expect(response.status).to eq(200)
        expect(assigns(:slides)).to contain_exactly(public_slide, private_slide)
      end
    end
  end

  describe 'When the user has not logged in' do
    describe 'GET /users/1' do
      it 'shows only the published slides of the user' do
        public_slide = create(:slide, user: default_user)
        create(:slide, user: default_user, private: true)
        get 'show', params: { id: default_user.id }
        expect(response.status).to eq(200)
        expect(assigns(:user)).to eq(default_user)
        expect(assigns(:slides)).to eq([public_slide])
      end
    end

    describe 'GET /users/user01' do
      it 'finds the user by username' do
        get 'show', params: { username: default_user.username }
        expect(response.status).to eq(200)
        expect(assigns(:user)).to eq(default_user)
      end
    end

    describe 'GET /users/1?sort_by=popularity' do
      it 'sorts the slides by the number of views' do
        less = create(:slide, user: default_user, total_view: 1)
        more = create(:slide, user: default_user, total_view: 100)
        get 'show', params: { id: default_user.id, sort_by: 'popularity' }
        expect(response.status).to eq(200)
        expect(assigns(:slides).to_a).to eq([more, less])
      end
    end

    describe 'GET /users/1/embedded' do
      render_views

      it 'returns javascript for embedding' do
        get 'embedded', params: { id: default_user.id }
        expect(response.status).to eq(200)
        expect(response.media_type).to eq('application/javascript')
      end

      it 'embeds the HTML as a plain string, so slide names are never run as code' do
        create(:slide, user: default_user, name: '${window.hacked = 1}`</script>')
        get 'embedded', params: { id: default_user.id }
        body = response.body
        expect(body).not_to include('innerHTML = `')
        expect(body).not_to include('</script>')
        html = JSON.parse(body[/elm\.innerHTML = (".*");/, 1])
        expect(html).to include('${window.hacked = 1}')
      end

      it 'uses the given prefix only when it is a simple id' do
        get 'embedded', params: { id: default_user.id, prefix: 'my-widget_1' }
        expect(response.body).to include('getElementById("slidehub-my-widget_1")')
        get 'embedded', params: { id: default_user.id, prefix: '");alert(1);("' }
        expect(response.body).to match(/getElementById\("slidehub-js[0-9a-f]{32}"\)/)
      end

      it 'shows only published slides, 5 per page' do
        create_list(:slide, 6, user: default_user)
        create(:slide, user: default_user, private: true)
        create(:slide, user: default_user, convert_status: Slide.convert_statuses[:unconverted])
        get 'embedded', params: { id: default_user.id }
        slides = assigns(:slides)
        expect(slides.size).to eq(5)
        expect(slides.map(&:private)).to all(be(false))
        expect(slides.map(&:convert_status)).to all(eq('converted'))
      end
    end

    describe 'GET /users/index' do
      it 'redirects to login page' do
        get 'index'
        expect(response.status).to eq(302)
      end
    end
  end
end
