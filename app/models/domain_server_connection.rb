class DomainServerConnection < ActiveRecord::Base
  
  belongs_to :server
  belongs_to :domain
  
  scope :active, where(:active => true)
  
  before_validation_on_create :default_active
  
  def default_active
    self.active = true
  end
  
end
