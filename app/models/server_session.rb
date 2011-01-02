class ServerSession
  
  attr_accessor :server
  
  def message(m, &block)
    server ? server.message(m, &block) : unauthenticated_message(m, &block)
  end
  
  def unauthenticated_message(message)
    if message =~ /^CONNECT (.*) (.*)/
      if @server = Server.where(:identifier => $1, :key => $2).first
        yield ['OK', { :message => "Authetnicated" }]
      else
        update_attribute :server_id, nil
        yield ['FAIL', {:message => "Server details not recognised"}]
      end
    else
      yield ['ERR']
    end
  end
  
end