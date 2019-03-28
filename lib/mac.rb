require "./config/environment.rb"

class Mac

  @@all = []
  attr_accessor :model, :cpu, :number_cores, :core_type, :color, :current_price, :was_price, :savings, :description, :link, :computer_type

  def initialize
    @@all << self
  end

  def print
      puts("Computer Type:  #{@computer_type}")
      puts("Model:          #{@model}")
      puts("CPU:            #{@cpu}")
      puts("Nbr Cores:      #{@number_cores}")
      #puts("Core Type:      #{@core_type}")
      #puts("Color:          #{@color}")
      #puts("Current Price:  #{@current_price}")
      #puts("Was Price:      #{@was_price}")
      #puts("Savings:        #{@savings}")
      puts("Description:    #{@description}")
      #puts("Link            #{@link}")

  end

  def self.all
    @@all
  end
end
