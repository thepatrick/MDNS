class DomainsController < ApplicationController
  
  before_filter :require_user
  respond_to :json
  respond_to :text, :only => :show
  def index
    respond_with(@domains = current_user.domains.all)
  end
  
  def show
    respond_with(@domain = current_user.domains.find(params[:id])) do |format|
      format.text do
        render :text => @domain.zone_file
      end
    end
  end
  def create
    @domain = current_user.domains.new(params[:domain])
    if @domain.save
      respond_with @domain, :status => :created, :location => @domain
    else
      respond_with @domain.errors, :status => :unprocessable_entity
    end
  end

  # PUT /ds/1
  # PUT /ds/1.xml
  def update
    @domain = current_user.domains.find(params[:id])
    if @domain.update_attributes(params[:domain])
      head :ok
    else
      respond_with @domain.errors, :status => unprocessable_entity
    end
  end

  # DELETE /ds/1
  # DELETE /ds/1.xml
  def destroy
    @domain = current_user.domains.find(params[:id])
    @domain.destroy
    head :ok
  end
  
  def publish
    @domain = current_user.domains.find(params[:id])
    @domain.publish!
    respond_with(@domain)
  end

end
