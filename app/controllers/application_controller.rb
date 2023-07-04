class ApplicationController < ActionController::Base

  # Acción para mostrar la página de error 404
  def not_found
    render file: "#{Rails.root}/public/404.html", layout: false, status: :not_found
  end
end
