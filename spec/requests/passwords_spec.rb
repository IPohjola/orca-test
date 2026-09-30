require "rails_helper"

RSpec.describe "Passwords", type: :request do
  it "renders the reset request form" do
    get new_password_path
    expect(response).to have_http_status(:ok)
    expect(response.body).to include(I18n.t("passwords.new.submit"))
  end

  it "enqueues a reset mail for a known address" do
    user = create_user
    expect {
      post passwords_path, params: { email_address: user.email_address }
    }.to have_enqueued_mail(PasswordsMailer, :reset)
    expect(response).to redirect_to(new_session_path)
  end

  it "renders the edit form for a valid token" do
    user = create_user
    get edit_password_path(user.password_reset_token)
    expect(response).to have_http_status(:ok)
    expect(response.body).to include(I18n.t("passwords.edit.submit"))
  end

  it "rejects an invalid token" do
    get edit_password_path("bogus")
    expect(response).to redirect_to(new_password_path)
    expect(flash[:alert]).to eq(I18n.t("passwords.edit.invalid_token"))
  end

  it "updates the password" do
    user = create_user
    put password_path(user.password_reset_token), params: { password: "newpassword", password_confirmation: "newpassword" }
    expect(response).to redirect_to(new_session_path)
    expect(user.reload.authenticate("newpassword")).to be_truthy
  end

  it "rejects mismatched passwords" do
    user = create_user
    put password_path(user.password_reset_token), params: { password: "a", password_confirmation: "b" }
    expect(flash[:alert]).to eq(I18n.t("passwords.update.mismatch"))
  end
end
