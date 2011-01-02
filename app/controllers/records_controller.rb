class RecordsController < ApplicationController
  
  before_filter :user_from_token
  before_filter :require_user
  
  respond_to :json
  
  before_filter :get_domain
  
  def get_domain
    @domain = Domain.find(params[:domain_id])
  end

  def index
    respond_with(@records = @domain.records.all)
  end
  
  def show
    respond_with(@record = @domain.records.find(params[:id]))
  end
  
  def create
    @record = @domain.records.build(params[:record])
    if @record.save
      respond_with @record, :status => :created, :location => domain_record_path(@domain, @record)
    else
      respond_with @record.errors, :status => :unprocessable_entity
    end
  end
  
  def update
    @record = @domain.records.find(params[:id])
    if @record.update_attributes(params[:record])
      head :ok
    else
      respond_with @record.errors, :status => unprocessable_entity
    end
  end
  
  def destroy
    @record = @domain.records.find(params[:id])
    @record.destroy
    head :ok
  end

end
