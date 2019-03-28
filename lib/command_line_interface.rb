require_relative "../lib/scraper.rb"
require 'nokogiri'
require 'colorize'

#class CommandLineInterface
#
  def run
    create_macs
    display_macs
    add_attributes_to_macs
  end

  def create_macs
    macs_array = Scraper.scrape_refurbished_macs("https://www.apple.com/shop/refurbished/mac/1tb-15-inch-macbook-pro")
  #  Student.create_from_collection(students_array)
  end

  def add_attributes_to_macs
  #  Student.all.each do |student|
  #    attributes = Scraper.scrape_profile_page(BASE_PATH + student.profile_url)
  #    student.add_student_attributes(attributes)
    end
  end

  def display_macs
  #  Student.all.each do |student|
  #    puts "#{student.name.upcase}".colorize(:blue)
  #    puts "  location:".colorize(:light_blue) + " #{student.location}"
  #    puts "  profile quote:".colorize(:light_blue) + " #{student.profile_quote}"
  #    puts "  bio:".colorize(:light_blue) + " #{student.bio}"
  #    puts "  twitter:".colorize(:light_blue) + " #{student.twitter}"
  #    puts "  linkedin:".colorize(:light_blue) + " #{student.linkedin}"
  #    puts "  github:".colorize(:light_blue) + " #{student.github}"
  #    puts "  blog:".colorize(:light_blue) + " #{student.blog}"
  #    puts "----------------------".colorize(:green)
  #  end
  end
end
