$ModList = []
$ModSettings = Hash[]
$ListOfModPokemonByParent = Hash[] if !defined?($ListOfModPokemonByParent)


#gets the load order from load_order.ini, the
def getModLoadOrder
	if File.exists?("Data/Mods/load_order.ini")
			File.open("Data/Mods/load_order.ini", "r") { |file_handle|
			  file_handle.each_line { |line|
				line=line.chomp
				next if line[0,1] == "#"
				next if line == ""
				next if line[0,1] == "!"
				$ModList.append(line)
			  }
			}

	else 
		raise _INTL("LMPModloader: Load order not found! Run the Mod Manager first")
	end

end

def is_integer_in_disguise?(str)
	return str.to_i.to_s == str
end

def getModSettings
	$ModList.each { |mod|
		$ModSettings[mod] = Hash[]
		raise _INTL("#{mod}: Mod in load order but #{mod}/mod_settings.ini not found! You may need to rebuild the load order from the Mod Manager if you deleted mods.") if !File.exists?("Data/Mods/#{mod}/mod_settings.ini")
		File.open("Data/Mods/#{mod}/mod_settings.ini", "r") { |file_handle|
		  file_handle.each_line { |line|
			next if line[0,1] == "#"
			line=line.chomp
			next if line == ""
		    line = line.split("=",-1)
			if line[1].include?(",")
				line[1] = line[1].split(",",-1)
			elsif is_integer_in_disguise?(line[1])
				line[1] = line[1].to_i
			end
			$ModSettings[mod][line[0]] = line[1]
			
		  }
		}
	}
	#puts $ModSettings
end


def mustCompileMods?
	if File.exists?("Data/Mods/mustcompile.ini")
		compilefile= File.open("Data/Mods/mustcompile.ini") 
		size = File.size?(compilefile)
		if size
			return false if (size > 0)
			return true
		else
			return true
		end
	else return true
	end
end

def loadMods
	getModLoadOrder
	getModSettings
	puts "Compile?: " + mustCompileMods?.to_s
	pbCompileAllModData(true) if mustCompileMods? 
	puts "Loading mods...."
	puts "load order is: " + $ModList.to_s
	cacheModMoves
	cacheModDex
	cacheModItems
	cacheModMetadata
	MessageTypes.loadMessageFile("Data/Mods/messages.dat")
	#load mod scripts from mod subfolders as defined in their modsettings.ini
	$ModList.each{ | mod |
		Dir["./Data/Mods/#{mod}/*.rb"].each {|file| load File.expand_path(file) } if $ModSettings[mod]["hasScripts"] == "true"
	}
	
	#load non-LMPModloader mods
	Dir["./Data/Mods/*.rb"].each {|file| load File.expand_path(file) }
	
	
	#Not implemented/needed yet:
	# 
	# cacheTrainers
	# cacheFields

	# $cache.RXanimations       = load_data("Data/Animations.rxdata") if !$cache.RXanimations
	# $cache.RXtilesets         = load_data("Data/tilesets.rxdata") if !$cache.RXtilesets
	# $cache.RXevents           = load_data("Data/CommonEvents.rxdata") if !$cache.RXevents
	# $cache.RXsystem           = load_data("Data/System.rxdata") if !$cache.RXsystem
end


def cacheModDex
	pbCompileModPokemonData if !File.exists?("Data/Mods/dexdata.dat")
	$ListOfModPokemonByParent = load_data("Data/Mods/graphicpaths.dat")
	$cache.pkmn_dex           = load_data("Data/Mods/dexdata.dat")
	$cache.pkmn_metrics       = load_data("Data/Mods/metrics.dat")
	$cache.pkmn_moves         = load_data("Data/Mods/attacksRS.dat")
	$cache.pkmn_egg           = load_data("Data/Mods/eggEmerald.dat")
	$cache.pkmn_evo           = load_data("Data/Mods/evolutions.dat")
end

def cacheModMoves
	pbCompileModMoves if !File.exists?("Data/Mods/moves.dat")
	$cache.pkmn_move          = load_data("Data/Mods/moves.dat")
	$cache.tm_data            = load_data("Data/Mods/tm.dat")
	#Not Implemented
	#$cache.move2anim          = load_data("Data/Mods/move2anim.dat")
	
end

def cacheModItems
	pbCompileModItems if !File.exists?("Data/Mods/items.dat")
	$cache.items           = load_data("Data/Mods/items.dat")
end

def cacheTrainers
	if !File.exists?("Data/trainers.dat")
		pbCompileTrainers 
		pbCompileTrainerLists
	end
	$cache.trainers           = load_data("Data/trainers.dat") if !$cache.trainers
	$cache.trainertypes       = load_data("Data/trainertypes.dat") if !$cache.trainertypes
end

def cacheFields
	compileFields if !File.exists?("Data/fields.dat")
	$cache.FEData             = load_data("Data/fields.dat") if !$cache.FEData
	$cache.FENotes            = load_data("Data/fieldnotes.dat") if !$cache.FENotes
end

def cacheMapInfos
	$cache.mapinfos           = load_data("Data/MapInfos.rxdata") if !$cache.mapinfos
end

def cacheModMetadata
	#Comments are not implemented/needed yet
	#$cache.regions            = load_data("Data/regionals.dat") if !$cache.regions
	$cache.encounters         = load_data("Data/Mods/encounters.dat") if !$cache.encounters
	#$cache.metadata           = load_data("Data/metadata.dat") if !$cache.metadata
	#$cache.map_conns          = load_data("Data/connections.dat") if !$cache.map_conns
	#$cache.town_map           = load_data("Data/townmap.dat") if !$cache.town_map
	PBTypes.loadTypeData
	#MessageTypes.loadMessageFile("Data/Messages.dat")
end

