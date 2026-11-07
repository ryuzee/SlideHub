require 'rails_helper'

RSpec.describe Admin::TenantsController, type: :controller do
  describe 'Tenants' do
    render_views
    let(:admin_user) { create(:admin_user) }
    before do
      login_by_admin_user admin_user
    end

    describe 'GET /admin/tenants/' do
      it 'lists the tenants' do
        create(:default_tenant)
        get 'index'
        expect(response.status).to eq(200)
        expect(response.body).to include('tenant1')
      end
    end

    describe 'GET /admin/tenants/new' do
      it 'shows the form to create a tenant' do
        get 'new'
        expect(response.status).to eq(200)
        expect(response.body).to include('name="tenant[name]"')
      end
    end

    describe 'POST /admin/tenants' do
      it 'creates a new tenant' do
        allow(Apartment::Tenant).to receive(:create).and_return(true)
        post :create, params: { tenant: { name: 'tenant1' } }
        expect(response.status).to eq(302)
        expect(response).to redirect_to '/admin/tenants'
        expect(flash[:notice]).to eq(I18n.t(:tenant_was_created))
      end
    end

    describe 'DELETE /admin/tenants/1' do
      it 'deletes a tenant' do
        allow(Apartment::Tenant).to receive(:drop).and_return(true)
        f = create(:default_tenant)
        delete :destroy, params: { id: f.id }
        expect(response.status).to eq(302)
        expect(response).to redirect_to '/admin/tenants'
        expect(flash[:notice]).to eq(I18n.t(:tenant_was_deleted))
      end
    end
  end
end
