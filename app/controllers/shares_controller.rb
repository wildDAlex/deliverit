# encoding: utf-8
class SharesController < ApplicationController
  before_filter :authenticate_user!, except: [:show, :show_by_name, :download]
  before_action :set_share, only: [:show, :edit, :update, :destroy, :turn_publicity]
  load_and_authorize_resource

  # GET /shares
  # GET /shares.json
  def index
    begin
      @shares = Share.owned_by(current_user)
      if params[:tag]
        @shares = @shares.tagged_with(params[:tag], current_user)
      end
      if params[:type] and params[:type] != 'images'
        @shares = @shares.where("content_type LIKE ?", "%#{params[:type]}%")
      end
      @shares = @shares.order("created_at desc").page params[:page] if @shares
      if params[:type] == 'images'
        @shares = @shares.images.order("created_at desc").page params[:page]
        render 'thumb.html.slim'
      end
    rescue ActiveRecord::RecordNotFound
      return route_not_found
    end
  end

  # GET /shares/1
  # GET /shares/1.json
  def show
  end

  # GET /f/:user_id/:original_filename
  # Uploads files from local path for given user and show file by name
  def show_by_name
    begin
      @user = User.find(params[:user_id])
      @user.upload_from_local_path
      @share = @user.shares.find_by_original_filename!(params[:original_filename]+'.'+params[:extension])
      unless @share.public? or (signed_in? and current_user == @share.user) or (signed_in? and current_user.admin?)
        redirect_to root_path, alert: t('messages.no_access')
      else
        render 'show.html.slim'
      end
    rescue ActiveRecord::RecordNotFound
      return route_not_found
    end
  end

  # GET /shares/new
  def new
    @share = Share.new
  end

  # GET /shares/1/edit
  def edit
    redirect_to share_path(params[:id])
  end

  # POST /shares
  # POST /shares.json
  def create
    @share = Share.new(share_params)
    @share.user = current_user

    respond_to do |format|
      if @share.save
        format.html { redirect_to @share, notice: t('messages.share_created') }
        format.json { render action: 'show', status: :created, location: @share }
      else
        format.html { render action: 'new' }
        format.json { render json: @share.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /shares/1
  # PATCH/PUT /shares/1.json
  def update
    respond_to do |format|
      if @share.update(share_params)
        format.html {
          if params[:redirect] && params[:redirect] == 'index'
            redirect_to root_path, notice: t('messages.share_updated')
          else
            redirect_to @share, notice: t('messages.share_updated')
          end
        }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @share.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /shares/1
  # DELETE /shares/1.json
  def destroy
    @share.destroy
    respond_to do |format|
      format.html { redirect_to shares_path, alert: t('messages.share_deleted') }
      format.json { head :no_content }
    end
  end

  def download
    @share = Share.find_by_file(params[:filename]+'.'+params[:extension])
    if @share.nil? ||
        ( params[:version] && (not Share::IMAGE_VERSIONS.include?(params[:version])) ) ||
        ( params[:version] && (not @share.image?) )
      return route_not_found
    end
    if @share.public || ( signed_in? && (@share.user == current_user || current_user.admin?) )
      if params[:version].nil? || Share::IMAGE_VERSIONS_TO_BE_COUNT.include?(params[:version])
        unless @share.user == current_user
          @share.download_count += 1; @share.save
        end
      end
      file = lambda {
        if params[:version]
          return @share.file.send(params[:version])
        else
          return @share.file
        end
      }
      if(request.headers["HTTP_RANGE"])

        size = File.size(file.call.url)
        bytes = Rack::Utils.byte_ranges(request.headers, size)[0]
        offset = bytes.begin
        length = bytes.end  - bytes.begin

        response.header["Accept-Ranges"]=  "bytes"
        response.header["Content-Range"] = "bytes #{bytes.begin}-#{bytes.end}/#{size}"

        send_data IO.binread(file.call.url,length, offset), :type => "video/webm", :stream => true,  :disposition => 'inline',
                  :file_name => @share.original_filename, buffer_size: 4096, status: "206 Partial Content"

      else
        send_file file.call.url, :x_sendfile => true, :filename => @share.original_filename, type: @share.content_type, disposition: "inline"
      end
    else
      redirect_to root_path, alert: t('messages.no_access')
    end
  end

  def upload_from_local
    if current_user
      upload_count = current_user.upload_from_local_path
      respond_to do |format|
        if upload_count > 0
          format.html { redirect_to shares_path, notice: t('messages.upload_from_local_success', count: upload_count) }
        else
          format.html { redirect_to shares_path, alert: t('messages.no_files_to_upload') }
        end
      end
    else
      route_not_found
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_share
      begin
        @share = Share.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        return route_not_found
      end
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def share_params
      if params[:share]   # if params[:share] fix the case when user click update button without selecting new file
        params.require(:share).permit(:file, :original_filename, :public, :tag_list)
      end
    end
end
