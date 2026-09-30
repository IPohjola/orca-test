require "rails_helper"

RSpec.describe "Home", type: :request do
  Roles::ALL.each do |role|
    it "renders for #{role}" do
      sign_in(create_user(role: role))
      get root_path
      expect(response).to have_http_status(:ok)
      expect(response.body).to include(I18n.t("home.index.title"))
    end
  end

  it "redirects to login without a session" do
    get root_path
    expect(response).to redirect_to(new_session_path)
  end
end
