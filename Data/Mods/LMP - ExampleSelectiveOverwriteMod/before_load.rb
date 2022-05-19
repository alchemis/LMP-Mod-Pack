#This script is executed before the mod is loaded, if it exists.
#In this case, we're using it to define a custom ModLoadHandler
#So that the mod does nothing if ExampleMod isn't also loaded


def createModHandler #we put this code inside of a def so that the variables stay local
    mod_name = "LMP - ExampleSelectiveOverwriteMod" #change this to your mod name
    puts "Running before_load for mod #{mod_name}"

    $ModLoadHandlers[mod_name] = ModLoadHandler.new(mod_name)
    load_handler = $ModLoadHandlers[mod_name]

    
    #this is an example of how to make your mod selectively load stuff based on which other mods are present

    #this is the most basic thing we can do, just check if another mod is loaded before loading at all
    #but if you are familiar with how essentials works you can essential-ly do any condition you want
    #to check other common things, you can access:

    # $ModList = [] #format: array of str Mod names sorted by load order
    # $ModSettings = Hash[] # format: str Mod => hash of settings
    # $ModMaps = Hash[] # format: int id => path to something formatted MapXXXXX.rxdata
    # $ListOfModPokemonByParent a hash containing [species ID => Hash[:parent => (string) name of the mod that added it, :id => (int) id, :overwrite => (bool) whether this pokemon overwrote another]
    # do NOT assign anything to these variables in here

    def load_handler.load_mod? 
        return is_loaded_before?("LMP - ExampleMod",@name) 
        #is_loaded_before? checks if a mod is loaded before another mod, in case our mod specifically depends on another mod
        #@name is the name given when creating the ModLoadHandler
        #you probably actually want to raise an error here if a dependency is missing
    end

    #the defs below this point aren't necessary to declare unless you are overwriting them, but this is left here as an example.

    def load_handler.load_move?(move)
        return true
    end

    def load_handler.load_ability?(move)
        return true
    end

    def load_handler.load_species?(species)
        return true
    end

    def load_handler.load_item?(item) 
        return true
    end

    def load_handler.load_encounters?(map_id)
        return true
    end

    def load_handler.load_map?(map_id)
        return true
    end

    def load_handler.load_event?(map_id, event_id) # !not implemented yet as of 2022/5/19!
        return true
    end

end
createModHandler
