class Tenant < ApplicationRecord
  VALID_TENANTNAME_REGEX = /\A[a-zA-Z0-9]{3,32}\z/.freeze
  validates :name, uniqueness: true,
                   length: { minimum: 3, maximum: 32 },
                   format: { with: VALID_TENANTNAME_REGEX },
                   exclusion: { in: (ReservedWord.list | SlideHub::Subdomain.list) }

  def self.primary?
    current = Tenant.connection.current_database
    Tenant.find_by(name: current).nil?
  end

  def self.identifier
    if primary?
      ''
    else
      Tenant.connection.current_database
    end
  end
end
