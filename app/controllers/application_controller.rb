class ApplicationController < ActionController::Base
  include Authentication
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  # Deny by default. A controller declares its roles with
  # `before_action -> { require_role(*Roles::X) }` and skips this callback.
  before_action :require_role_declared

  private

  def require_role_declared
    redirect_to root_path, alert: t("authorization.denied")
  end

  def require_role(*roles)
    return if Current.user&.role_in?(roles)

    redirect_to root_path, alert: t("authorization.denied")
  end
end
