class Domain < ActiveRecord::Base
  
  belongs_to :user
  has_many :records
  
  def before_validation_on_create
    self.default_ttl = 1.hour
    self.serial = 1
    self.expire = 24.hours
    self.retry = 10.minutes 
    self.refresh = 1.hour
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
  
end
