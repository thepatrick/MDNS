class HomeController < ApplicationController
  
  def index
    unless current_user
      redirect_to new_gate_path
    end
    redirect_to '/client/'
  end
  
end