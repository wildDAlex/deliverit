class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_filter :configure_permitted_parameters, if: :devise_controller?

  before_action :set_new_share

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:account_update) { |u|
      u.permit(:email, :password, :password_confirmation, :current_password, :show_links)
    }
  end

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_url, :alert => exception.message
  end

  def route_not_found
    if params[:format] && params[:format] != "html"
      render :nothing => true, :status => 404
    else
      render :template => 'errors/404', :status => 404
    end
  end

  private

    def set_new_share
      if user_signed_in?
        @share = Share.new
      end
    end

end
