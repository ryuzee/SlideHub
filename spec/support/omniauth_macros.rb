def set_omniauth
  OmniAuth.config.add_mock(:facebook,
                           { 'uid' => '123545',
                             'name' => 'foo bar',
                             'credentials' => {
                               'token' => 'mock_token',
                               'secret' => 'mock_secret',
                             } })
end
