class MainController < ApplicationController
  before_action :authenticate_user!

  def home
    redirect_to projects_path if user_signed_in?
  end
end
