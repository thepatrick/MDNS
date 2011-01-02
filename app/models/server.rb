class Server < ActiveRecord::Base
  
  has_many :domain_server_connections
  has_many :domains, :through => :domain_server_connections, :conditions => { :active => true }
  has_many :server_messages
  
  before_validation_on_create :default_key
  
  def message(message)
    if message =~ /^GETDOMAINS/
      yield ['DOMAINS', domains.active.all]
    else
      yield ['ERR']
    end
  end
  
  def default_key
    self.key = Authlogic::Random.hex_token
  end
  
  def push_message(msg)
    server_messages.create :message => msg.to_json
  end
  
end
