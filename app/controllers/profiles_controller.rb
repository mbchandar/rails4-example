class ProfilesController < ApplicationController
  before_filter :authenticate_user!
  before_action :set_user, only: [:edit, :update, :destroy]

  def edit
    authorize! :edit, @user
    respond_to do |format|
      format.html { redirect_to admin_path }
      format.js
    end   
  end
  
  def update
    authorize! :update, @user
    if @user.update(user_params)
      @users = User.order("role,username")
      flash[:info] = t('devise.registrations.update_user')
    else
      @errors_found = true
    end
    respond_to do |format|
      format.html { redirect_to admin_path }
      format.js
    end
  end
  
  def destroy
    authorize! :delete, @user
    @user.destroy
    @users = User.order("role,username")
    respond_to do |format|
      format.html { redirect_to admin_path }
      format.js
    end
  end

  def create
    if params[:user]
      pwd = SecureRandom.hex(8)
      # use a reset_password_token to force password creation on confirmation
      raw, enc = Devise.token_generator.generate(User, :reset_password_token)
      options = {:username => params[:user][:username], :email => params[:user][:email], :password => pwd, :password_confirmation => pwd, :reset_password_token => enc, :role => 'user'} if params[:user]
      user = User.new(options)
      authorize! :create, user
      unless user.save
        @error_message = user.errors.full_messages.map{|s| s}.join('<br />') if user.errors
        @error_message ||= t(:cannot_save_new_user, :scope => 'devise.errors.messages')
      end
    else
      @error_message ||= t(:cannot_save_new_user, :scope => 'devise.errors.messages')
    end
    @users = User.order("role,username")
    respond_to do |format|
      format.html { redirect_to admin_path }
      format.js { render :layout=>false }
    end
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:username, :email, :role)
  end

end
