class RecordsController < ApplicationController
  
  before_filter :require_user
  respond_to :json
  
  before_filter :get_domain
  
  def get_domain
    @domain = Domain.find(params[:domain_id])
  end

  def index
    respond_with(@records = @domain.records.all)
  end
  q
  def show
    respond_with(@record = @domain.records.find(params[:id]))
  end
  
  def create
    @record = @domain.records.build(params[:record])
    if @record.save
      respond_with @record, :status => :created, :location => @record
    else
      respond_with @record.errors, :status => :unprocessable_entity
    end
  end
  
  # def update
  #   @domain = current_user.domains.find(params[:id])
  #   if @domain.update_attributes(params[:d])
  #     head :ok
  #   else
  #     respond_with @domain.errors, :status => unprocessable_entity
  #   end
  # end
  # 
  # def destroy
  #   @domain = current_user.domains.find(params[:id])
  #   @domain.destroy
  #   head :ok
  # end
  # 
  # def publish
  #   @domain = current_user.domains.find(params[:id])
  #   @domain.publish!
  #   respond_with(@domain)
  # end

end
