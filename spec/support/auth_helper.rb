#
# Signs in over HTTP against the Rails 8 authentication generator's
# SessionsController. Every factory user has the password "password".
module AuthHelper
  def sign_in(user, password: "password")
    post session_path, params: { email_address: user.email_address, password: password }
  end

  def sign_out
    delete session_path
  end
end

RSpec.configure do |config|
  config.include AuthHelper, type: :request
end
