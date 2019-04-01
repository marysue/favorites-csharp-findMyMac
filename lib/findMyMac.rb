require "./config/environment.rb"

module FindMyMac
  class Error < StandardError; end


  class FindMyMac::Finder
    #Array indices for available configurations - used by desktopConfigs, laptopConfigs arrays
    MODELS = 0
    CPUS = 1
    NUMBER_CORES = 2
    CORE_TYPE = 3
    DISPLAY = 4

    attr_accessor :desktopObjs, :laptopObjs, :otherObjs,
                :iMacObjs, :iMacProObjs, :MacBookObjs, :MacBookProObjs,
                :MacBookAirObjs, :MacMiniObjs, :MacProObjs,
                :desktopConfigs, :laptopConfigs

    #====================================================================
    #              Constructor methods
    #====================================================================
    def initialize(mac_attrs_hash=nil)
      initArrays

      if (mac_attrs_hash == nil)
        mac_attrs_hash = Scraper::scrape_refurbished_mac
      end

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
      @laptopConfigs[NUMBER_CORES] << computerHash[:number_cores] unless @laptopConfigs[NUMBER_CORES].include?(computerHash[:number_cores])
      @laptopConfigs[CORE_TYPE] << computerHash[:core_type] unless @laptopConfigs[CORE_TYPE].include?(computerHash[:core_type])
      @laptopConfigs[DISPLAY] << computerHash[:display_size] unless @laptopConfigs[DISPLAY].include?(computerHash[:display_size])
    end

    def addToDesktopConfigs(computerHash)
      @desktopConfigs[MODELS] << computerHash[:model] unless @desktopConfigs[MODELS].include?(computerHash[:model])
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
      @desktopConfigs[NUMBER_CORES] = []
      @desktopConfigs[CORE_TYPE] = []

      @laptopConfigs = []
      @laptopConfigs[MODELS] = []
      @laptopConfigs[NUMBER_CORES] = []
      @laptopConfigs[CORE_TYPE] = []
      @laptopConfigs[DISPLAY] = []

      @desktopObjs = []
      @laptopObjs = []

      @otherObjs = []
    end

    def self.all
      @@all
    end

    #====================================================================
    #  Entry point for selecting laptop or desktop search
    #====================================================================
    def selectConfiguration
      configHash = {}
      selectComputerType == 1 ? configHash = selectDesktopConfiguration : configHash = selectLaptopConfiguration

      puts("")
      puts("\nConfiguration Requested:  \n\tModel:  #{configHash[:model]}\n\tDisplay:  #{configHash[:display]}\n\tCPU: #{configHash[:cpu]}\n\tNumber of Cores: #{configHash[:number_cores]}\n\n")
      configHash
    end
    #==============================================================================
    # selectLaptopConfiguration
    #   Presents the user of possible configurations for the laptopObj
    #  returns configuration hash which matches the user's requirement
    #===========================================================================
    def selectLaptopConfiguration
      configHash = {}

      modelsArr = @laptopConfigs[MODELS].sort_by{ |h| h.downcase }
      index = getSelectionAsIndex(modelsArr, "Which model would you like?  ", true)
      index != nil ? model = modelsArr[index] : model = nil

      displayArr = @laptopConfigs[DISPLAY].sort_by{ |h| h.downcase }
      index = getSelectionAsIndex(displayArr, "Would you like to select a display size? [y/n]:   ", false)
      index != nil ? display_size = displayArr[index] : display_size = nil


      cpuArray = []
      cpuArray = getAvailCPUs(model, display_size)
      cpuArray = cpuArray.sort_by{ |h| h.downcase }
      index = getSelectionAsIndex(cpuArray, "Would you like to select the CPU? [y/n]: ", false)
      index != nil ? cpu = cpuArray[index] : cpu = nil

      coresArr = @laptopConfigs[NUMBER_CORES].sort_by{ |h| h.downcase }
      index = getSelectionAsIndex(coresArr, "Would you like to select the number of cores? [y/n]:   ", false)
      index != nil ? number_cores = coresArr[index] : number_cores = nil

      configHash = {
        :model => model,
        :display => display_size,
        :cpu => cpu,
        :number_cores => number_cores
      }
      configHash
    end
    #==========================================================================
    # getSelectionAsIndex
    #    prompts user for their choice
    #    examines validition of response
    #    returns the selection as an index into the selection array
    #==========================================================================
    def getSelectionAsIndex(arr, prompt, mandatory)
      selection = nil
      puts #put a newline

      #if array size == 1, don't ask for selection
      #and do not include this in configuration request
      if arr.size > 1
        i = 0
        if (presentChoice(prompt, mandatory) == "y")
          #for each element of the sorted Array
          #present them as choices
          arr.each do |x|
            i += 1 #save value for later prompt
            puts("#{i}. #{x}")
          end #each

          #validate the choice
          selection = getValidSelection(arr.size)
          selection -= 1 #set to index value
        end #presentChoice == "y"
      end #if arr.size > 1
      selection  #return input
    end
    #==========================================================================
    # getValidSelection
    #    validates the selection and gets correct user input
    #    returns a valid selection
    #==========================================================================
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

    #==========================================================================
    #presentChoice
    #    Puts up a prompt.  If the choice must be yes, returns yes
    #    otherwise continues to prompt until the user selects a
    #    valid choice.
    #==========================================================================
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
    #====================================================================
    #selectDesktopConfiguration
    #   Presents the available choices for Models, Cpus and Cores
    #   Then returns a configuration hash for the user's choices
    #====================================================================
    def selectDesktopConfiguration
      configHash = {}
      models = @desktopConfigs[MODELS].sort_by{|h| h.downcase}
      index = getSelectionAsIndex(models, "Which model would you like?  ", true)
      index != nil ? model = models[index] : model = nil
      puts("Selection:  #{index}:  #{models[index]}")
      cpuArray = getAvailCPUs(model)
      cpuArray = cpuArray.sort_by{|h| h.downcase}
      index = getSelectionAsIndex(cpuArray, "Would you like to select the CPU?  [y/n]:  ", false)
      index != nil ? cpu = cpuArray[index] : cpu = nil
      for i in 0 .. cpuArray.size - 1 do
        puts("Cpu[#{i}]: #{cpuArray[i]}\n")
      end
      puts("Selection:  #{index}: #{cpuArray[index]}")

      coresArr = @desktopConfigs[NUMBER_CORES].sort_by{ |h| h.downcase}
      index = getSelectionAsIndex(coresArr, "Would you like to select the number of cores? [y/n]:   ", false)
      index != nil ? number_cores = coresArr[index] : number_cores = nil
      if index != nil
        puts("Selection:  #{index}: #{coresArr[index]}")
      end
      configHash = {
        :model => model,
        :cpu => cpu,
        :number_cores => number_cores
      }
      configHash
    end
    #=========================================================================
    # getAvailCPUs
    #    Determines which type of computer this is, then calls getCpuArr
    #    with appropriate object ... this way we only present cpus on the
    #    model that the user is interested in
    #    This didn't work in laptopConfigs or desktopConfigs bc the Cpus
    #    were all over the map
    #==========================================================================
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
    #==========================================================================
    # getCpuArr
    #    looks at each object and places the cpu value into the
    #    cpuArray.  Returns the array [used for the user to choose from]
    #==========================================================================
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
    #====================================================================
    #  selectComputerType
    #   Select desktop or laptop
    #====================================================================
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
    #====================================================================
    #             Entry Point for searching
    # Controller: Gets selection, presents matches, asks for addition
    #             information, presents addl info.
    #====================================================================
    def findMacs
      configHash = selectConfiguration

      #match objects to configuration
      matchedObjsArr = findMatches(configHash.reject{ |k, v| v == nil})
      if (matchedObjsArr.size > 0)
        puts("We have found #{matchedObjsArr.size} computers matching this configuration.\n\n")
      end
      #enter new configurations to narrow results?
      exit = enterNewConfig(matchedObjsArr)
      exit != 'y' && matchedObjsArr.size > 0 ? printMatchedItems(matchedObjsArr) : nil
      matchedObjsArr.size > 0 && exit == "n" ? getAddlInfo(matchedObjsArr) :nil

    end
    #==========================================================================
    #findMatches:
    #  Determines which array of objects to use in our comparison
    #  of the user's configurations
    #  calls findMatchedObjs with appropriate set of objects
    #==========================================================================
    def findMatches(configHash)
      matchedObjsArr = []
      if configHash[:model] == "MacBook"
        matchedObjsArr = findMatchedObjs(configHash, @MacBookObjs)
      elsif configHash[:model] == "MacBook Pro"
        matchedObjsArr = findMatchedObjs(configHash, @MacBookProObjs)
      elsif configHash[:model] == "MacBook Air"
        matchedObjsArr = findMatchedObjs(configHash, @MacBookAirObjs)
      elsif configHash[:model] == "iMac"
        matchedObjsArr = findMatchedObjs(configHash, @iMacObjs)
      elsif configHash[:model] == "iMac Pro"
        matchedObjsArr = findMatchedObjs(configHash, @iMacProObjs)
      elsif configHash[:model] == "Mac Mini"
        matchedObjsArr = findMatchedObjs(configHash, @MacMiniObjs)
      elsif configHash[:model] == "Mac Pro"
        matchedObjsArr = findMatchedObjs(configHash, @MacProObjs)
      end
      matchedObjsArr
    end
    #======================================================================
    # findMatchedObjs
    #   Looks at each object, comparing to users requirements,
    #   returns array of matched objects
    #======================================================================
    def findMatchedObjs(configHash, objs)
      matchedObjs = []

        objs.each do |x|
          if matches(x, configHash)
            matchedObjs << x
          end
        end
        matchedObjs
    end
    #======================================================================
    # matches :
    #    Examines each users requirement with a given object
    #    returns true if there's a match
    #    if any requirement doesn't match, we stop and return false.
    #======================================================================
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
    #==============================================================================
    #hashKeysToStringArr()
    #    Helper function for matches as we need no understand what
    #    we are looking at
    #==============================================================================
    def hashKeysToStringArr(hash)
      propertiesArr = []

      hash.each do |k, v|
        k == :cpu ? propertiesArr << "cpu" : nil
        k == :display ? propertiesArr << "display" : nil
        k == :number_cores ? propertiesArr << "number_cores" : nil
      end
      propertiesArr
    end
    #====================================================================
    # enterNewConfig()
    #   Presents final count of matches. Asks user if they want
    #   to enter a new configuration to limit number of matches
    #====================================================================
    def enterNewConfig(matchedObjsArr)
      #returns input y or n to get additional information
      input = 'n'
      if matchedObjsArr.size == 0
        puts("There are no refurbished computers matching this configuration.")
      elsif matchedObjsArr.size > 10
        puts("\nYou have a large number of matches:  #{matchedObjsArr.size}.")
        input = getYNInput("Would you like to narrow the selections by adding criteria? [y/n] ")
        puts("")
      end
      input
    end
    #====================================================================
    #getAddlInfo
    # Matches have been displayed.
    # Ask user if they want additional information on any computers displayed
    #====================================================================
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
        puts("\nConfiguration requested:  \n")
        puts("================================")
        hash = Scraper::scrape_addl_info(matchedObjsArr[index - 1].link)

        matchedObjsArr[index-1].add_attrs_by_hash(hash)
        matchedObjsArr[index - 1].print
        puts("")

      end
    end
    #====================================================================
    # getYNInput(prompt)
    #  Input helper method
    #  Gets a Y/N answer from a prompt
    #====================================================================
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
    #====================================================================
    #              Output methods
    #====================================================================
    #====================================================================
    #formatHeading
    # Creates a string of precise length and positioning for executables
    # to be presented in the CLI
    #====================================================================
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
    #====================================================================
    #formatMatchedItem
    # Take the matched items, and format them to fit nicely into
    # a predetermined size string - works with formatHeading above
    #====================================================================
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
    #====================================================================
    #formatString
    # Works with formatHeading and formatMatchedItem
    # Sets the string to a specified length
    #====================================================================
    def formatString(inStr, len)
      for i in 1 .. len - inStr.length
        inStr += " "
      end
      inStr
    end
    #====================================================================
    #printMatchedItems
    #  Cycles through all matched items
    #  formats them to fit nicely into a table output in cli
    #  then prints each item
    #====================================================================
    def printMatchedItems(objsArr)
      i = 1
      puts("#{formatHeading(objsArr[0].computer_type)}")
      objsArr.each do |x|
        matchedItem = formatMatchedItem(x, i)
        puts("#{matchedItem}")
        i += 1
      end
    end
    #=====================================================================
    # Troubleshooting methods
    #=====================================================================

    #=====================================================================
    # printObjectArray
    #     prints all the properties of each object passed into this methods
    #=====================================================================
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
  end #ends class Finder
end #ends module
