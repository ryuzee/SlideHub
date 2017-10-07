require 'rails_helper'

RSpec.describe Admin::FeaturedSlidesController, type: :controller do
  describe 'FeaturedSlides' do
    render_views
    let(:admin_user) { create(:admin_user) }
    before do
      login_by_admin_user admin_user
    end

    describe 'GET /admin/featured_slides/' do
      it 'works!' do
        get 'index'
        expect(response.status).to eq(200)
      end
    end

    describe 'GET /admin/featured_slides/new' do
      it 'works!' do
        get 'new'
        expect(response.status).to eq(200)
      end
    end

    describe 'POST /admin/featured_slides' do
      context 'when the target slide exists' do
        it 'saves record as a featured slides' do
          slide = create(:slide)
          post :create, params: { featured_slide: { slide_id: slide.id } }
          expect(response.status).to eq(302)
          expect(response).to redirect_to '/admin/featured_slides'
          expect(flash[:notice]).to eq(I18n.t(:featured_slide_was_added))
        end
      end

      context 'when the target slide does not exist' do
        it 'does not save record as a featured slides' do
          slide = build(:slide)
          post :create, params: { featured_slide: { slide_id: slide.id } }
          expect(response.status).to eq(200)
          expect(response.body).to include('is not included in the list')
        end
      end
    end

    describe 'DELETE /admin/featured_slides/1' do
      it 'deletes a feature slide' do
        slide = create(:slide)
        create(:featured_slide)
        delete :destroy, params: { id: slide.id }
        expect(response.status).to eq(302)
        expect(response).to redirect_to '/admin/featured_slides'
        expect(flash[:notice]).to eq(I18n.t(:featured_slide_was_deleted))
      end
    end
  end
end
