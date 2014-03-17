# encoding: utf-8
module Api
  module V1

    class SharesController < Api::V1::ApiController

      #protect_from_forgery with: :null_session

      skip_before_filter :verify_authenticity_token, :only => [:create, :update, :destroy]

      before_action :set_share, only: [:show, :update, :destroy]

      load_and_authorize_resource

      respond_to :json

      # GET /api/v1/shares.json
      def index
        @shares = Share.where(user_id: current_user.id)
        respond_with @shares
      end

      # GET /api/v1/1.json
      def show
        respond_with @share
      end

      # POST /api/v1/shares.json
      def create
        user = {user_id: current_user.id}
        if share_params && Share.create(share_params.merge(user))
          respond_with current_user.shares.last
        else
          render json: nil, status: :unprocessable_entity
        end
      end

      # PATCH/PUT /api/v1/1.json
      def update
        if share_params && @share.update(share_params)
          respond_with @share.update(share_params)
        else
          render json: nil, status: :unprocessable_entity
        end
      end

      # DELETE /api/v1/1.json
      def destroy
        respond_with @share.destroy
      end

      private
      # Use callbacks to share common setup or constraints between actions.
      def set_share
        begin
          @share = Share.find(params[:id])
        rescue ActiveRecord::RecordNotFound
          render text: { status: 404, error: t('api.m404') }.to_json, :status => 404
        end
      end

      # Never trust parameters from the scary internet, only allow the white list through.
      def share_params
        begin
          if params[:share]   # if params[:share] fix the case when user click update button without selecting new file
            params.require(:share).permit(:file, :original_filename, :public)
          end
        rescue ActionController::UnpermittedParameters
          nil
        end

      end
    end


  end
end