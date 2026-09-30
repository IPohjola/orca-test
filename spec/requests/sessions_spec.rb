require "rails_helper"

RSpec.describe "Sessions", type: :request do
  it "renders the login form" do
    get new_session_path
    expect(response).to have_http_status(:ok)
    expect(response.body).to include(I18n.t("sessions.new.submit"))
  end

  it "signs in with valid credentials" do
    user = create_user
    post session_path, params: { email_address: user.email_address, password: "password" }
    expect(response).to redirect_to(root_url)
  end

  it "rejects invalid credentials" do
    user = create_user
    post session_path, params: { email_address: user.email_address, password: "wrong" }
    expect(response).to redirect_to(new_session_path)
    expect(flash[:alert]).to eq(I18n.t("sessions.create.invalid"))
  end

  it "signs out" do
    sign_in(create_user)
    delete session_path
    expect(response).to redirect_to(new_session_path)
  end
end
