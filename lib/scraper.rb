class Scraper
  attr_accessor :scraperHash

  def self.get_details(url, cssStr)
    html = open(url).read
    page = Nokogiri::HTML(html)
    page.css(cssStr)
  end

  def self.clean_up(inStr)
    inStr = inStr.gsub("\n", "")
    inStr = inStr.gsub("Was", "")
    inStr = inStr.gsub("Save","")
    inStr = inStr.gsub(" ", "")
    inStr
  end

  def self.scrape_refurbished_mac(url="https://www.apple.com/shop/refurbished/mac/1tb-15-inch-macbook-pro")
    hashArr = []
    page = get_details(url, 'div.refurbished-category-grid-no-js')
    line_items_arr = page.css('li')

    line_items_arr.each do |x|
      link = x.css('a')[0]['href']
      if (link != nil)
          description =  x.css('a')[0].children[0].text
          link = "https://www.apple.com" + link
      else
          description = ""
      end

      description_hash = create_description_hash(description)
      was_price = clean_up(x.css('span.as-price-previousprice').text)
      current_price = clean_up(x.css('div.as-price-currentprice').text)
      savings = clean_up(x.css('span.as-producttile-savingsprice').text)

      hash = {
          :cpu => description_hash[:cpu],
          :display_size => description_hash[:display_size],
          :number_cores => description_hash[:number_cores],
          :core_type => description_hash[:core_type],
          :display_type => description_hash[:display_type],
          :color => description_hash[:color],
          :model => description_hash[:model],
          :computer_type => description_hash[:computer_type],
          :link => link,
          :description => description,
          :current_price => current_price,
          :was_price => was_price,
          :savings => savings
        }
        #print_hash(hash)
        hashArr << hash.reject{ |k,v| v == nil || v == ""}
    end #for each li

    return hashArr; 1

  end #scrape_refurbished_macs

  def self.getDetail(str)
    retStr = nil
    #looking for RAM, HardDrive, GPU, dateReleased
    if str.include?("released")
      retStr = "YearReleased"
    elsif str.include?("Radeon") || str.include?("Graphics") #MUST fire before memory as both use string memory
      retStr = "GPU"
    elsif str.include?("memory")
      retStr = "RAM"
    elsif str.include?("SSD")
      retStr = "HardDrive"
    elsif str.include?("Camera")
      retStr = "Camera"
    elsif str.downcase.include?("display")
      retStr = "Display"
    else
      retStr = "Other"
    end #if
    retStr
  end

  def self.scrape_addl_info(url="https://www.apple.com/shop/product/G0UC3LL/A/Refurbished-154-inch-MacBook-Pro-31GHz-Quad-core-Intel-Core-i7-with-Retina-display-Space-Gray?fnode=e6dc8e0258d94d542289be52a9dc6eb1aec38e58149c9f96393ca5f5dd1947506c4c6f73db201cac625df431694aeebff4542a5960107e79058082c5204031ee22014d8beee65baa824d71488c78a1e6")
    hashArr = {}
    mainpanel = get_details(url, 'div.as-productinfosection-mainpanel')
    paragraphs = mainpanel[0].css('p')

    ram = year_released = gpu = hard_drive = other = camera = display = ""
    paragraphs.each do |x|
      detailStr = x.text.lstrip
      detailStr = detailStr.rstrip
      detail = getDetail(detailStr)

      case detail
        when "RAM"
          ram = detailStr
        when "HardDrive"
          hard_drive = detailStr
        when "YearReleased"
          year_released = detailStr
        when "GPU"
          gpu = detailStr
        when "Other"
          other = detailStr
        when "Camera"
          camera = detailStr
        when "Display"
          display = detailStr
      end
    end #for each paragraph

    hash = {
        :ram => ram,
        :hard_drive => hard_drive,
        :year_released => year_released,
        :gpu => gpu,
        :camera => camera,
        :display => display,
        :other => other
      }

      hash = hash.reject{ |k,v| v == nil || v == ""}
  end #scrape_addl_info


  def self.sort(arr)
    tmpArr = []
    arr.each do |x|
      tmpArr << x[:description]
    end
    tmpArr
  end

  #method used for testing
  def self.create_descriptions_hash_from_array(descriptions)
    descriptions = ["Refurbished 12-inch MacBook 1.2GHz dual-core Intel Core m3 - Gold",
    "Refurbished 12-inch MacBook 1.2GHz dual-core Intel Core m3 - Rose Gold",
    "Refurbished 12-inch MacBook 1.2GHz dual-core Intel Core m3 - Silver",
    "Refurbished 12-inch MacBook 1.2GHz dual-core Intel Core m3 - Space Gray",
    "Refurbished 12-inch MacBook 1.2GHz dual-core Intel Core m3-Gold",
    "Refurbished 12-inch MacBook 1.3GHz dual-core Intel Core i5 - Gold",
    "Refurbished 12-inch MacBook 1.3GHz dual-core Intel Core i5 - Rose Gold",
    "Refurbished 12-inch MacBook 1.3GHz dual-core Intel Core i5 - Silver",
    "Refurbished 12-inch MacBook 1.3GHz dual-core Intel Core i5-Space Gray",
    "Refurbished 12-inch MacBook 1.4GHz dual-core Intel Core i7 - Gold",
    "Refurbished 12-inch MacBook 1.4GHz dual-core Intel Core i7 - Rose Gold",
    "Refurbished 12-inch MacBook 1.4GHz dual-core Intel Core i7 - Silver",
    "Refurbished 12-inch MacBook 1.4GHz dual-core Intel Core i7 - Space Gray",
    "Refurbished 13.3-inch MacBook Air 1.6GHz dual-core Intel Core i5 with Retina Display - Gold",
    "Refurbished 13.3-inch MacBook Air 1.6GHz dual-core Intel Core i5 with Retina Display - Silver",
    "Refurbished 13.3-inch MacBook Air 1.6GHz dual-core Intel Core i5 with Retina Display - Space Gray",
    "Refurbished 13.3-inch MacBook Air 1.8GHz dual-core Intel Core i5",
    "Refurbished 13.3-inch MacBook Air 2.2GHz dual-core Intel Core i7",
    "Refurbished 13.3-inch MacBook Pro 2.3GHz dual-core Intel Core i5 with Retina display - Silver",
    "Refurbished 13.3-inch MacBook Pro 2.3GHz dual-core Intel Core i5 with Retina display - Space Gray",
    "Refurbished 13.3-inch MacBook Pro 2.3GHz quad-core Intel Core i5 with Retina display - Silver",
    "Refurbished 13.3-inch MacBook Pro 2.3GHz quad-core Intel Core i5 with Retina display - Space Gray",
    "Refurbished 13.3-inch MacBook Pro 2.7GHz quad-core Intel Core i7 with Retina display - Silver",
    "Refurbished 13.3-inch MacBook Pro 2.7GHz quad-core Intel Core i7 with Retina display - Space Gray",
    "Refurbished 13.3-inch MacBook Pro 3.1GHz dual-core Intel Core i5 with Retina display - Silver",
    "Refurbished 13.3-inch MacBook Pro 3.1GHz dual-core Intel Core i5 with Retina display - Space Gray",
    "Refurbished 13.3-inch MacBook Pro 3.5GHz dual-core Intel Core i7 with Retina display - Silver",
    "Refurbished 13.3-inch MacBook Pro 3.1GHz dual-core Intel Core i5 with Retina display - Space Gray",
    "Refurbished 13.3-inch MacBook Pro 3.5GHz dual-core Intel Core i7 with Retina display - Silver",
    "Refurbished 13.3-inch MacBook Pro 3.5GHz dual-core Intel Core i7 with Retina display - Space Gray",
    "Refurbished 13.3-inch MacBook Pro 2.0GHz Dual-core Intel Core i5 with Retina Display - Silver",
    "Refurbished 13.3-inch MacBook Pro 2.0GHz Dual-core Intel Core i5 with Retina Display - Space Gray",
    "Refurbished 13.3-inch MacBook Pro 2.9GHz Dual-core Intel Core i5 with Retina Display - Space Gray",
    "Refurbished 13.3-inch MacBook Pro 3.3GHz Dual-core Intel Core i7 with Retina Display - Space Gray",
    "Refurbished 13.3-inch Macbook Pro 2.9GHz Dual-core Intel Core i5 with Retina Display - Silver",
    "Refurbished 13.3-inch Macbook Pro 2.9GHz Dual-core Intel Core i5 with Retina Display - Space Gray",
    "Refurbished 13.3-inch Macbook Pro 3.3GHz Dual-core Intel Core i7 with Retina Display - Silver",
    "Refurbished 13.3-inch Macbook Pro 3.3GHz Dual-core Intel Core i7 with Retina Display - Space Gray",
    "Refurbished 15.4-inch MacBook Pro 2.2GHz 6-core Intel Core i7 with Retina display - Silver",
    "Refurbished 15.4-inch MacBook Pro 2.2GHz 6-core Intel Core i7 with Retina display - Space Gray",
    "Refurbished 15.4-inch MacBook Pro 2.6GHz 6-core Intel Core i7 with Retina display - Silver",
    "Refurbished 15.4-inch MacBook Pro 2.6GHz 6-core Intel Core i7 with Retina display - Space Gray",
    "Refurbished 15.4-inch MacBook Pro 2.9GHz 6-core Intel Core i9 with Retina display - Silver",
    "Refurbished 15.4-inch MacBook Pro 2.9GHz 6-core Intel Core i9 with Retina display - Space Gray",
    "Refurbished 15.4-inch MacBook Pro 2.9GHz Quad-core Intel Core i7 with Retina display - Silver",
    "Refurbished 15.4-inch MacBook Pro 2.9GHz Quad-core Intel Core i7 with Retina display - Space Gray",
    "Refurbished 15.4-inch MacBook Pro 3.1GHz Quad-core Intel Core i7 with Retina display - Silver",
    "Refurbished 15.4-inch MacBook Pro 3.1GHz Quad-core Intel Core i7 with Retina display - Space Gray",
    "Refurbished 15.4-inch MacBook Pro 2.9GHz Quad-core Intel Core i7 with Retina display - Silver",
    "Refurbished 15.4-inch Macbook Pro 2.6GHz Quad-core Intel Core i7 with Retina display - Space Gray",
    "Refurbished 15.4-inch Macbook Pro 2.7GHz Quad-core Intel Core i7 with Retina display - Space Gray",
    "Refurbished 15.4-inch Macbook Pro 2.9GHz Quad-core Intel Core i7 with Retina display - Silver",
    "Refurbished 15.4-inch Macbook Pro 2.9GHz Quad-core Intel Core i7 with Retina display - Space Gray",
    "Refurbished 21.5-inch iMac 2.3GHz dual-core Intel Core i5",
    "Refurbished 21.5-inch iMac 3.0GHz quad-core Intel Core i5 with Retina 4K display",
    "Refurbished 21.5-inch iMac 3.4GHz quad-core Intel Core i5 with Retina 4K display",
    "Refurbished 21.5-inch iMac 3.6GHz quad-core Intel Core i7 with Retina 4K display",
    "Refurbished 27-inch iMac 3.4GHz quad-core Intel Core i5 with Retina 5K display",
    "Refurbished 27-inch iMac 3.5GHz quad-core Intel Core i5 with Retina 5K display",
    "Refurbished 27-inch iMac 3.8GHz quad-core Intel Core i5 with Retina 5K display",
    "Refurbished 27-inch iMac 4.2GHz quad-core Intel Core i7 with Retina 5K display",
    "Refurbished 27-inch iMac Pro 2.3GHz 18-core Intel Xeon W with Retina 5K display",
    "Refurbished 27-inch iMac Pro 3.0GHz 10-core Intel Xeon W with Retina 5K display",
    "Refurbished 27-inch iMac Pro 3.2GHz 8-core Intel Xeon W with Retina 5K display",
    "Refurbished Mac Mini 2.6GHz Dual-core Intel Core i5",
    "Refurbished Mac Mini 2.8GHz Dual-core Intel Core i5",
    "Refurbished Mac Mini 3.0GHz Dual-core Intel Core i7",
    "Refurbished Mac Pro 2.7GHz 12-Core Intel Xeon E5",
    "Refurbished Mac Pro 3.0GHz 8-Core Intel Xeon E5",
    "Refurbished Mac Pro 3.5GHz 6-Core Intel Xeon E5",
    "Refurbished Mac mini 3.0GHz 6-core Intel Core i5 - Space Gray",
    "Refurbished Mac mini 3.2GHz 6-core Intel Core i7 - Space Gray",
    "Refurbished Mac mini 3.6GHz quad-core Intel Core i3 - Space Gray"]

    for i in 0 .. descriptions.size - 1 do
      descriptions[i] = descriptions[i].gsub("-Space", " - Space")
      descriptions[i] = descriptions[i].gsub("-Gold", " - Gold")
      descriptions[i] = descriptions[i].gsub("-Silver", " - Silver")
      descriptions[i] = descriptions[i].gsub(" ", "|")
      descriptions[i] = descriptions[i].gsub("Refurbished", "")
      descriptions[i] = descriptions[i].gsub("Mac|mini", "Mac Mini")
      descriptions[i] = descriptions[i].gsub("Mac|Mini", "Mac Mini")
      descriptions[i] = descriptions[i].gsub("Mac|Pro", "Mac Pro")
      descriptions[i] = descriptions[i].gsub("iMac|Pro", "iMac Pro")
      descriptions[i] = descriptions[i].gsub("MacBook|Pro", "MacBook Pro")
      descriptions[i] = descriptions[i].gsub("Macbook|Pro", "MacBook Pro")
      descriptions[i] = descriptions[i].gsub("|Air", " Air")
      descriptions[i] = descriptions[i].gsub("|inch", " inch")
      descriptions[i] = descriptions[i].gsub("Intel|Core|", "Intel Core ")
      descriptions[i] = descriptions[i].gsub("Intel|Xeon|", "Intel Xeon ")
      descriptions[i] = descriptions[i].gsub("quad|", "quad ")
      descriptions[i] = descriptions[i].gsub("dual|", "dual ")
      descriptions[i] = descriptions[i].gsub("with|", "")
      descriptions[i] = descriptions[i].gsub("Retina|", "Retina ")
      descriptions[i] = descriptions[i].gsub("|display", " display")
      descriptions[i] = descriptions[i].gsub("|-|", "|")
      descriptions[i] = descriptions[i].gsub("|Gray", " Gray ")
    end #formatting descriptions
    hashArr = []
    hash = {}

    for i in 0 .. descriptions.size-1 do
      tmpArr = descriptions[i].split("|")
      display_size = model = cpu = number_cores = core_type = color = ""
      for j in 0 .. tmpArr.size-1 do
        if tmpArr[j].include?("inch")
            display_size = tmpArr[j]
        elsif tmpArr[j].include?("Mac")
            model = tmpArr[j]
        elsif tmpArr[j].include?("GHz")
          cpu = tmpArr[j]
        elsif tmpArr[j].include?("-core")
            number_cores = tmpArr[j]
        elsif tmpArr[j].include?("Intel")
            core_type = tmpArr[j]
        elsif tmpArr[j].include?("Retina")
            display_type = tmpArr[j]
        elsif tmpArr[j].include?("Gold") || tmpArr[j].include?("Silver") || tmpArr[j].include?("Gray") || tmpArr[j].include?("Rose")
            color = tmpArr[j]
        elsif tmpArr[j] != ""
            puts("Error message here...our description doesn't include expected values:  #{tmpArr[j]}")
        end #if
      end #j
      hash = {
        :display_size => display_size,
        :model => model,
        :cpu => cpu,
        :number_cores => number_cores,
        :core_type => core_type,
        :color => color,
        :display_type => display_type
      }
      hashArr << hash.reject{|k,v| v == ""}
    end  #i
    hashArr
  end #test

  def self.formatDescription(description)
    #takes description string and seperates into "|" delimited fields

    #setup description string for some level of consistency
    description = description.gsub("-Space", " - Space")
    description = description.gsub("-Gold", " - Gold")
    description = description.gsub("-Silver", " - Silver")

    #now put separators in everywhere
    description = description.gsub(" ", "|")
    description = description.gsub("\u00A0", " ")

    #now fix separators so they don't separate mid-field
    description = description.gsub("Refurbished", "")
    description = description.gsub("Mac|mini", "Mac Mini")
    description = description.gsub("Mac|Mini", "Mac Mini")
    description = description.gsub("Mac|Pro", "Mac Pro")
    description = description.gsub("iMac|Pro", "iMac Pro")
    description = description.gsub("MacBook|Pro", "MacBook Pro")
    description = description.gsub("Macbook|Pro", "MacBook Pro")
    description = description.gsub("Macbook Pro", "MacBook Pro")
    description = description.gsub("|Air", " Air")
    description = description.gsub("|inch", " inch")
    description = description.gsub("Intel|Core|", "Intel Core ")
    description = description.gsub("Intel|Xeon|", "Intel Xeon ")
    description = description.gsub("quad|", "Quad ")
    description = description.gsub("quad", "Quad")
    description = description.gsub("dual|", "Dual ")
    description = description.gsub("dual", "Dual")
    description = description.gsub("-core", "-Core")
    description = description.gsub("with|", "")
    description = description.gsub("Retina|", "Retina ")
    description = description.gsub("|display", " display")
    description = description.gsub("|-|", "|")
    description = description.gsub("|Gray", " Gray ")
  end

  def self.create_description_hash(description)
    description = formatDescription(description)

    hash = {}

    #load up our hash
    tmpArr = description.split("|")
    display_size = model = cpu = number_cores = core_type = color = ""
    for j in 0 .. tmpArr.size-1 do
      if tmpArr[j].include?("inch")
          display_size = tmpArr[j]
      elsif tmpArr[j].include?("Mac")
          model = tmpArr[j]
      elsif tmpArr[j].include?("GHz")
        cpu = tmpArr[j]
      elsif tmpArr[j].include?("-core") || tmpArr[j].include?("-Core")
          number_cores = tmpArr[j]
      elsif tmpArr[j].include?("Intel")
          core_type = tmpArr[j]
      elsif tmpArr[j].include?("Retina")
          display_type = tmpArr[j]
      elsif tmpArr[j].include?("Gold") || tmpArr[j].include?("Silver") || tmpArr[j].include?("Gray") || tmpArr[j].include?("Rose")
          color = tmpArr[j]
      elsif tmpArr[j] != ""
            puts("Error message here...our description doesn't include expected values:  #{tmpArr[j]}")
      end #if
    end #j

    computer_type = determineComputerType(model)

    hash = {
      :display_size => display_size,
      :display_type => display_type,
      :model => model,
      :cpu => cpu,
      :number_cores => number_cores,
      :core_type => core_type,
      :color => color,
      :computer_type => computer_type
    }
    hash
  end #create_description_hash

  def self.determineComputerType(model)
    tmpStr = model.downcase
    type = nil
    if tmpStr.include?("macbook")
      type = "Laptop"
    elsif tmpStr.include?("imac") || tmpStr.include?("mac ")
      type = "Desktop"
    else
      type = "unknown"
      puts("model = xxx#{tmpStr}xxx, type=#{type}")
      gets.strip
    end
    type
  end

  def self.print_model_from_hashArray(hashArr, model)
    mArr = []
    hashArr.each do |x|
      if x[:model] == model
        mArr << x
      end
    end
    print_hash_array(mArr)
    nil
  end

  def self.print_hash(hash)
      puts("\n\n=====================================")
      hash[:model]           != "" ? puts("Model:         #{hash[:model]}")          : nil
      hash[:display_size]    != "" ? puts("Display Size:  #{hash[:display_size]}")   : nil
      hash[:display_type]    != "" ? puts("Display Type:  #{hash[:display_type]}")   : nil
      hash[:cpu]             != "" ? puts("CPU:           #{hash[:cpu]}")            : nil
      hash[:number_cores]    != "" ? puts("Nbr Cores:     #{hash[:number_cores]}")   : nil
      hash[:core_type]       != "" ? puts("Core Type:     #{hash[:core_type]}")      : nil
      hash[:color]           != "" ? puts("Color:         #{hash[:color]}")          : nil
      hash[:current_price]   != "" ? puts("Current Price: #{hash[:current_price]}")  : nil
      hash[:was_price]       != "" ? puts("Was:           #{hash[:was_price]}")      : nil
      hash[:savings]         != "" ? puts("Savings:       #{hash[:savings]}")        : nil
      hash[:description]     != "" ? puts("Description:   #{hash[:description]}")    : nil
      hash[:link]            != "" ? puts("Link:          #{hash[:link]}")           : nil
    nil
  end

  def self.print_hash_array(hashArr)
      hashArr.each do |x|
        puts("\n\n=====================================")
        x[:model]           != "" ? puts("Model:         #{x[:model]}")          : nil
        x[:display_size]    != "" ? puts("Display Size:  #{x[:display_size]}")   : nil
        x[:display_type]    != "" ? puts("Display Type:  #{x[:display_type]}")   : nil
        x[:cpu]             != "" ? puts("CPU:           #{x[:cpu]}")            : nil
        x[:number_cores]    != "" ? puts("Nbr Cores:     #{x[:number_cores]}")   : nil
        x[:core_type]       != "" ? puts("Core Type:     #{x[:core_type]}")      : nil
        x[:color]           != "" ? puts("Color:         #{x[:color]}")          : nil
        x[:current_price]   != "" ? puts("Current Price: #{x[:current_price]}")  : nil
        x[:was_price]       != "" ? puts("Was:           #{x[:was_price]}")      : nil
        x[:savings]         != "" ? puts("Savings:       #{x[:savings]}")        : nil
        x[:description]     != "" ? puts("Description:   #{x[:description]}")    : nil
        x[:link]            != "" ? puts("Link:          #{x[:link]}")           : nil
      end #for each
      nil
    end
end #class Scraper
