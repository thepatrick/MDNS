class AdminController < ApplicationController

  before_filter :require_user
  
  before_filter :require_admin
  
  def index
  end
  
end