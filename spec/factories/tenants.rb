FactoryBot.define do
  factory :default_tenant, class: Tenant do
    id { 1 }
    name { 'tenant1' }
    initialize_with { Tenant.find_or_create_by(id: id) }
  end
end
