require 'rails_helper'

RSpec.describe Admin::CustomFilesController, type: :controller do
  describe 'Slides' do
    render_views
    let(:admin_user) { create(:admin_user) }
    before do
      login_by_admin_user admin_user
    end

    describe 'GET /admin/custom_files/' do
      it 'works!' do
        get 'index'
        expect(response.status).to eq(200)
      end
    end

    describe 'GET /admin/custom_files/new' do
      it 'works!' do
        get 'new'
        expect(response.status).to eq(200)
      end
    end

    describe 'POST /admin/custom_files' do
      it 'works!' do
        allow(SlideHub::Cloud::Engine::Aws).to receive(:upload_files).and_return(true)
        allow(SlideHub::Cloud::Engine::Azure).to receive(:upload_files).and_return(true)
        post 'create', params: {
          custom_file: {
            file: fixture_file_upload(Rails.root.join('spec', 'fixtures', 'dummy.txt'), 'text/html'),
            description: 'hoge',
          },
        }
        expect(response.status).to eq(302)
        expect(response).to redirect_to admin_custom_files_path
        expect(File.exist?(Rails.root.join('tmp', 'dummy.txt'))).to eq(false)
      end

      it 'updates the existing record if path is equal to the existing one' do
        allow(SlideHub::Cloud::Engine::Aws).to receive(:upload_files).and_return(true)
        allow(SlideHub::Cloud::Engine::Azure).to receive(:upload_files).and_return(true)
        custom_file = create(:default_custom_file)
        post 'create', params: {
          custom_file: {
            file: fixture_file_upload(Rails.root.join('spec', 'fixtures', 'dummy.txt'), 'text/html'),
            description: 'hoge',
          },
        }
        expect(response.status).to eq(302)
        expect(response).to redirect_to admin_custom_files_path
        expect(CustomFile.find(custom_file.id).description).to eq('hoge')
      end
    end

    describe 'DELETE /admin/custom_files/1' do
      it 'works!' do
        allow(SlideHub::Cloud::Engine::Aws).to receive(:delete_files).and_return(true)
        allow(SlideHub::Cloud::Engine::Azure).to receive(:delete_files).and_return(true)
        custom_file = create(:default_custom_file)
        delete :destroy, params: { id: custom_file.id }
        expect(response.status).to eq(302)
        expect(response).to redirect_to admin_custom_files_path
        expect(CustomFile.find_by(id: custom_file.id)).to eq(nil)
      end
    end
  end
end
