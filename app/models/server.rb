class Server < ActiveRecord::Base
  
  def message(message)
    yield ['OK']
    # if message =~ /^CONNECT (.*) (.*)/
    #   if @server = Server.where(:identifier => $1, :key => $2).first
    #     yield ['OK', { :message => "Authetnicated" }]
    #   else
    #     update_attribute :server_id, nil
    #     yield ['FAIL', {:message => "Server details not recognised"}]
    #   end
    # else
    #   yield ['ERR']
    # end
  end
  
  def before_validation_on_create
    self.key = Authlogic::Random.hex_token
  end
  
end
