module Concerns
    module Findable #class methods
        def find_by_model(model)
            self.all.detect { |x| x.model == model}
        end

        def find_by_specs(model, display_size=nil, number_cores=nil, cpu=nil)
          retObjArr = []
          matchingDisplays = getMachingDisplaySize(display_size)
          matchingModels = getMatchingModels(model)
          matchingCores = getMatchingNbrCores(number_cores)
          matchingCPUs = getMatchingCPUs(cpu)

          #intersection  = & (not &&)
          retObjArr = matchingDisplays & matchingModels & matchingCores & matchingCPUs
        end

        def getMatchingModels(model)
          retObjArr = []
          self.all.each do |x|
            if x.model == model
              retObjArr << x
            end
          end
          retObjArr
        end

        def getMatchingDisplaySize(display_size)
          retObjArr = []
          self.all.each do |x|
            if x.respond_to?("display_size")
               if x.display_size == display_size
                 retObjArr << x
               end
            else #no display - then just include this in the search
              retObjArr << x
            end #if
          end  #each
          retObjArr
        end

        def getMatchingNbrCores(number_cores)
          retObjArr = []
          self.all.each do |x|
            if number_cores == x.number_cores
              retObjArr << x
            end
          end
          retObjArr
        end

        def getMatchingCPUs(cpu)
          retObjArr = []
          self.all.each do |x|
            if cpu == x.cpu
              retObjArr << x
            end
          end
          retObjArr
        end

        def ordered_list_sort
          i = 1;

          sorted = self.all.sort_by { |o| o.model}
          sorted.each { |x| puts("#{i}. #{x.model}"); i+=1}
          nil
        end
      end #module
end #Concerns
