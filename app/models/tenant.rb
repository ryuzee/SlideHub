class Tenant < ApplicationRecord
  VALID_TENANTNAME_REGEX = /\A[a-zA-Z0-9]{3,32}\z/.freeze
  validates :name, uniqueness: true,
                   length: { minimum: 3, maximum: 32 },
                   format: { with: VALID_TENANTNAME_REGEX },
                   exclusion: { in: (ReservedWord.list | SlideHub::Subdomain.list) }
end
