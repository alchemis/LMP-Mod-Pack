$ModList = [] #format: array of str Mod names sorted by load order
$ModSettings = Hash[] # format: str Mod => hash of settings
$CustomModSettings = Hash[] # format: str Mod => hash of settings
$ModMaps = Hash[] # format: int id => path to something formatted MapXXXXX.rxdata
$ListOfModPokemonByParent = Hash[] if !defined?($ListOfModPokemonByParent)
$ModLoadHandlers = Hash[] #format: str mod_name => ModLoadHandler object
$ModloaderSettings = Hash[] # format: section => Hash of str key => value
$ModDebug = false #used to control debug messages and whether to always force a recompile

def is_loaded_before?(mod,mod2) #checks if mod is loaded before mod2, to check whether you're in the right spot in the load order
	return false if !($ModList.include?(mod)) || !($ModList.include?(mod2))
	return $ModList.find_index(mod) < $ModList.find_index(mod2)
end

class ModLoadHandler #note: mods dont need to have a ModLoadHandler defined if they dont need it, in which case it always default to true

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


#gets the load order from load_order.ini, the
def getModLoadOrder
	list = []
	hash = $ModloaderSettings["loadOrder"]
	hash = hash.sort_by { |key, value| key }
	hash.each{|k,v|
		list.append(v)
	}
	$ModList = list
end

def runModLoadHandlers
	$ModList.each{ | mod |
		load File.expand_path("Data/Mods/#{mod}/before_load.rb") if safeExists?("Data/Mods/#{mod}/before_load.rb")
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
				if hash[current_header].keys.include?(line[0])
                    puts hash[current_header][line[0]].inspect
                    if hash[current_header][line[0]].class == Array
                        puts "array"
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
    File.open(path+"2", "w") { |file_handle|
        file_handle.write(string)
    }
end

def getModSettings
	$ModList.each{|mod|
		raise _INTL("#{mod}: Mod in load order but #{mod}/mod_settings.ini not found! You may need to rebuild the load order from the Mod Manager if you deleted mods.") if !File.exists?("Data/Mods/#{mod}/mod_settings.ini")
		all_settings = readIni("Data/Mods/#{mod}/mod_settings.ini")
		$ModSettings[mod] = all_settings["settings"]
		$CustomModSettings[mod] = all_settings["custom_settings"]
	}

	#puts $ModSettings if $ModDebug
end

def getModLoaderSettings
	modloader_settings_path = "Data/Mods/Modloader/modloader_settings.ini"
	if File.exists?(modloader_settings_path)
		$ModloaderSettings = readIni(modloader_settings_path)
	else
		raise _INTL("Data/Mods/Modloader/modloader_settings.ini not found!!")
	end
end

def mustCompileMods?
	return true if $ModDebug
	return $ModloaderSettings["settings"]["recompile"] == "true"
end




def doneCompiling
	$ModloaderSettings["settings"]["recompile"] == "false"
	writeIni("Data/Mods/Modloader/modloader_settings.ini",hash)
end

def loadMods
	getModLoaderSettings
	getModLoadOrder
	getModSettings
	runModLoadHandlers
	puts "Compile mods?: " + mustCompileMods?.to_s
	pbCompileAllModData(true) if mustCompileMods? 
	puts "Loading mods...."
	puts "load order is: " + $ModList.to_s
	getModMaps
	cacheModMoves
	cacheModDex
	cacheModItems
	cacheModMetadata
	cacheModMapInfos
	MessageTypes.loadMessageFile("Data/Mods/Modloader/messages.dat")
	#load mod scripts from mod subfolders as defined in their modsettings.ini
	$ModList.each{ | mod |
		Dir["./Data/Mods/#{mod}/*.rb"].each {|file|
			load File.expand_path(file) if !(file.end_with?("before_load.rb"))
			} if $ModSettings[mod]["hasScripts"] == "true"
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
	puts "ignoring modded maps for this load..." if ignoreModdedMaps && $ModDebug
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
	$ListOfModPokemonByParent = load_data("Data/Mods/Modloader/graphicpaths.dat")
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

