class SharesController < ApplicationController
  before_filter :authenticate_user!, except: [:show, :download]
  before_action :set_share, only: [:show, :edit, :update, :destroy, :turn_publicity]
  load_and_authorize_resource

  # GET /shares
  # GET /shares.json
  def index
    @shares = Share.where(user_id: current_user.id).type(@shares, params[:type]).order("created_at desc").page params[:page]
  end

  # GET /shares/1
  # GET /shares/1.json
  def show
  end

  # GET /shares/new
  def new
    @share = Share.new
  end

  # GET /shares/1/edit
  def edit
  end

  # POST /shares
  # POST /shares.json
  def create
    @share = Share.new(share_params)
    @share.user = current_user

    #5.times do
    #  @share = Share.new(share_params)
    #  @share.user = current_user
    #  @share.save
    #end

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
        format.html { redirect_to @share, notice: t('messages.share_updated') }
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
      format.html { redirect_to shares_url, alert: t('messages.share_deleted') }
      format.json { head :no_content }
    end
  end

  def download
    @share = Share.find_by_file(params[:filename]+'.'+params[:extension])
    if not @share or (not Share::IMAGE_VERSIONS.include?(params[:version]) and not params[:version].nil?)
      return route_not_found
    end
    if (@share.user == current_user) or (signed_in? and current_user.admin?) or @share.public
      file = if params[:version]
        @share.file.send(params[:version]) if params[:version] and Share::IMAGE_VERSIONS.include?(params[:version])
      else
        @share.file
      end
      send_file file.url, :x_sendfile => true, :filename => @share.original_filename, disposition: "inline"
    else
      redirect_to root_url, alert: t('messages.no_access')
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_share
      @share = Share.find(params[:id])
      @share.file
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def share_params
      if params[:share]   # if params[:share] fix the case when user click update button without selecting new file
        params.require(:share).permit(:file, :original_filename, :public)
      end
    end
end
