class UsersController < ApplicationController
  #before_filter :authenticate_user!
  #load_and_authorize_resource skip_load_resource only: [:create] # let CanCan to not throwing ForbiddenAttributesError exception

  before_action :set_user, only: [:show, :edit, :destroy, :update]
  before_action :allow_only_admin  # Not using CanCan in this controller

  def index
    @users = User.all.order(created_at: :desc).page params[:page]
  end

  def show
  end

  def new
    @user = User.new
  end

  def edit
    @hide_password = true #disallow change passwords, it's handled by Device
  end

  def create
    @user = User.new(user_params)
    @user.confirm!

    respond_to do |format|
      if @user.save
        format.html { redirect_to @user, notice: t('messages.user_created') }
        format.json { render action: 'show', status: :created, location: @user }
      else
        format.html { render action: 'new' }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    if params[:user][:password].blank?
      params[:user].delete(:password)
      params[:user].delete(:password_confirmation)
    end

    respond_to do |format|
      if @user.update(user_params)
        format.html { redirect_to @user, notice: t('messages.user_updated')}
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    respond_to do |format|
      if @user.admin?
        format.html { redirect_to users_path, alert: t('messages.cannot_delete_admin') }
        format.json { render action: 'show', status: :created, location: @user }
      elsif @user.destroy
        format.html { redirect_to users_url, alert: t('messages.user_deleted') }
        format.json { head :no_content }
      end
    end
  end

  private
  # Use callbacks to user common setup or constraints between actions.
  def set_user
    begin
      @user = User.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      return route_not_found
    end
  end

  def allow_only_admin
    return route_not_found unless (current_user && current_user.admin?)
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def user_params
    params.require(:user).permit(:email, :password, :password_confirmation, :current_password, :show_links)
  end

end
