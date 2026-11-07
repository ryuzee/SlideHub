require 'rails_helper'

RSpec.describe CommentsController, type: :controller do
  describe 'Comments' do
    render_views
    let(:data) { create(:slide) }
    let(:another_user) { create(:another_user) }

    describe 'add new comments by login user' do
      it 'adds the comment and goes back to the slide' do
        login_by_user another_user
        comment_data = {}
        comment_data[:slide_id] = data[:id]
        comment_data[:user_id] = another_user.id
        comment_data[:comment] = 'Test'
        post :create, params: { comment: comment_data }
        expect(response.status).to eq(302)
        expect(response).to redirect_to "/slides/#{data.id}#comments-heading"
        slide = Slide.find(data.id)
        expect(slide.comments.count).to be == 1
        expect(slide.comments[0].comment).to eq(comment_data[:comment])
        expect(slide.comments[0].user_id).to eq(another_user.id)
      end

      it 'tells why the comment was not posted' do
        login_by_user another_user
        post :create, params: { comment: { slide_id: data.id, comment: '' } }
        expect(response).to redirect_to "/slides/#{data.id}#comments-heading"
        expect(flash[:alert]).to include(I18n.t(:comment_not_posted))
        expect(Slide.find(data.id).comments.count).to eq(0)
      end

      it 'does not add a comment to a slide that does not exist' do
        login_by_user another_user
        expect do
          post :create, params: { comment: { slide_id: 0, comment: 'Test' } }
        end.to raise_error(ActiveRecord::RecordNotFound)
        expect(Comment.count).to eq(0)
      end
    end

    describe 'fail to add new comments by anonymous user' do
      it 'does not add a comment and asks to sign in' do
        comment_data = {}
        comment_data[:slide_id] = data[:id]
        comment_data[:user_id] = another_user.id
        comment_data[:comment] = 'Test'
        post :create, params: { comment: comment_data }
        expect(response.status).to eq(302)
        expect(response).to redirect_to '/users/sign_in'
        slide = Slide.find(data.id)
        expect(slide.comments.count).to be == 0
      end
    end

    describe 'delete comment by login user' do
      it 'deletes the comment and goes back to the slide' do
        c = create(:comment_for_slide)
        login_by_user another_user
        get :destroy, params: { id: c.id }
        expect(response.status).to eq(302)
        expect(response).to redirect_to "/slides/#{c.slide_id}"
        slide = Slide.find(c.slide_id)
        expect(slide.comments.count).to be == 0
      end
    end

    describe 'fail to delete comment by anonymous user' do
      it 'does not delete the comment and asks to sign in' do
        c = create(:comment_for_slide)
        get :destroy, params: { id: c.id }
        expect(response.status).to eq(302)
        expect(response).to redirect_to '/users/sign_in'
        slide = Slide.find(c.slide_id)
        expect(slide.comments.count).to be == 1
      end
    end
  end
end
