class Record < ActiveRecord::Base
  
  belongs_to :domain
  
  scope :of_type, lambda { |t| where('resource_type = ?', t) }
  
  def to_zone
    { :class => 'IN', :name => name, (resource_type == 'TXT' ? :text : :host) => self.target, :ttl => domain.default_ttl }.merge(weight_zone).merge(priorty_zone).merge(port_zone)
  end
  
  def weight_zone
    has_weight? ? { :weight => weight } : {}
  end
  
  def priorty_zone
    has_weight? ? { :pri => priority } : {}
  end
  
  def port_zone
    has_port? ? { :port => port } : {}    
  end
  
  def has_weight?
    resource_type == 'SRV'
  end
  
  def has_priority?
    resource_type == 'SRV' or resource_type == 'MX'
  end
  
  def has_port?
    resource_type == 'SRV'
  end
  
end


# t.integer :domain_id, :null => false
# t.string :name, :null => false
# t.string :resource_type
# t.integer :priority
# t.integer :weight
# t.integer :port
# t.integer :target

# SRV = weight, port
# MX = weight