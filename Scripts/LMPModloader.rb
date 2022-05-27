#Load dependencies, we use json for the Modloader settings
#$LOAD_PATH.append(Dir.pwd)
$LOAD_PATH.append("#{$LOAD_PATH[0]}\\Data\\Mods\\lib") 

require 'json'

$ModList = [] #format: array of Mod objects sorted by load order
$ModMaps = Hash[] # format: int id => path to something formatted MapXXXXX.rxdata
$ListOfModPokemonByParent = Hash[] if !defined?($ListOfModPokemonByParent)
$ModloaderSettings = Hash[] # format: section => Hash of str key => value
$ModDebug = false #used to control debug messages and whether to always force a recompile




def is_loaded_before?(mod,mod2) #given the mod names, checks if mod is loaded before mod2, to check whether you're in the right spot in the load order
	return false if $ModList.any?{|a| a.name == mod} || $ModList.any?{|a| a.name == mod2}
	return $ModList.find_index {|item| item.name == mod} < $ModList.find_index {|item| item.name == mod2}
end


def saveModLoaderSettingsJson
	hash = $ModloaderSettings
	json = JSON.pretty_generate(hash)
	File.open("Data/Mods/Modloader/modloader_settings.json","w") do |f|
		f.write(json)
	end
end

#gets the load order from load_order.ini, the
def getModLoadOrder
	index = 0
	$ModloaderSettings["loadOrder"].each{|modName|
		index += 1
		$ModList.append(Mod.new(modName, index))
	}
end

def runModLoadHandlers
	$ModList.each{ |mod|
		load File.expand_path("#{mod.path}/before_load.rb") if safeExists?("#{mod.path}/before_load.rb")
	}
end

def is_integer_in_disguise?(str)
	return str.to_i.to_s == str
end

def getModMaps
	if File.exists?("Data/Mods/Modloader/Maps/ModMaps.dat")
		$ModMaps = load_data("Data/Mods/Modloader/Maps/ModMaps.dat")
	end
end

def readIni(path)
	headerDetector = /\[(.*)\]/
	hash = Hash[] # Header => Hash
	File.open(path, "r") { |file_handle|
          current_header = ""
		  file_handle.each_line { |line|
			next if line[0,1] == "#" 
			line=line.chomp
			next if line == ""
			if line.match(headerDetector)
				current_header = $1
				hash[current_header] = Hash[]
                next
			end
			if line.include?("=")
				line = line.gsub(/\s*=\s*/,"=")
				raise _INTL("#{path}: has a property defined before a header, invalid ini syntax.") if !current_header
		    	line = line.split("=",-1)
			end
			if line[1].include?(",")
				line[1] = line[1].split(",",-1)
			elsif is_integer_in_disguise?(line[1])
				line[1] = line[1].to_i
			end
			hash[current_header][line[0]] = line[1]
			
		  }
	}
	return hash
end

def writeIni(path,hash)
	headerDetector = /\[(.*)\]/
	string = ""
    current_header = ""
	File.open(path, "r") { |file_handle|
		file_handle.each_line{|line|
			if line[0,1] == "#" 
				string += line
				next
			end
			line = line.chomp
			if line.match(headerDetector)
				current_header = $1
				string += line + "\n"
				next
			end
            if line == ""
                string += line + "\n"
				next
            end
			if line.include?("=")
				raise _INTL("#{path}: has a property defined before a header, invalid ini syntax.") if !current_header
				line = line.gsub(/\s*=\s*/,"=")
		    	line = line.split("=",-1)
				#puts hash.inspect
				#puts "current header: #{current_header} current key: #{line[0]} current value: #{line[1]} trying to write: #{hash[current_header][line[0]]}"
				if hash[current_header].keys.include?(line[0].to_s)
                    if hash[current_header][line[0]].class == Array
                        line[1] = hash[current_header][line[0]]
                        line[1] = line[1].join(",") 
                    elsif hash[current_header][line[0]].class == Integer
                        line[1] = hash[current_header][line[0]].to_s
                    else
                        line[1] = hash[current_header][line[0]] 
                    end
                    
				end
				line = line.join("=")
				string += line + "\n"
			end

		}
	}
    File.open(path, "w") { |file_handle|
        file_handle.write(string)
    }
end

def getModSettings
	$ModList.each{|mod|
		raise _INTL("#{mod.name}: Mod in load order but #{mod.path}/mod_settings.ini not found! You may need to rebuild the load order from the Mod Manager if you deleted mods.") if !File.exists?("Data/Mods/#{mod}/mod_settings.ini")
		all_settings = readIni("#{mod.path}/mod_settings.ini")
		mod.settings = all_settings["settings"]
		mod.custom_settings = all_settings["custom_settings"]
	}

	#puts $ModSettings if $ModDebug
end

def getModLoaderSettings
	modloader_settings_path = "Data/Mods/Modloader/modloader_settings.json"
	if File.exists?(modloader_settings_path)
		File.read(modloader_settings_path)
		$ModloaderSettings = JSON.parse(File.read(modloader_settings_path))
		$ModDebug = true if $ModloaderSettings["settings"]["debug"] == "true"
	else
		raise _INTL("Data/Mods/Modloader/modloader_settings.ini not found!!")
	end
end

def mustCompileMods?
	return true if $ModDebug
	return $ModloaderSettings["settings"]["recompile"] == "true"
end

def flush_mod_cache

end


def doneCompiling
	$ModloaderSettings["settings"]["recompile"] = "false"
	saveModLoaderSettingsJson
end

def loadMods
	getModLoaderSettings
	$ModList = load_data("Data/Mods/Modloader/mods.dat") if !mustCompileMods? #just load the cache if we dont have to recompile woo
	
	if mustCompileMods?
		puts "Compiling mods:"
		$ModList = []
		getModLoadOrder
		getModSettings
		runModLoadHandlers
		pbCompileAllModData(true)
	end

	puts "Loading mods:"
	puts "load order is: " + $ModList.map{|mod| mod.name}.to_s
	puts "mod abilities: #{$ModAbilities.inspect}"
	puts $ModList.inspect
	getModMaps
	cacheModMoves
	cacheModDex
	cacheModItems
	cacheModMetadata
	cacheModMapInfos
	MessageTypes.loadMessageFile("Data/Mods/Modloader/messages.dat")
	#load mod scripts from mod subfolders as defined in their modsettings.ini
	$ModList.each{ | mod |
		Dir["./#{mod.path}/*.rb"].each {|file|
			load File.expand_path(file) if !(file.end_with?("before_load.rb"))
			} if mod.settings["hasScripts"] == "true"
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

def $cache.map_load(mapid,ignoreModdedMaps=false)
	self.cachedmaps = [] if !self.cachedmaps
	if $ModMaps.keys.include?(mapid) && !ignoreModdedMaps
		if !self.cachedmaps[mapid]
			puts "loading modded map",mapid
			self.cachedmaps[mapid] = load_data($ModMaps[mapid])
		end
	end
	#puts "ignoring modded maps for this load..." if ignoreModdedMaps && $ModDebug
	if !self.cachedmaps[mapid]
		puts "loading map",mapid
		self.cachedmaps[mapid] = load_data(sprintf("Data/Map%03d.rxdata", mapid))
	end
	return self.cachedmaps[mapid]
end

def $cache.flushmaps
	self.cachedmaps = []
	self.mapinfos = nil
end

def cacheModDex
	pbCompileModPokemonData if !File.exists?("Data/Mods/Modloader/dexdata.dat")
	$cache.pkmn_dex           = load_data("Data/Mods/Modloader/dexdata.dat")
	$cache.pkmn_metrics       = load_data("Data/Mods/Modloader/metrics.dat")
	$cache.pkmn_moves         = load_data("Data/Mods/Modloader/attacksRS.dat")
	$cache.pkmn_egg           = load_data("Data/Mods/Modloader/eggEmerald.dat")
	$cache.pkmn_evo           = load_data("Data/Mods/Modloader/evolutions.dat")
end

def cacheModMoves
	pbCompileModMoves if !File.exists?("Data/Mods/Modloader/moves.dat")
	$cache.pkmn_move          = load_data("Data/Mods/Modloader/moves.dat")
	$cache.tm_data            = load_data("Data/Mods/Modloader/tm.dat")
	#Not Implemented
	#$cache.move2anim          = load_data("Data/Mods/Modloader/move2anim.dat")
	
end

def cacheModItems
	pbCompileModItems if !File.exists?("Data/Mods/Modloader/items.dat")
	$cache.items           = load_data("Data/Mods/Modloader/items.dat")
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

def cacheModMapInfos
	pbCompileMaps if !File.exists?("Data/Mods/Modloader/Maps/MapInfos.rxdata")
	$cache.mapinfos           = load_data("Data/Mods/Modloader/Maps/MapInfos.rxdata")
end

def cacheModMetadata
	#Comments are not implemented/needed yet
	#$cache.regions            = load_data("Data/regionals.dat") if !$cache.regions
	$cache.encounters         = load_data("Data/Mods/Modloader/encounters.dat") if !$cache.encounters
	#$cache.metadata           = load_data("Data/metadata.dat") if !$cache.metadata
	#$cache.map_conns          = load_data("Data/connections.dat") if !$cache.map_conns
	#$cache.town_map           = load_data("Data/townmap.dat") if !$cache.town_map
	PBTypes.loadTypeData
	#MessageTypes.loadMessageFile("Data/Messages.dat")
end

