class SharesController < ApplicationController
  before_filter :authenticate_user!
  before_action :set_share, only: [:show, :edit, :update, :destroy]

  # GET /shares
  # GET /shares.json
  def index
    @shares = Share.order("created_at desc").page params[:page]
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

    respond_to do |format|
      if @share.save
        format.html { redirect_to @share, notice: 'Share was successfully created.' }
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
        format.html { redirect_to @share, notice: 'Share was successfully updated.' }
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
      format.html { redirect_to shares_url, alert: 'Share was successfully deleted.' }
      format.json { head :no_content }
    end
  end

  def download
    @share = Share.find_by_file(params[:filename]+'.'+params[:extension])
    if user_signed_in? and @share.user == current_user
      send_file @share.file.url, :x_sendfile => true, disposition: "inline"
    else
      redirect_to root_url, alert: 'Forbidden. You don\'t have permission to access this file.'
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
        params.require(:share).permit(:file, :original_filename)
      end
    end
end
