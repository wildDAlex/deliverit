class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action :set_new_share

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
