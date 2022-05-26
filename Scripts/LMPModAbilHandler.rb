

class AbilityEffect

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

class PokeBattle_Pokemon
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



