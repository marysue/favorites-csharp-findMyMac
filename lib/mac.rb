class Mac

  @@all = []
  attr_accessor :model, :cpu, :number_cores, :core_type, :color, :current_price,
                :was_price, :savings, :description, :link, :computer_type,
                :ram, :gpu, :year_released, :hard_drive, :other,
                :display_size, :display_type, :display, :camera


  def initialize(mac_attrs_hash)
    @@all << self

    #@other = ""
    mac_attrs_hash.each do |key, value|
      if self.respond_to?("#{key}")
        self.send(("#{key}="), value)
      else
          raise ArgumentError.new("Key not found:  #{key} for #{self.class} in hash: \n #{mac_attrs_hash}")
      end
    end
  end

  def add_attrs_by_hash(hash)
    hash.each do |key, value|
      if self.respond_to?("#{key}")
        self.send(("#{key}="), value)
      else
        puts ("Key not found:  #{key} for #{self.class} in hash: \n #{hash}")
      end
    end
  end

  #======================================================================
  # matches :
  #    Examines each users requirement with a given object
  #    returns true if there's a match
  #    if any requirement doesn't match, we stop and return false.
  #======================================================================
  def matches(hash)
    matched = true
    hash.each do |k, v|
      if matched #only continue loop if we continue to match properties
        case k.to_s
          when "cpu"
            @cpu == v ? matched = true : matched = false
          when  "display"
            @display_size == v ? matched = true : matched = false
          when "number_cores"
            @number_cores == v ? matched = true : matched = false
          end #case
        end #if matched
    end #each
    matched
  end


  def print
      puts("Computer Type:  #{@computer_type}") unless @computer_type == "" || @computer_type == nil
      puts("Model:          #{@model}") unless @model == "" || @model == nil
      puts("Display Size:   #{@display_size}") unless @display_size == "" || @display_size == nil
      puts("Display:        #{@display}") unless @display == "" || @display == nil
      puts("Display Type:   #{@display_type}") unless @display_type == "" || @display_type == nil
      puts("CPU:            #{@cpu}") unless @cpu == "" || @cpu == nil
      puts("Nbr Cores:      #{@number_cores}") unless @number_cores == "" || @number_cores == nil
      puts("Core Type:      #{@core_type}") unless @core_type == "" || @core_type == nil
      puts("Hard Drive:     #{@hard_drive}") unless @hard_drive == "" || @hard_drive == nil
      puts("RAM:            #{@ram}") unless @ram == "" || @ram == nil
      puts("GPU:            #{@gpu}") unless @gpu == "" || @gpu == nil
      puts("Camera:         #{@camera}") unless @camera == "" || @camera == nil
      puts("Year Released:  #{@year_released}") unless @year_released == "" || @year_released == nil
      puts("Color:          #{@color}") unless @color == "" || @color == nil
      puts("Current Price:  #{@current_price}") unless @current_price == "" || @current_price == nil
      puts("Was Price:      #{@was_price}") unless @was_price == "" || @was_price == nil
      puts("Savings:        #{@savings}") unless @savings == "" || @savings == nil
      puts("Description:    #{@description}") unless @description == "" || @description == nil
      puts("Link            #{@link}") unless @link == "" || @link == nil
      puts("Other           #{@other}") unless @other == "" || @other == nil
  end

  def self.all
    @@all
  end

  def printOther
    @@all.each { |x| puts("Other:  #{x.other}") unless x.other == "" || x.other == nil}
    nil
  end

  def printDisplay
    @@all.each { |x| puts("Display:  #{x.display}") unless x.display == "" || x.display == nil}
    nil
  end
end
