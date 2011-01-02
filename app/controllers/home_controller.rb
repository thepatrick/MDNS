class HomeController < ApplicationController
  
  def index
    unless current_user
      redirect_to new_gate_path
    else
      redirect_to '/client/' 
    end
  end
  
end