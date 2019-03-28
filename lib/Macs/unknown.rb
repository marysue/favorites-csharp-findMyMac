require "./config/environment.rb"

class Unknown < Mac
  extend Concerns::Findable
  
  attr_accessor :display, :display_type, :display_size

  def initialize(mac_attrs_hash)
    mac_attrs_hash.each do |key, value|
      if self.respond_to?("#{key}")
        self.send(("#{key}="), value)
      else
        puts ("Key not found:  #{key} for #{self.class} in hash: \n #{mac_attrs_hash}")
      end
    end
  end

  def print
    super
  end

end
