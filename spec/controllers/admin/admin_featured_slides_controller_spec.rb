require 'rails_helper'

RSpec.describe Admin::FeaturedSlidesController, type: :controller do
  describe 'FeaturedSlides' do
    render_views
    let(:admin_user) { create(:admin_user) }
    before do
      login_by_admin_user admin_user
    end

    describe 'GET /admin/featured_slides/' do
      it 'lists published candidates that are not featured yet, filtered by title' do
        featured = create(:featured_slide, slide: create(:slide, name: 'Featured Sushi'))
        candidate = create(:slide, name: 'Candidate Sushi')
        create(:slide, name: 'Private Sushi', private: true)
        create(:slide, name: 'Other')
        get 'index', params: { q: 'Sushi' }
        expect(assigns(:candidates)).to eq([candidate])
        expect(assigns(:featured_slides)).to eq([featured])
      end
    end

    describe 'GET /admin/featured_slides/new' do
      it 'redirects to the list, where slides are added now' do
        get 'new'
        expect(response).to redirect_to '/admin/featured_slides'
      end
    end

    describe 'PATCH /admin/featured_slides/reorder' do
      it 'saves the order' do
        a = create(:featured_slide)
        b = create(:featured_slide)
        patch :reorder, params: { ids: [a.id, b.id] }, format: :json
        expect(response.status).to eq(204)
        expect(FeaturedSlide.ordered.pluck(:id)).to eq([a.id, b.id])
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
          expect(response.status).to eq(422)
          expect(response.body).to include(I18n.t('errors.messages.inclusion'))
        end
      end
    end

    describe 'DELETE /admin/featured_slides/1' do
      it 'deletes a feature slide' do
        f = create(:featured_slide)
        delete :destroy, params: { id: f.id }
        expect(response.status).to eq(302)
        expect(response).to redirect_to '/admin/featured_slides'
        expect(flash[:notice]).to eq(I18n.t(:featured_slide_was_deleted))
      end
    end
  end
end
