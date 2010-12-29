class AdminDomainsController < ApplicationController
  
  before_filter :require_user
  before_filter :require_admin
  
  def index
    @domains = Domain.order('fqdn ASC').all
  end
  
  def toggle
    @domain = Domain.find(params[:admin_domain_id])
    @domain.active = !@domain.active
    @domain.save
    redirect_to admin_domain_index_path
  end
  
end