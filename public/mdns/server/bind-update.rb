#!/usr/bin/env ruby

require 'rubygems'
require 'getoptlong'
require 'date'
require 'open-uri'
require 'json'

def execute(command)
    IO.popen("-") do |f|
        if f
            text = f.read
            return text
        else
            $stderr.close
            $stderr = $stdout.dup
            system(*command)
            exit!
        end
    end
end

unless File.exists?('/tmp/mdns-trigger-update')
  puts "No update needed."
  exit
end

this_is_primary  = File.exists?('/etc/mdns-primary')
primary_server   = "216.218.223.103"
secondary_server = "65.111.164.147; 78.110.170.92;"

restart_bind = true

server_root = "http://dns.m.ac.nz/dnsconfig/api"
api_key = "api.key=servers.mdns.patrick.geek.nz"

path_to_updates = server_root + "/domain/all?" + api_key

read_data = open(path_to_updates).read

x = JSON.parse(read_data)

stuff_base = "/etc/bind"
# stuff_base = "/Users/patrick/Desktop"

File.open(stuff_base + "/named.conf.mdns", "w") do |f|
  f << ""
end

#puts x['domains']

x['domains'].each do |y|
  
  path_to_zone = "" + server_root + "/domain/zonefile?id=" + y['key'] + "&" + api_key
  puts y['fqdn'] + ", with version " + y["version"].to_s 
	#+ ". Get from: " + path_to_zone
  
  File.open(stuff_base + "/named.conf.mdns", "a") do |f|
    f <<  "zone \"" + y['fqdn'] + ".\" {\n"
    
    if(this_is_primary)
      f <<  "  type master;\n"
      f <<  "  file \""+ stuff_base + "/zones/" + y ['fqdn'] + ".mdns-zone\";\n"
      f <<  "  allow-update { none; };\n"
      f <<  "  notify explicit;\n"
      f <<  "  allow-transfer { " + secondary_server + " };\n"
      f <<  "  also-notify { " + secondary_server + " };\n"      
    else
      f <<  "  type slave;\n"
      f <<  "  notify no;\n"
      f <<  "  file \"" + y ['fqdn'] + ".mdns-zone\";\n"
      f <<  "  masters { " + primary_server + "; };"
    end
    
    f <<  "};\n"
    f <<  "\n"
  end
  
  if(this_is_primary)
    File.open(stuff_base + "/zones/" + y['fqdn'] + ".mdns-zone", "w") do |f|
      f << open(path_to_zone).read
    end
  end
  
end

if restart_bind
  puts execute("/etc/init.d/bind9 reload")
end

File.unlink('/tmp/mdns-trigger-update')