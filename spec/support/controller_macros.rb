# see http://konyu.hatenablog.com/entry/2014/11/12/230433
module ControllerMacros
  def login_admin(admin)
    @request.env["devise.mapping"] = Devise.mappings[:admin]
    sign_in admin
  end

  def login_user(user)
    @request.env["devise.mapping"] = Devise.mappings[:user]
    user.confirm!
    sign_in user
  end
end
