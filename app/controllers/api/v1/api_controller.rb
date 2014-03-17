module Api
  module V1
    class ApiController < ApplicationController
      before_filter :authenticate_user_from_token!
      # This is Devise's authentication
      before_filter :authenticate_user!

      def authenticate_user_from_token!
        user_email = request.headers['HTTP_USER_EMAIL'].presence
        user = user_email && User.find_by_email(user_email)

        if user && Devise.secure_compare(user.authentication_token, request.headers['HTTP_USER_TOKEN'])
          sign_in user, store: false
        end
      end

      rescue_from CanCan::AccessDenied do |exception|
        render text: { status: 403, error: exception.message }.to_json, :status => 403
      end

    end
  end
end