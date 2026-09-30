class HomeController < ApplicationController
  before_action -> { require_role(*Roles::ALL) }
  skip_before_action :require_role_declared

  def index
  end
end
