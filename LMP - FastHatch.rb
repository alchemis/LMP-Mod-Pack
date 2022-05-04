

class PokemonOptions
  #####MODDED
  attr_accessor :lmp_fasthatch
  
  
  def lmp_fasthatch
    @lmp_fasthatch = 0 if !@lmp_fasthatch
    return @lmp_fasthatch
  end
  #####/MODDED
end

#####MODDED
#Make sure it exists
#$amb_ModAdditionalOptions=[] if !defined?($amb_ModAdditionalOptions)

if defined?($amb_ModAdditionalOptions)
#Record the new option
	$amb_ModAdditionalOptions["lmp_fasthatch"] = EnumOption.new(_INTL("Fast Hatch"),[_INTL("Off"),_INTL("On")],
																	proc { $idk[:settings].lmp_fasthatch },
																	proc {|value|  $idk[:settings].lmp_fasthatch=value },
																	"Skip hatching animation."
																)
else
	$idk[:settings].lmp_fasthatch = 1
end
#####/MODDED

def pbHatch(pokemon)
  fasthatch=defined?($idk[:settings].lmp_fasthatch) ? $idk[:settings].lmp_fasthatch : 0
  if $game_system && $game_system.is_a?(Game_System)
    playingBGM=$game_system.getPlayingBGM
    playingBGMposition = Audio.bgm_pos if playingBGM
    $game_system.bgm_pause
  end
  pbBGMPlay("Evolution")
  speciesname=PBSpecies.getName(pokemon.species)
  pokemon.name=speciesname
  pokemon.trainerID=$Trainer.id
  pokemon.ot=$Trainer.name
  pokemon.happiness=120
  pokemon.timeEggHatched=pbGetTimeNow
  pokemon.obtainMode=1 # hatched from egg
  pokemon.hatchedMap=$game_map.map_id
  $Trainer.seen[pokemon.species]=true
  $Trainer.owned[pokemon.species]=true
  pbSeenForm(pokemon)
  pokemon.pbRecordFirstMoves
  if !fasthatch || fasthatch == 0
	  if !pbHatchAnimation(pokemon)
		Kernel.pbMessage(_INTL("Huh?\1"))
		Kernel.pbMessage(_INTL("...\1"))
		Kernel.pbMessage(_INTL("... .... .....\1"))
		Kernel.pbMessage(_INTL("{1} hatched from the Egg!",speciesname))
		if Kernel.pbConfirmMessage(_INTL("Would you like to nickname the newly hatched {1}?",speciesname))
		  species=PBSpecies.getName(pokemon.species)
		  nickname=pbEnterPokemonName(_INTL("{1}'s nickname?",speciesname),0,12,"",pokemon)
		  pokemon.name=nickname if nickname!=""
		end
	  end
  else
	Kernel.pbMessage(_INTL("{1} hatched from the Egg!",speciesname))
  end
  pbBGMStop()
  $game_system.bgm_resume(playingBGM, playingBGMposition)
end