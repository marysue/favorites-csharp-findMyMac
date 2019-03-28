require "./lib/findMyMac/version"
require "./config/environment.rb"

module FindMyMac
  class Error < StandardError; end
  # Your code goes here...
  class FindMyMac::Finder

    #Array indices for available configurations
    MODELS = 0
    CPUS = 1
    NUMBER_CORES = 2
    CORE_TYPE = 3
    DISPLAY = 4

    attr_accessor :desktopObjs, :laptopObjs, :otherObjs,
                :iMacObjs, :iMacProObjs, :MacBookObjs, :MacBookProObjs,
                :MacBookAirObjs, :MacMiniObjs, :MacProObjs,
                :desktopConfigs, :laptopConfigs

    def initialize
      initArrays

      mac_attrs_hash = Scraper::scrape_refurbished_mac

      mac_attrs_hash.each do |x|
        #create objects for each refurbished item
        if x[:computer_type] == "Laptop"
          addToLaptopConfigs(x)
          @laptopObjs << createLaptopObj(x)
        elsif x[:computer_type] == "Desktop"
          addToDesktopConfigs(x)
          @desktopObjs << createDesktopObj(x)
        else
          @otherObjs << Unknown.new(x)
        end
      end #each
    end #initialize

    def addToLaptopConfigs(computerHash)
      @laptopConfigs[MODELS] << computerHash[:model] unless @laptopConfigs[MODELS].include?(computerHash[:model])
      @laptopConfigs[CPUS] << computerHash[:cpu] unless @laptopConfigs[CPUS].include?(computerHash[:cpu])
      @laptopConfigs[NUMBER_CORES] << computerHash[:number_cores] unless @laptopConfigs[NUMBER_CORES].include?(computerHash[:number_cores])
      @laptopConfigs[CORE_TYPE] << computerHash[:core_type] unless @laptopConfigs[CORE_TYPE].include?(computerHash[:core_type])
      @laptopConfigs[DISPLAY] << computerHash[:display_size] unless @laptopConfigs[DISPLAY].include?(computerHash[:display_size])
    end

    def addToDesktopConfigs(computerHash)
      @desktopConfigs[MODELS] << computerHash[:model] unless @desktopConfigs[MODELS].include?(computerHash[:model])
      @desktopConfigs[CPUS] << computerHash[:cpu] unless @desktopConfigs[CPUS].include?(computerHash[:cpu])
      @desktopConfigs[NUMBER_CORES] << computerHash[:number_cores] unless @desktopConfigs[NUMBER_CORES].include?(computerHash[:number_cores])
      @desktopConfigs[CORE_TYPE] << computerHash[:core_type] unless @desktopConfigs[CORE_TYPE].include?(computerHash[:core_type])
    end

    def createLaptopObj(computerHash)
      laptopObj = Laptop.new(computerHash)
      if computerHash[:model] == "MacBook"
        @MacBookObjs << laptopObj
      elsif computerHash[:model] == "MacBook Pro"
        @MacBookProObjs << laptopObj
      elsif computerHash[:model] == "MacBook Air"
        @MacBookAirObjs << laptopObj
      else
        @otherObjs << laptopObj
      end
      laptopObj
    end

    def createDesktopObj(computerHash)
      desktopObj = Desktop.new(computerHash)
      if computerHash[:model] == "iMac"
        @iMacObjs << desktopObj
      elsif computerHash[:model] == "iMac Pro"
        @iMacProObjs << desktopObj
      elsif computerHash[:model] == "Mac Mini"
        @MacMiniObjs << desktopObj
      elsif computerHash[:model] == "Mac Pro"
        @MacProObjs << desktopObj
      else
        @otherObjs << desktopObj
      end
      desktopObj
    end

    def initArrays
      @iMacObjs = []
      @iMacProObjs = []
      @MacBookObjs = []
      @MacBookProObjs = []
      @MacBookAirObjs = []
      @MacMiniObjs = []
      @MacProObjs = []

      @desktopConfigs = []
      @desktopConfigs[MODELS] = []
      @desktopConfigs[CPUS] = []
      @desktopConfigs[NUMBER_CORES] = []
      @desktopConfigs[CORE_TYPE] = []

      @laptopConfigs = []
      @laptopConfigs[MODELS] = []
      @laptopConfigs[CPUS] = []
      @laptopConfigs[NUMBER_CORES] = []
      @laptopConfigs[CORE_TYPE] = []
      @laptopConfigs[DISPLAY] = []

      @desktopObjs = []
      @laptopObjs = []

      @otherObjs = []
    end

    def selectComputerType
      puts("Available computer types: ")
      puts("1.  Desktop")
      puts("2.  Laptop")
      print("Which computer type would you like? [1,2]:  ")
      input = gets.strip.to_i

      while input != 1 && input != 2
        print("Please select 1 or 2:  ")
        input = gets.strip.to_i
      end
      input
    end

    def findMacs
      configHash = selectConfiguration

      #match objects to configuration
      matchedObjsArr = findTheMacs(configHash.reject{ |k, v| v == nil})
      if (matchedObjsArr.size > 0)
        puts("We have found #{matchedObjsArr.size} computers matching this configuration.")
      end
      #enter new configurations to narrow results?
      exit = enterNewConfig(matchedObjsArr)
      exit != 'y' && matchedObjsArr.size > 0 ? printMatchedItems(matchedObjsArr) : nil
      matchedObjsArr.size > 0 && exit == "n" ? getAddlInfo(matchedObjsArr) :nil

    end

    def enterNewConfig(matchedObjsArr)
      #returns input y or n to get additional information
      input = 'n'
      if matchedObjsArr.size == 0
        puts("There are no refurbished computers matching this configuration.")
      elsif matchedObjsArr.size > 10
        puts("\nYou have a large number of matches:  #{matchedObjsArr.size}.")
        input = getYNInput("Would you like to narrow the selections by adding criteria? [y/n]")
        puts("")
      end
      input
    end

    #the entry point for selecting computer configuration
    def selectConfiguration
      configHash = {}
      selectComputerType == 1 ? configHash = selectDesktopConfiguration : configHash = selectLaptopConfiguration

      puts("\nSelected:  \n\tModel:  #{configHash[:model]}\n\tDisplay:  #{configHash[:display]}\n\tCPU: #{configHash[:cpu]}\n\tNumber of Cores: #{configHash[:number_cores]}\n")
      configHash
    end

    def getAddlInfo(matchedObjsArr)
      index = 0
      puts("")

      moreInfo = getYNInput("Would you like additional information on any item? [y/n] ")
      if moreInfo == 'y'
        print("Please enter which item you would like more information on: 1..#{matchedObjsArr.size}:  ")
        index = gets.strip.to_i
        while (index < 1 || index > matchedObjsArr.size )
          print("Please enter a value between 1..#{matchedObjsArr.size}")
          index = gets.strip.to_i
        end
        puts("\nSelected:  \n")
        puts("================================")
        hash = Scraper::scrape_addl_info(matchedObjsArr[index - 1].link)

        matchedObjsArr[index-1].add_attrs_by_hash(hash)
        matchedObjsArr[index - 1].print
      end
    end

    def getYNInput(prompt)
      input = nil
      print(prompt)
      while input == nil || (input != 'y' && input != 'n')
        input = gets.strip.downcase
        if (input != 'y' && input != 'n')
          print("Please enter y/n: ")
        end
      end
      input
    end

    def formatHeading(computer_type)
    #puts("#  Model        Display        CPU      Cores      Price    ")
    #      1. MacBook Pro  13.3-inch      2.3GHz   Quad-Core  $2,700.25
    #         12           12             8        12         12
    number = " #  "
    model = formatString("Model", 12)
    if computer_type == "Desktop"
      display = formatString("Type", 12)
    else
      display = formatString("Display", 12)
    end
    cpu = formatString("CPU", 8)
    cores = formatString("Cores", 12)
    price = formatString("Price", 12)
    heading = number + model + display + cpu + cores + price
  end

  def formatMatchedItem(itemObj, i)
    number = "#{i}. "
    if i < 10
      number = "#{i}.  "
    else
      number = "#{i}. "
    end

    model = formatString(itemObj.model, 12)

    if (itemObj.computer_type == "Laptop")
      display = formatString(itemObj.display_size, 12)
    else
      display = formatString("Desktop", 12)
    end
    cpu = formatString(itemObj.cpu, 8)
    cores = formatString(itemObj.number_cores, 12)
    price = formatString(itemObj.current_price, 12)
    matchedItem = number + model + display + cpu + cores + price
  end

  def printMatchedItems(objsArr)
  i = 1
    puts("#{formatHeading(objsArr[0].computer_type)}")
    objsArr.each do |x|
      matchedItem = formatMatchedItem(x, i)
      puts("#{matchedItem}")
      i += 1
    end
  end

    def formatString(inStr, len)
      for i in 1 .. len - inStr.length
        inStr += " "
      end
      inStr
    end

    def printTheMacs(objsArr,configHash)
      i = 1
      if objsArr.size == 0
        puts("Sorry, no computer matching this configuration currently in stock.")
      else
        puts("\n\nWe found #{objsArr.size} matching configurations \nbased on the following selection criteria:\n")
        configHash.each do |k, v|
          print(" #{k} : #{v} \n")
        end
        puts

        if objsArr.size > 10
          print("Due to the volume of matching configurations, you may want to\nincrease the number of search parameters.\n Would you like to enter more search parameters? [y/n] ")
          input = gets.strip
          if (input.downcase == "n")
              printMatchedItems(objsArr)
          end #if input == "n"
        elsif objsArr.size >0 && objsArr.size < 10  #if objArr.size > 10
          printMatchedItems(objsArr)
        end  #if objArr.size <= 10
      end #if objArr.size == 0
      nil
    end

    def printObjectArray(objsArr)
      i = 1
      objsArr.each do |x|
        puts("#{i}.")
        puts("=====================================================")
        x.print
        puts("=====================================================")
        puts
        i+=1
      end #each
    end

    def findTheMacs(configHash)
      matchedObjsArr = []
      if configHash[:model] == "MacBook"
        matchedObjsArr = findMatchedObjs(configHash, @MacBookObjs)
      elsif configHash[:model] == "MacBook Pro"
        matchedObjsArr = findMatchedObjs(configHash, @MacBookProObjs)
      elsif configHash[:model] == "MacBook Air"
        matchedObjsArr = findMatchedObjs(configHash, @MacBookAirObjs)
      elsif configHash[:model] = "iMac"
        matchedObjsArr = findMatchedObjs(configHash, @iMacObjs)
      elsif configHash[:model] = "iMac Pro"
        matchedObjsArr = findMatchedObjs(configHash, @iMacProObjs)
      elsif configHash[:model] = "Mac Mini"
        matchedObjsArr = findMatchedObjs(configHash, @MacMiniObjs)
      elsif configHash[:model] = "Mac Pro"
        matchedObjsArr = findMatchedObjs(configHash, @MacProObjs)
      end
      matchedObjsArr
    end

    def findMatchedObjs(configHash, objs)
      matchedObjs = []

        objs.each do |x|
          if matches(x, configHash)
            matchedObjs << x
          end
        end
        matchedObjs
    end

    def hashKeysToStringArr(hash)
      propertiesArr = []

      hash.each do |k, v|
        k == :cpu ? propertiesArr << "cpu" : nil
        k == :display ? propertiesArr << "display" : nil
        k == :number_cores ? propertiesArr << "number_cores" : nil
      end
      propertiesArr
    end

    def matches(obj, hash)
      propertiesArr = hashKeysToStringArr(hash)

      matched = true
      propertiesArr.each do |x|
        if matched #only continue loop if we continue to match properties
          case x
            when "cpu"
              obj.cpu == hash[:cpu] ? matched = true : matched = false
            when  "display"
              obj.display_size == hash[:display] ? matched = true : matched = false
            when "number_cores"
              obj.number_cores == hash[:number_cores] ? matched = true : matched = false
            end #case
          end #if matched
      end #each
      matched
    end

    def selectDesktopConfiguration
      configHash = {}
      index = getSelectionAsIndex(@desktopConfigs[MODELS], "Which model would you like?  ", true)
      index != nil ? model = @desktopConfigs[MODELS][index] : model = nil

      cpuArray = getAvailCPUs(model)
      index = getSelectionAsIndex(cpuArray, "Would you like to select the CPU?  [y/n]:  ", false)
      index != nil ? cpu = cpuArray[index] : cpu = nil

      index = getSelectionAsIndex(@desktopConfigs[NUMBER_CORES], "Would you like to select the number of cores? [y/n]:   ", false)
      index != nil ? number_cores = @desktopConfigs[NUMBER_CORES][index] : number_cores = nil

      configHash = {
        :model => model,
        :cpu => cpu,
        :number_cores => number_cores
      }
      configHash
    end

    def getAvailCPUs(model, display=nil)
      cpuArray = []
      if model == "MacBook"
          cpuArray = getCpuArr(@MacBookObjs, display)
      elsif model=="MacBook Pro"
            cpuArray = getCpuArr(@MacBookProObjs, display)
      elsif model == "MacBook Air"
           cpuArray = getCpuArr(@MacBookAirObjs, display)
      elsif model == "iMac"
        cpuArray = getCpuArr(@iMacObjs, display)
      elsif model == "iMac Pro"
        cpuArray = getCpuArr(@iMacProObjs, display)
      elsif model == "Mac Mini"
          cpuArray = getCpuArr(@MacMiniObjs, display)
      elsif model == "Mac Pro"
        cpuArray = getCpuArr(@MacProObjs, display)
      end
      cpuArray.uniq
    end

    def getCpuArr(objs, display)
      cpuArray = []
      if display != nil
        objs.each do |x|
          x.display_size == display ? cpuArray << x.cpu : nil
        end
      else
        objs.each do |x|
          cpuArray << x.cpu
        end
      end
      cpuArray
    end


    def selectLaptopConfiguration
      configHash = {}

      index = getSelectionAsIndex(@laptopConfigs[MODELS], "Which model would you like?  ", true)
      index != nil ? model = @laptopConfigs[MODELS][index] : model = nil

      index = getSelectionAsIndex(@laptopConfigs[DISPLAY], "Would you like to select a display size? [y/n]:   ", false)
      index != nil ? display_size = @laptopConfigs[DISPLAY][index] : display_size = nil


      cpuArray = []
      cpuArray = getAvailCPUs(model, display_size)
      index = getSelectionAsIndex(cpuArray, "Would you like to select the CPU? [y/n]: ", false)
      index != nil ? cpu = cpuArray[index] : cpu = nil

      index = getSelectionAsIndex(@laptopConfigs[NUMBER_CORES], "Would you like to select the number of cores? [y/n]:   ", false)
      index != nil ? number_cores = @laptopConfigs[NUMBER_CORES][index] : number_cores = nil

      configHash = {
        :model => model,
        :display => display_size,
        :cpu => cpu,
        :number_cores => number_cores
      }
      configHash
    end

    def getSelectionAsIndex(arr, prompt, mandatory)
      selection = nil
      puts #put a newline

      #if array size == 1, don't ask for selection
      #and do not include this in configuration request
      if arr.size > 1
        sortedArr = arr.sort
        i = 0
        if (presentChoice(prompt, mandatory) == "y")
          #for each element of the sorted Array
          #present them as choices
          sortedArr.each do |x|
            i += 1 #save value for later prompt
            puts("#{i}. #{x}")
          end #each

          #validate the choice
          selection = getValidSelection(sortedArr.size)
          selection -= 1 #set to index value
        end #presentChoice == "y"
      end #if arr.size > 1
      selection  #return input
    end

    def getValidSelection(nbrChoices)
      input = 0
      while (input < 1 || input > nbrChoices)
        print("Choose [1 .. #{nbrChoices}]:  ")
        input = gets.strip.to_i
        if (input < 1 || input > nbrChoices)
          print("Invalid input:  #{input}.  Choose values: [1..#{nbrChoices}]:  ")
          input = gets.strip.to_i
        end
      end  #while
      input
    end

    def presentChoice(prompt, mandatory)
      print("#{prompt}")
      mandatory ? input = "y" : input = nil
      mandatory ? puts : nil  #needs an extra newline as no prompt y/n

      while input == nil || (input != "y" && input != "n")
        input = gets.strip.downcase
        if (input != "y" && input != "n")
          puts("Invalid input: #{input}  Expected [y/n]\n ")
          print("#{prompt}")
        end
      end
      input
    end

    def printDesktopObjs()
      @desktopObjs.each do |x|
          x.printObj
      end
    end

    def printLaptopObjs()
      @laptopObjs.each do |x|
        x.printObj
      end
    end

    def self.all
      @@all
    end

    def self.add_attrs_by_hash(mac_attrs_hash)
      #create new Mac instance, then add all attributes we have values for
      mac_attrs_hash.each{|key, value| self.send(("#{key}="), value)}
    end
  end
end
