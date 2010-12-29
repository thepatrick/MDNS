class UserSessionsController < ApplicationController
  before_filter :require_no_user, :only => [:new, :create]
  before_filter :require_user, :only => :destroy
  
  def new
    @user_session = UserSession.new
  end
  
  def create
    @user_session = UserSession.new(params[:user_session])
    if @user_session.save
      flash[:notice] = "Login successful!"
      redirect_back_or_default '/client/'
    else
      render :action => :new
    end
  end
  
  def destroy
    current_user_session.destroy
    flash[:notice] = "Logout successful!"
    redirect_back_or_default new_gate_url
  end
  
  def show
    respond_to do |format|
      format.html { redirect_to account_path }
      format.json do 
        render :json => {
          :status => "ok",
          :logged_in => !current_user.nil?,
          :auth_url => current_user && logout_gate_path || new_gate_path(:url => '/client/'),
          :user => current_user && {
            :nickname => current_user.first_name,
            :email => current_user.email
          }
        }
      end
    end
  end
  
end