require 'rails_helper'

RSpec.describe Admin::CategoriesController, type: :controller do
  render_views
  let(:admin_user) { create(:admin_user) }

  before do
    login_by_admin_user admin_user
  end

  describe 'GET /admin/categories/' do
    it 'shows the number of slides in each category' do
      sushi = create(:default_category, name_en: 'Sushi', name_ja: 'すし')
      create_list(:slide, 2, category: sushi)
      empty = create(:default_category, name_en: 'Empty', name_ja: '空')
      get 'index'
      expect(assigns(:slide_counts).fetch(sushi.id, 0)).to eq(2)
      expect(assigns(:slide_counts).fetch(empty.id, 0)).to eq(0)
      row = Nokogiri::HTML(response.body).css('tbody tr').find { |tr| tr.text.include?('Sushi') }
      expect(row.css('td').map { |td| td.text.strip }).to include('2')
    end

    it 'lists the categories' do
      create(:default_category, name_en: 'Sushi', name_ja: 'すし')
      get 'index'
      expect(response.status).to eq(200)
      expect(response.body).to include('Sushi', 'すし')
    end
  end

  describe 'GET /admin/categories/new' do
    it 'shows the form to create a category' do
      get 'new'
      expect(response.status).to eq(200)
      expect(response.body).to include('name="category[name_en]"', 'name="category[name_ja]"')
    end
  end

  describe 'POST /admin/categories' do
    it 'creates a category when both names are given' do
      expect { post 'create', params: { category: { name_en: 'Ramen', name_ja: 'ラーメン' } } }.to change(Category, :count).by(1)
      expect(response).to redirect_to admin_categories_path
      expect(Category.find_by(name_en: 'Ramen').name_ja).to eq('ラーメン')
    end

    it 'shows the form again without creating anything when a name is missing' do
      expect { post 'create', params: { category: { name_en: 'Ramen', name_ja: '' } } }.not_to change(Category, :count)
      expect(response.status).to eq(200)
      expect(response).to render_template :new
    end
  end

  describe 'GET /admin/categories/edit/1' do
    it 'shows the form filled with the current names' do
      target = create(:default_category)
      get 'edit', params: { id: target.id }
      expect(response.status).to eq(200)
      expect(response.body).to include('value="Category1"', 'value="Category1_ja"')
    end
  end

  describe 'POST /admin/categories/update' do
    it 'updates the category when the names are valid' do
      target = create(:default_category)
      post :update, params: { id: target.id, category: { name_en: 'SushiKuitai', name_ja: target.name_ja } }
      expect(response).to redirect_to admin_categories_path
      expect(Category.find(target.id).name_en).to eq('SushiKuitai')
    end

    it 'shows the form again and keeps the old name when the name is empty' do
      target = create(:default_category)
      post :update, params: { id: target.id, category: { name_en: '', name_ja: target.name_ja } }
      expect(response.status).to eq(200)
      expect(response).to render_template :edit
      expect(Category.find(target.id).name_en).to eq('Category1')
    end
  end

  describe 'DELETE /admin/category' do
    it 'deletes the category when there is no slide in the category' do
      target = create(:default_category)
      delete :destroy, params: { id: target.id }
      expect(response).to redirect_to admin_categories_path
      expect(Category.where(id: target.id).count).to eq(0)
    end

    it 'can not delete the category when one or more slides belong to the category' do
      slide = create(:slide)
      delete :destroy, params: { id: slide.category_id }
      expect(response).to redirect_to admin_categories_path
      expect(Category.where(id: slide.category_id).count).to eq(1)
    end
  end
end
