class RecordtypesController < ApplicationController
  
  before_filter :require_user
  respond_to :json
  
  def index
    respond_with([
      { :type => 'A', :hasPriority => false, :hasWeight => false, :hasPort => false },
      { :type => 'AAAA', :hasPriority => false, :hasWeight => false, :hasPort => false },
      { :type => 'CNAME', :hasPriority => false, :hasWeight => false, :hasPort => false },
      { :type => 'MX', :hasPriority => true, :hasWeight => false, :hasPort => false },
      { :type => 'NS', :hasPriority => false, :hasWeight => false, :hasPort => false },
      { :type => 'SRV', :hasPriority => true, :hasWeight => true, :hasPort => true },
      { :type => 'TXT', :hasPriority => false, :hasWeight => false, :hasPort => false }
    ])
  end
  
end


