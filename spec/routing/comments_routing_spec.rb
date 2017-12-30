# == Schema Information
#
# Table name: comments
#
#  id               :integer          not null, primary key
#  user_id          :integer          not null
#  commentable_id   :integer          not null
#  comment          :text(65535)      not null
#  created_at       :datetime         not null
#  updated_at       :datetime
#  commentable_type :string(255)      default("Slide")
#  role             :string(255)      default("comments")
#

require 'rails_helper'

describe CommentsController do
  describe 'routing' do
    it 'routes to #create' do
      expect(post('/comments')).to route_to('comments#create')
    end

    it 'routes to #destroy' do
      expect(delete('/comments/1')).to route_to('comments#destroy', id: '1')
    end
  end
end
