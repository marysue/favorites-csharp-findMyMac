require "./config/environment.rb"

class Mac

  @@all = []
  attr_accessor :model, :cpu, :number_cores, :core_type, :color, :current_price,
                :was_price, :savings, :description, :link, :computer_type,
                :ram, :gpu, :year_released, :hard_drive

  def initialize
    @@all << self
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

  def print
      puts("Computer Type:  #{@computer_type}") unless @computer_type == ""
      puts("Model:          #{@model}") unless @model == ""
      puts("CPU:            #{@cpu}") unless @cpu == ""
      puts("Nbr Cores:      #{@number_cores}") unless @number_cores == ""
      puts("Core Type:      #{@core_type}") unless @core_type == ""
      puts("Hard Drive:     #{@hard_drive}") unless @hard_drive == ""
      puts("RAM:            #{@ram}") unless @ram == ""
      puts("GPU:            #{@gpu}") unless @gpu == ""
      puts("Year Released:  #{@year_released}") unless @year_released == ""
      puts("Color:          #{@color}") unless @color == ""
      puts("Current Price:  #{@current_price}") unless @current_price == ""
      puts("Was Price:      #{@was_price}") unless @was_price == ""
      puts("Savings:        #{@savings}") unless @savings == ""
      puts("Description:    #{@description}") unless @description == ""
      puts("Link            #{@link}") unless @link == ""

  end

  def self.all
    @@all
  end
end
