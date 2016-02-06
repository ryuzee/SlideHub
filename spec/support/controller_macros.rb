# see http://konyu.hatenablog.com/entry/2014/11/12/230433
module ControllerMacros
  def login_by_admin_user(admin)
    @request.env['devise.mapping'] = Devise.mappings[:admin]
    sign_in admin
  end

  def login_by_user(user)
    @request.env['devise.mapping'] = Devise.mappings[:user]
    sign_in user
  end
end
