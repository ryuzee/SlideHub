FactoryBot.define do
  factory :default_tenant, class: Tenant do
    name { 'tenant1' }
    initialize_with { Tenant.find_or_create_by(name: name) }
  end
end
