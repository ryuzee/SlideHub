module Users
  class RegistrationsController < Devise::RegistrationsController
    # Overwrite update_resource to let users to update their user without giving their password
    def update_resource(resource, params)
      if %w[facebook twitter saml].include?(resource.provider)
        params.delete('current_password')
        resource.update_without_password(params)
      else
        resource.update_with_password(params)
      end
    end
  end
end
