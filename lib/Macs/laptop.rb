require "./config/environment.rb"

class Laptop < Mac
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
    puts("Display:          #{self.display}")
    puts("Display Type:     #{self.display_type}")
    puts("Display Size:     #{self.display_size}")
  end
end
