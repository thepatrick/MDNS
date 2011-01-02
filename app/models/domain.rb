class Domain < ActiveRecord::Base
  
  belongs_to :user
  has_many :records
  has_many :domain_server_connections
  has_many :servers, :through => :domain_server_connections, :conditions => { :active => true }
  
  scope :active, where(:active => true).where('zone_file IS NOT NULL')
  
  before_validation_on_create :set_deafults
  
  def set_deafults
    self.default_ttl = 1.hour
    self.version = 1
    self.expire = 24.hours
    self.retry = 10.minutes 
    self.refresh = 1.hour
    self.servers << Server.all # by default add all servers
  end
  
  def bump_version
    today = Time.now.to_date
    if self.updated_at.to_date == today
      self.builds_today = builds_today + 1
    else
      self.builds_today = 1
    end
    self.version = (today.strftime("%Y%m%d") + ("%02d" % self.builds_today)).to_i
  end
  
  def publish!
    bump_version
    populate_zone_file
    save!
    servers.map { |s| s.push_message(:kind => 'DOMAINPUSH', :domain => id); }
  end
  
  def populate_zone_file
    zf = Zonefile.new
    
    zf.soa[:ttl]        = ""
    zf.soa[:minimumTTL] = default_ttl
    zf.soa[:serial]     = version
    zf.soa[:email]      = "hostmaster"
    zf.soa[:origin]     = "@"
    zf.soa[:expire]     = expire
    zf.soa[:primary]    = "s1.dns.m.ac.nz."
    zf.soa[:retry]      = self.retry
    zf.soa[:refresh]    = refresh
    
    records.of_type('A').each do |r|
      zf.a << r.to_zone
    end
    records.of_type('AAAA').each do |r|
      zf.a4 << r.to_zone
    end
    records.of_type('CNAME').each do |r|
      zf.cname << r.to_zone
    end
    records.of_type('MX').each do |r|
      zf.mx << r.to_zone
    end
    records.of_type('NS').each do |r|
      zf.ns << r.to_zone
    end
    records.of_type('SRV').each do |r|
      zf.srv << r.to_zone
    end
    records.of_type('TXT').each do |r|
      zf.txt << r.to_zone
    end
    self.zone_file = zf.output
  end
  
  def as_json(options = {})
    super((options || {}).merge({ :include => {:servers => { :only => [:ip, :identifier] }} }))    
  end
  
end
