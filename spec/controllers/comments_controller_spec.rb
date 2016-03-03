# == Schema Information
#
# Table name: comments
#
#  id               :integer          not null, primary key
#  user_id          :integer          not null
#  commentable_id   :integer          not null
#  comment          :text(65535)      not null
#  created_at       :datetime         not null
#  modified_at      :datetime
#  commentable_type :string(255)      default("Slide")
#  role             :string(255)      default("comments")
#

require 'rails_helper'

RSpec.describe CommentsController, type: :controller do
  describe 'Comments' do
    let(:data) { create(:slide) }
    let(:general_user) { create(:general_user) }

    describe 'add new comments by login user' do
      it 'works!' do
        login_by_user general_user
        comment_data = {}
        comment_data[:commentable_id] = data[:id]
        comment_data[:commentable_type] = 'Slide'
        comment_data[:user_id] = general_user.id
        comment_data[:comment] = 'Test'
        post :create, comment: comment_data
        expect(response.status).to eq(302)
        expect(response).to redirect_to "/slides/#{data.id}"
        slide = Slide.find(data.id)
        expect(slide.comments.count).to be == 1
        expect(slide.comments[0].comment).to eq(comment_data[:comment])
      end
    end

    describe 'fail to add new comments by anonymous user' do
      it 'works!' do
        comment_data = {}
        comment_data[:commentable_id] = data[:id]
        comment_data[:commentable_type] = 'Slide'
        comment_data[:user_id] = general_user.id
        comment_data[:comment] = 'Test'
        post :create, comment: comment_data
        expect(response.status).to eq(302)
        expect(response).to redirect_to '/users/sign_in'
        slide = Slide.find(data.id)
        expect(slide.comments.count).to be == 0
      end
    end

    describe 'delete comment by login user' do
      it 'works!' do
        c = create(:comment_for_slide)
        login_by_user general_user
        get :destroy, { id: c.id }
        expect(response.status).to eq(302)
        expect(response).to redirect_to "/slides/#{data.id}"
        slide = Slide.find(data.id)
        expect(slide.comments.count).to be == 0
      end
    end

    describe 'fail to delete comment by anonymous user' do
      it 'works!' do
        c = create(:comment_for_slide)
        get :destroy, { id: c.id }
        expect(response.status).to eq(302)
        expect(response).to redirect_to '/users/sign_in'
        slide = Slide.find(data.id)
        expect(slide.comments.count).to be == 1
      end
    end
  end
end
