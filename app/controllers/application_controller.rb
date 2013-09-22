class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action :set_new_share

  private

    def set_new_share
      if user_signed_in?
        @share = Share.new
      end
    end

end
