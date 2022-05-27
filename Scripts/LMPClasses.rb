class Mod 

    attr_accessor :name, :path, :species, :maps, :load_handler, :settings, :load_order_index, :custom_settings, :path_redirects, :abilities

    def initialize(name, load_order_index)
        @name = name
        @path = "Data/Mods/#{name}"
        @species = Hash[] #string internal name => ModSpecies object
        @maps = Hash[] #int map ID => string map path
		@path_redirects = Hash[] #string old path => string new path
        @load_handler = ModLoadHandler.new(name)
        @settings = Hash[] # string setting => string value
        @load_order_index = load_order_index #int
        @custom_settings = Hash[] #string setting => string value
		@abilities = Hash[] #string internalname => AbilityEffects obj
    end

	def to_s
		return @name
	end

end



class ModSpecies #currently not used
	def initialize(name, hash)
	end
end

class ModLoadHandler #used to determine whether to load content from a mod

	#make an instance of the class and overwrite the methods for mod custom load handlers
	#each method must return a boolean when passed a string (or int, for maps and events) containing a specific thing in the mod files, graphics excepted
	#internal names are always used when avaliable
	#this will probably be updated to use symbols when PBS files are refactored into hashes.


	def initialize(name)
		@name = name 
	end

	def load_mod? 
		return true
	end

	def load_move?(move)
		return true
	end

	def load_ability?(ability)
		return true
	end

	def load_species?(species)
		return true
	end

	def load_item?(item) 
		return true
	end

	def load_encounters?(map_id)
		return true
	end

	def load_map?(map_id)
		return true
	end

	def load_event?(map_id, event_id)
		return true
	end
	
end

class AbilityEffect #used to define modded ability effects

	attr_accessor :id, :internalName, :name, :desc

	def initialize(id, internalName)
		@id = id
		@internalName = internalName
	end

	def ==(other)
		return true if other.instance_of?(AbilityEffect) && other.internalName == @internalName
		return false
	end

	def onSwitch(battler, battle, onactive)
		return false
	end

    def endOfTurn(battler,battle)
        return false
    end

    def onDamaged()
        return false
    end
end

class PokeBattle_Pokemon #overwrite to add ability effects
	attr_accessor(:abil_effects)
 
    def is_modded
        return true if $ListOfModPokemonByParent.include?(self.species)
    end

    def get_abil_effects
        if self.is_modded 
                abil_intName = getConstantName(PBAbilities,self.ability)
                if $ModAbilities.include?(abil_intName.to_s)
                    @abil_effects = $ModAbilities[abil_intName.to_s] 
                    return true
                else return false
                end
        end
        return false
    end
end

