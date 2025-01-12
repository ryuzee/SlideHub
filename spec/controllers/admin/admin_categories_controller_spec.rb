require 'rails_helper'

RSpec.describe Admin::CategoriesController, type: :controller do
  
  describe 'Categories' do
    render_views
    let(:admin_user) { create(:admin_user) }
    before do
      login_by_admin_user admin_user
    end

    describe 'GET /admin/categories/' do
      it 'shows the list of categories' do
        get 'index'
        expect(response.status).to eq(200)
      end
    end

    describe 'GET /admin/categories/new' do
      it 'shows the form to create new category' do
        get 'new'
        expect(response.status).to eq(200)
      end
    end

    describe 'POST /admin/categories' do
      it 'create a new category when name_en and name_ja fields are provided' do
        post 'create', params: { category: { name_en: 'en', name_ja: 'ja' } }
        expect(response.status).to eq(302)
        expect(response).to redirect_to admin_categories_path
      end

      it 'can not create new category because of lack of category value, so render form again' do
        post 'create', params: { category: { name_en: 'en', name_ja: '' } }
        expect(response.status).to eq(200)
        expect(response).to render_template :new
      end
    end

    describe 'GET /admin/categories/edit/1' do
      it 'shows form to edit category' do
        target = create(:default_category)
        get 'edit', params: { id: target.id }
        expect(response.status).to eq(200)
      end
    end

    describe 'POST /admin/categories/update' do
      it 'updates the category when the name_en field is valid' do
        target = create(:default_category)
        data = Category.find(target.id)
        update_category = 'SushiKuitai'
        data[:name_en] = update_category
        keys = %w[id name_en name_ja]
        data_attr = data.attributes
        data_attr.each_key do |k, _v|
          data_attr.delete(k) unless keys.include?(k)
        end
        post :update, params: { id: target.id, category: data_attr }
        new_category = Category.find(target.id).name_en
        expect(new_category).to eq(update_category)
        expect(response.status).to eq(302)
      end
    end

    describe 'POST /admin/categories/update' do
      it 'can not update the category because the name is empty, thus go to edit screen' do
        target = create(:default_category)
        data = Category.find(target.id)
        update_category = '' # validation error
        data[:name_en] = update_category
        keys = %w[id name_en name_ja]
        data_attr = data.attributes
        data_attr.each_key do |k, _v|
          data_attr.delete(k) unless keys.include?(k)
        end
        post :update, params: { id: target.id, category: data_attr }
        expect(response.status).to eq(200)
        expect(response).to render_template :edit
      end
    end

    describe 'DELETE /admin/category' do
      it 'deletes the category when there is no slide in the category' do
        target = create(:default_category)
        delete :destroy, params: { id: target.id }
        expect(response.status).to eq(302)
        expect(response).to redirect_to admin_categories_path
        expect(Category.where(id: target.id).count).to eq(0)
      end

      it 'can not delete the category when one or more slides belong to the category' do
        slide = create(:slide)
        delete :destroy, params: { id: slide.category_id }
        expect(response.status).to eq(302)
        expect(response).to redirect_to admin_categories_path
        expect(Category.where(id: slide.category_id).count).to eq(1)
      end
    end
  end
end
