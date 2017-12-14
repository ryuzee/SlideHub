module SlideHub
  class UsernameUrlConstrainer
    def matches?(request)
      User.find_by(username: request.params[:username]).present?
    end
  end
end
