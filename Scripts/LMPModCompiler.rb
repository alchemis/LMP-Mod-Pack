$ListOfModPokemonByParent = Hash[]
$ModPBSToLoad = Hash[] if !defined?($ModPBSToLoad)
$ModAbilities = Hash[] # internalName => AbilityEffect object

#This file is extremely hacky, it's based on Compiler.rb from Pokemon Reborn scripts, but some things had to be edited very heavily.
#It would be kind of useless to mark down which things are modified as most things are.

#notable diferences from compiler.rb: uses flags from mod_settings.ini to determine how to load PBS files from mods.

#saves an extra file called graphicspaths.dat containing the path to graphic files for modded pokemon. might be very buggy 0_0
#variables that are modified are named from "pbCompileX" to "pbCompileModX", the original compiler should thus not be overwritten with defs from here, which are loaded with LMPModloader


#Done PBS files: moves, pokemon, abilities, tm, items
#TODO: metadata, other pbs that are necessary
#TODO: finish maps done!
#TODO: fix graphics system to be universal and better

## ugly code warning ##


def hasModGraphics?(id)
	return $ListOfModPokemonByParent.has_key?(id)
end

def getAllPokemonMessages(messagetype)
	messages = []
	messages[0] = nil
	for i in 0...pbGetMessageCount(messagetype)
		messages[i] = pbGetMessage(messagetype,i)
	end
	return messages
end

def moduleToHash(input_module)
	ret = Hash[]
	for i in 0...input_module.constants.length
		ret[input_module.constants[i].to_s] = (input_module.constants(false).map &input_module.method(:const_get))[i]
	end
	return ret#.sort_by {|_key, value| value}.to_h
end

def hashtoString(hash)
	str = ""
	for key,value in hash.sort_by {|_key, value| value}.to_h
		str += "#{key}=#{value}\n"
	end
	return str
end

def pbAddModScript(script,sectionname)
	filename = "Data/Mods/" + sectionname + ".rb"
	File.open(filename,"w"){|f| f.write script}
end

def pbCompileShadowMoves
	sections=[]
	if File.exists?("PBS/shadowmoves.txt")
		pbCompilerEachCommentedLine("PBS/shadowmoves.txt"){|line,lineno|
			if line[ /^([^=]+)=(.*)$/ ]
				key=$1
				value=$2
				value=value.split(",")
				species=parseSpecies(key)
				moves=[]
				for i in 0...[4,value.length].min
					moves.push((parseMove(value[i]) rescue nil))
				end
				moves.compact!
				sections[species]=moves if moves.length>0
			end
		}
	end
	save_data(sections,"Data/shadowmoves.dat")
end

# def pbCompileBTTrainers(filename)
	# sections=[]
	# btTrainersRequiredTypes={
		# "Type"=>[0,"e",PBTrainers],
		# "Name"=>[1,"s"],
		# "BeginSpeech"=>[2,"s"],
		# "EndSpeechWin"=>[3,"s"],
		# "EndSpeechLose"=>[4,"s"],
		# "PokemonNos"=>[5,"*u"]
	# }
	# requiredtypes=btTrainersRequiredTypes
	# trainernames=[]
	# beginspeech=[]
	# endspeechwin=[]
	# endspeechlose=[]
	# if safeExists?(filename)
		# File.open(filename,"rb"){|f|
			# FileLineData.file=filename
			# pbEachFileSectionEx(f){|section,name|
					# rsection=[]
					# for key in section.keys
						# FileLineData.setSection(name,key,section[key])
						# schema=requiredtypes[key]
						# next if !schema
						# record=pbGetCsvRecord(section[key],0,schema)
						# rsection[schema[0]]=record
					# end
					# trainernames.push(rsection[1])
					# beginspeech.push(rsection[2])
					# endspeechwin.push(rsection[3])
					# endspeechlose.push(rsection[4])
					# sections.push(rsection)
			# }
		# }
	# end
	# MessageTypes.addMessagesAsHash(MessageTypes::TrainerNames,trainernames)
	# MessageTypes.addMessagesAsHash(MessageTypes::BeginSpeech,beginspeech)
	# MessageTypes.addMessagesAsHash(MessageTypes::EndSpeechWin,endspeechwin)
	# MessageTypes.addMessagesAsHash(MessageTypes::EndSpeechLose,endspeechlose)
	# return sections
# end

def pbCompileTownMap
	nonglobaltypes={
		"Name"=>[0,"s"],
		"Filename"=>[1,"s"],
		"Point"=>[2,"uussUUUU"]
	}
	currentmap=-1
	rgnnames=[]
	placenames=[]
	placedescs=[]
	sections=[]
	pbCompilerEachCommentedLine("PBS/townmap.txt"){|line,lineno|
		if line[/^\s*\[\s*(\d+)\s*\]\s*$/]
			currentmap=$~[1].to_i
			sections[currentmap]=[]
		else
			if currentmap<0
				raise _INTL("Expected a section at the beginning of the file\n{1}",FileLineData.linereport)
			end
			if !line[/^\s*(\w+)\s*=\s*(.*)$/]
				raise _INTL("Bad line syntax (expected syntax like XXX=YYY)\n{1}",FileLineData.linereport)
			end
			settingname=$~[1]
			schema=nonglobaltypes[settingname]
			if schema
				record=pbGetCsvRecord($~[2],lineno,schema)
				if settingname=="Name"
					rgnnames[currentmap]=record
				elsif settingname=="Point"
					placenames.push(record[2])
					placedescs.push(record[3])
					sections[currentmap][schema[0]]=[] if !sections[currentmap][schema[0]]
					sections[currentmap][schema[0]].push(record)
				else	# Filename
					sections[currentmap][schema[0]]=record
				end
			end
		end
	}
	File.open("Data/townmap.dat","wb"){|f|
		Marshal.dump(sections,f)
	}
	MessageTypes.setMessages(
		MessageTypes::RegionNames,rgnnames
	)
	MessageTypes.setMessagesAsHash(
		MessageTypes::PlaceNames,placenames
	)
	MessageTypes.setMessagesAsHash(
		MessageTypes::PlaceDescriptions,placedescs
	)
end

def pbCompileMetadata
	sections=[]
	currentmap=-1
	pbCompilerEachCommentedLine("PBS/metadata.txt") {|line,lineno|
		if line[/^\s*\[\s*(\d+)\s*\]\s*$/]
			sectionname=$~[1]
			if currentmap==0
				if sections[currentmap][MetadataHome]==nil
					raise _INTL("The entry Home is required in metadata.txt section [{1}]",sectionname)
				end
				if sections[currentmap][MetadataPlayerA]==nil
					raise _INTL("The entry PlayerA is required in metadata.txt section [{1}]",sectionname)
				end
			end
			currentmap=sectionname.to_i
			sections[currentmap]=[]
		else
			if currentmap<0
				raise _INTL("Expected a section at the beginning of the file\n{1}",FileLineData.linereport)
			end
			if !line[/^\s*(\w+)\s*=\s*(.*)$/]
				raise _INTL("Bad line syntax (expected syntax like XXX=YYY)\n{1}",FileLineData.linereport)
			end
			matchData=$~
			schema=nil
			FileLineData.setSection(currentmap,matchData[1],matchData[2])
			if currentmap==0
				schema=PokemonMetadata::GlobalTypes[matchData[1]]
			else
				schema=PokemonMetadata::NonGlobalTypes[matchData[1]]
			end
			if schema
				record=pbGetCsvRecord(matchData[2],lineno,schema)
				sections[currentmap][schema[0]]=record
			end
		end
	}
	File.open("Data/metadata.dat","wb"){|f|
		Marshal.dump(sections,f)
	}
end

def pbCompileModItems
	mods = $ModList
	#load vanilla data
	records=$cache.items
	itemnames=getAllPokemonMessages(MessageTypes::Items)
	itemdescs=getAllPokemonMessages(MessageTypes::ItemDescriptions)
	movedata=$cache.pkmn_move
	records[0] = []
	constants=moduleToHash(PBItems)
	maxValue=PBItems.maxValue
	mods.each{ |mod| 
		next if !($ModSettings[mod]["ModPBS"].include?("items"))
		$ModLoadHandlers[mod] = ModLoadHandler.new(mod) if $ModLoadHandlers[mod] == nil
		next if !($ModLoadHandlers[mod].load_mod?)
		overwriting = false
		pbCompilerEachCommentedLine("Data/Mods/#{mod}/PBS/items.txt"){|line,lineno|
			
			linerecord=pbGetCsvRecord(line,lineno,[0,"vnsuusuuUN"])
			next if !($ModLoadHandlers[mod].load_item?(linerecord[1]))
			record=[]
			if constants.keys.include?(linerecord[1])
				overwriting = true
				record[ITEMID] = constants[linerecord[1]] 
				record[0] = constants[linerecord[1]] 
			else
				overwrite = false
				record[ITEMID] = maxValue + 1
				constants[linerecord[1]] = maxValue + 1
				record[0] = maxValue + 1
			end
			puts "#{mod}: Added Item with id #{linerecord[0]} and internalname #{linerecord[1]} Overwrite? " + overwriting.to_s if $ModDebug
			record[ITEMNAME] = linerecord[2]
			itemnames[record[0]]=linerecord[2]
			record[ITEMPOCKET] = linerecord[3]
			record[ITEMPRICE] = linerecord[4]
			record[ITEMDESC] = linerecord[5]
			itemdescs[record[0]]=linerecord[5]
			record[ITEMUSE] = linerecord[6]
			record[ITEMBATTLEUSE] = linerecord[7]
			record[ITEMTYPE] = linerecord[8]
			if linerecord[9]!="" && linerecord[9]
				record[ITEMMACHINE] = parseMove(linerecord[9])
			else
				record[ITEMMACHINE] = 0
			end
			maxValue=[maxValue,record[0]].max
			records[record[ITEMID]] = record
		}
	}
	File.open("Data/Mods/Modloader/items.dat","wb"){|file|
		Marshal.dump(records,file)
	}
	$cache.items = records
	MessageTypes.setMessages(MessageTypes::Items,itemnames)
	MessageTypes.setMessages(MessageTypes::ItemDescriptions,itemdescs)
	#writeSerialRecords("Data/items.dat",records)
	code="class PBItems\n"
	code+=hashtoString(constants)
	code+="\ndef PBItems.getName(id)\nreturn pbGetMessage(MessageTypes::Items,id)\nend\n"
	code+="\ndef PBItems.getCount\nreturn #{records.length}\nend\n"
	code+="\ndef PBItems.maxValue\nreturn #{maxValue}\nend\nend"
	eval(code)
	pbAddModScript(code,"PBItems")
	Graphics.update
end

def pbCompileConnections
	records=[]
	constants=""
	itemnames=[]
	pbCompilerEachPreppedLine("PBS/connections.txt"){|line,lineno|
		hashenum={
				"N"=>"N","North"=>"N",
				"E"=>"E","East"=>"E",
				"S"=>"S","South"=>"S",
				"W"=>"W","West"=>"W"
		}
		record=[]
		thisline=line.dup
		record.push(csvInt!(thisline,lineno))
		record.push(csvEnumFieldOrInt!(thisline,hashenum,"",sprintf("(line %d)",lineno)))
		record.push(csvInt!(thisline,lineno))
		record.push(csvInt!(thisline,lineno))
		record.push(csvEnumFieldOrInt!(thisline,hashenum,"",sprintf("(line %d)",lineno)))
		record.push(csvInt!(thisline,lineno))
		if !pbRgssExists?(sprintf("Data/Map%03d.rxdata",record[0])) &&
				!pbRgssExists?(sprintf("Data/Map%03d.rvdata",record[0]))
			print _INTL("Warning: Map {1}, as mentioned in the map\nconnection data, was not found.\n{2}",record[0],FileLineData.linereport)
		end
		if !pbRgssExists?(sprintf("Data/Map%03d.rxdata",record[3])) &&
				!pbRgssExists?(sprintf("Data/Map%03d.rvdata",record[3]))
			print _INTL("Warning: Map {1}, as mentioned in the map\nconnection data, was not found.\n{2}",record[3],FileLineData.linereport)
		end
		case record[1]
			when "N"
				raise _INTL("North side of first map must connect with south side of second map\n{1}",FileLineData.linereport) if record[4]!="S"
			when "S"
				raise _INTL("South side of first map must connect with north side of second map\n{1}",FileLineData.linereport) if record[4]!="N"
			when "E"
				raise _INTL("East side of first map must connect with west side of second map\n{1}",FileLineData.linereport) if record[4]!="W"
			when "W"
				raise _INTL("West side of first map must connect with east side of second map\n{1}",FileLineData.linereport) if record[4]!="E"
		end
		records.push(record)
	}
	save_data(records,"Data/connections.dat")
	Graphics.update
end


def pbCompileModEncounters
	mods = $ModList
	encounters=$cache.encounters 
	mods.each{ |mod| 
		next if !($ModSettings[mod]["ModPBS"].include?("encounters"))
		$ModLoadHandlers[mod] = ModLoadHandler.new(mod) if $ModLoadHandlers[mod] == nil
		next if !($ModLoadHandlers[mod].load_mod?)
		lines=[]
		linenos=[]
		FileLineData.file="Data/Mods/#{mod}/PBS/encounters.txt"
		File.open("Data/Mods/#{mod}/PBS/encounters.txt","rb"){|f|
		lineno=1
		f.each_line {|line|
			if lineno==1 && line[0]==0xEF && line[1]==0xBB && line[2]==0xBF
				line=line[3,line.length-3]
			end
			line=prepline(line)
			if line.length!=0
				lines[lines.length]=line
				linenos[linenos.length]=lineno
			end
			lineno+=1
		}
		}

		thisenc=nil
		lastenc=-1
		lastenclen=0
		needdensity=false
		lastmapid=-1
		i=0;
		while i<lines.length
			line=lines[i]
			FileLineData.setLine(line,linenos[i])
			mapid=line[/^\d+$/]
			if mapid
				next if !($ModLoadHandlers[mod].load_encounters?(mapid))
				lastmapid=mapid
				if thisenc && (thisenc[1][EncounterTypes::Land] ||
							thisenc[1][EncounterTypes::LandMorning] ||
							thisenc[1][EncounterTypes::LandDay] ||
							thisenc[1][EncounterTypes::BugContest] ||
							thisenc[1][EncounterTypes::LandNight]) &&
							thisenc[1][EncounterTypes::Cave]
				raise _INTL("Can't define both Land and Cave encounters in the same area (map ID {1})",mapid)
				end
				thisenc=[EncounterTypes::EnctypeDensities.clone,[]]
				encounters[mapid.to_i]=thisenc
				needdensity=true
				i+=1
				next
			end
			enc=findIndex(EncounterTypes::Names){|val| val==line}
			if enc>=0
				needdensity=false
				enclines=EncounterTypes::EnctypeChances[enc].length
				encarray=[]
				j=i+1; k=0
				while j<lines.length && k<enclines
					line=lines[j]
					FileLineData.setLine(lines[j],linenos[j])
					splitarr=strsplit(line,/\s*,\s*/)
					if !splitarr || splitarr.length<2
						raise _INTL("In encounters.txt, expected a species entry line,\ngot \"{1}\" instead (probably too few entries in an encounter type).\nPlease check the format of the section numbered {2},\nwhich is just before this line.\n{3}",
						line,lastmapid,FileLineData.linereport)
					end
					splitarr[2]=splitarr[1] if splitarr.length==2
					splitarr[1]=splitarr[1].to_i
					splitarr[2]=splitarr[2].to_i
					maxlevel=PBExperience::MAXLEVEL
					if splitarr[1]<=0 || splitarr[1]>maxlevel
						raise _INTL("Level number is not valid: {1}\n{2}",splitarr[1],FileLineData.linereport)
					end
					if splitarr[2]<=0 || splitarr[2]>maxlevel
						raise _INTL("Level number is not valid: {1}\n{2}",splitarr[2],FileLineData.linereport)
					end
					if splitarr[1]>splitarr[2]
						raise _INTL("Minimum level is greater than maximum level: {1}\n{2}",line,FileLineData.linereport)
					end
					splitarr[0]=parseSpecies(splitarr[0])
					linearr=splitarr
					encarray.push(linearr)
					thisenc[1][enc]=encarray
					j+=1
					k+=1
				end
			if j==lines.length && k<enclines
				raise _INTL("Reached end of file unexpectedly. There were too few entries in the last section, expected {1} entries.\nPlease check the format of the section numbered {2}.\n{3}",
					enclines,lastmapid,FileLineData.linereport)
				end
				i=j
			elsif needdensity
				needdensity=false
				nums=strsplit(line,/,/)
				if nums && nums.length>=3
					for j in 0...EncounterTypes::EnctypeChances.length
						next if !EncounterTypes::EnctypeChances[j] ||
								EncounterTypes::EnctypeChances[j].length==0
						next if EncounterTypes::EnctypeCompileDens[j]==0
						thisenc[0][j]=nums[EncounterTypes::EnctypeCompileDens[j]-1].to_i
					end
				else
					raise _INTL("Wrong syntax for densities in encounters.txt; got \"{1}\"\n{2}",line,FileLineData.linereport)
				end
			i+=1
			else
				raise _INTL("Undefined encounter type {1}, expected one of the following:\n{2}\n{3}",
				line,EncounterTypes::Names.inspect,FileLineData.linereport)
			end
		end
	}
	$cache.encounters = encounters
	save_data(encounters,"Data/Mods/Modloader/encounters.dat")
end

def pbCompileModMoves
	mods = $ModList
	records=moduleToHash(PBMoves)
	movenames=getAllPokemonMessages(MessageTypes::Moves)
	movedescs=getAllPokemonMessages(MessageTypes::MoveDescriptions)
	movedata=$cache.pkmn_move
	movedata[0] = [0,0,0,0,0,0,0,0,0,0]
	
	maxValue=PBMoves.maxValue
	mods.each{ |mod| 
		next if !($ModSettings[mod]["ModPBS"].include?("moves"))
		$ModLoadHandlers[mod] = ModLoadHandler.new(mod) if $ModLoadHandlers[mod] == nil
		next if !($ModLoadHandlers[mod].load_mod?)
		pbCompilerEachPreppedLine("Data/Mods/"+mod+"/PBS/moves.txt"){|line,lineno|
			thisline=line.clone
			record=[]
			overwriting = true
			flags=0
			record=pbGetCsvRecord(line,lineno,[0,"vnsxueeuuuxiss",
			nil,nil,nil,nil,nil,PBTypes,["Physical","Special","Status"],
			nil,nil,nil,nil,nil,nil,nil])
			#pbCheckWord(record[3],_INTL("Function code"))
			
			#Check if there is already a move with the same internal name, if so, set the ID to the same as that move, else, set the ID to that of the last move in the list plus 1
			next if !($ModLoadHandlers[mod].load_move?(record[1]))
			if	!(records.keys.include?(record[1]))
				record[0] = maxValue+1
				overwriting = false
			else
				record[0] = records[record[1]]
			end
			
			flags|=1 if record[12][/a/]
			flags|=2 if record[12][/b/]
			flags|=4 if record[12][/c/]
			flags|=8 if record[12][/d/]
			flags|=16 if record[12][/e/]
			flags|=32 if record[12][/f/]
			flags|=64 if record[12][/g/]
			flags|=128 if record[12][/h/]
			flags|=256 if record[12][/i/]
			flags|=512 if record[12][/j/]
			flags|=1024 if record[12][/k/]
			flags|=2048 if record[12][/l/]
			flags|=4096 if record[12][/m/]
			flags|=8192 if record[12][/n/]
			flags|=16384 if record[12][/o/]
			flags|=32768 if record[12][/p/]
			if record[6]==2 && record[4]!=0
			raise _INTL("Status moves must have a base damage of 0, use either Physical or Special\n{1}",FileLineData.linereport)
			end
			if record[6]!=2 && record[4]==0
			print _INTL(
				"Warning: Physical and special moves can't have a base damage of 0, changing to a Status move\n{1}",FileLineData.linereport)
			record[6]=2
			end
			movedata[record[0]]=[																						#movedata[fuckinpieceofshit][3]
			record[3],	# Function code
			record[4],	# Damage
			record[5],	# Type
			record[6],	# Category
			record[7],	# Accuracy
			record[8],	# Total PP
			record[9],	# Effect chance
			record[10], # Target
			record[11], # Priority
			flags,			# Flags
			]
			movenames[record[0]]=record[2]	# Name
			movedescs[record[0]]=record[13] # Description

		maxValue=[maxValue,record[0]].max

			if overwriting
			records.delete(records.key(records[0]))
			records[record[1]] = record[0]
			else
			records[record[1]] = record[0]
			end
			puts "#{mod}: Added Move with id #{record[0]} and internalname #{record[1]} Overwrite? " + overwriting.to_s if $ModDebug
		}
	}
	File.open("Data/Mods/Modloader/moves.dat","wb"){|file|
		Marshal.dump(movedata,file)
	}
	$cache.pkmn_move = movedata
	MessageTypes.setMessages(MessageTypes::Moves,movenames)
	MessageTypes.setMessages(MessageTypes::MoveDescriptions,movedescs)
	code="class PBMoves\n"
	code+=hashtoString(records)
	code+="\ndef self.getName(id)\nreturn pbGetMessage(MessageTypes::Moves,id) if id < 10000 \nreturn PokeBattle_ZMoves::ZMOVENAMES[id-10001]\nend"
	code+="\ndef self.getCount\nreturn #{records.length}\nend"
	code+="\ndef self.maxValue\nreturn #{maxValue}\nend\nend"
	eval(code)
	pbAddModScript(code,"PBMoves")
end

def pbCompileModAbilities()
	mods = $ModList
	records=moduleToHash(PBAbilities)
	movenames=getAllPokemonMessages(MessageTypes::Abilities)
	movedescs=getAllPokemonMessages(MessageTypes::AbilityDescs)
	maxValue=PBAbilities.maxValue
	mods.each{ |mod| 
		next if !($ModSettings[mod]["ModPBS"].include?("abilities"))
		$ModLoadHandlers[mod] = ModLoadHandler.new(mod) if $ModLoadHandlers[mod] == nil
		next if !($ModLoadHandlers[mod].load_mod?)
		path = mod + "/PBS/abilities.txt"

		
		pbCompilerEachPreppedLine("Data/Mods/"+path){|line,lineno|
			record=pbGetCsvRecord(line,lineno,[0,"vnss"])
			next if !($ModLoadHandlers[mod].load_ability?(record[1]))
			if	!(records.values.include?(record[1]))
				record[0] = maxValue+1
				overwriting = false
			else
				record[0] = records[record[1]]
				overwriting = true
			end
			movenames[record[0]]=record[2]
			movedescs[record[0]]=record[3]
			maxValue=[maxValue,record[0]].max
			
			records.delete(records.key(records[0]))
			records[record[1]] = record[0]
			if !overwriting #create an AbilityEffect object if the ability is being added
				$ModAbilities[record[1]] = AbilityEffect.new(record[0],record[1])
			end
			puts "#{mod}: Added Ability with id " + record[0].to_s + " Overwrite? " + overwriting.to_s if $ModDebug
		}
	}
	MessageTypes.setMessages(MessageTypes::Abilities,movenames)
	MessageTypes.setMessages(MessageTypes::AbilityDescs,movedescs)
	code="class PBAbilities\n"
	code+=hashtoString(records)
	code+="\ndef self.getName(id)\nreturn pbGetMessage(MessageTypes::Abilities,id)\nend"
	code+="\ndef self.getCount\nreturn #{records.length}\nend\n"
	code+="\ndef self.maxValue\nreturn #{maxValue}\nend\nend"
	eval(code)
	pbAddModScript(code,"PBAbilities")
end

def dump_and_get_hash(object)
		#useful to compare two objects that are different instances of the same class
		# dump_and_get_hash(object) == dump_and_get_hash(object.clone).hash # true, whereas normally it would return false unless those objects have ==() defined
		# ! slow for small objects !
		return Marshal.dump(object).hash
end



def checkMapSizes(map1,map2)
		return false if map1::data::xsize != map2::data::xsize 
		return false if map1::data::zsize != map2::data::zsize 
		return false if map1::data::ysize != map2::data::ysize 
		return true
end

def mergeMapTiles(modded_map,destination_map)
	#replaces tiles in map 2 with tiles in map 1 (if they are different)
	return false if !checkMapSizes(modded_map,destination_map)
	(0..modded_map.data.xsize-1).each{ |x|
		(0..modded_map.data.ysize-1).each{ |y|
			(0..modded_map.data.zsize-1).each{ |z|
				tile = modded_map.data[x,y,z]
				tile2 = destination_map.data[x,y,z]
				if tile != tile2
					#puts "Replaced tile at #{[x,y,z]}" if $ModDebug
					destination_map.data[x,y,z] = tile
				end
			}
		}
	}
end

def mergeMapTiles_ignore_vanilla_tiles(modded_map,destination_map,vanilla_map)
		#replaces tiles in destination_map with tiles in modded_map, if those tiles are NOT in vanilla_map
		return false if !checkMapSizes(modded_map,destination_map)
		(0..modded_map.data.xsize-1).each{ |x|
			(0..modded_map.data.ysize-1).each{ |y|
					(0..modded_map.data.zsize-1).each{ |z|
				tile = modded_map.data[x,y,z]
				if (tile != destination_map.data[x,y,z] && tile != vanilla_map.data[x,y,z])
					puts "Replaced tile at #{[x,y,z]} with #{tile} because it wasnt equal to vanilla_data (#{vanilla_map.data[x,y,z]}) or the previously modded map (#{destination_map.data[x,y,z]})" if $ModDebug
					destination_map.data[x,y,z] = tile
				end
				}
 		}
 	}
end

def mergeMapEvents(map1,map2)
		#replaces events in map 2 with events in map 1 (if they are different)
		merge_list = map2.events
		return false if !checkMapSizes(map1,map2)
		map1.events.each { |event|
				#puts map2.events[event[0]] if $ModDebug

				if map2.events[event[0]] == nil
						#found an event in the modded map whose id doesn't exist in the original map
						merge_list[event[0]] = event[1]
				elsif dump_and_get_hash(event[1]) != dump_and_get_hash(map2.events[event[0]])
						#found two events that are different but share the same id
						#check if they are also in the same position
						puts "Found 2 events with id #{event[0]}" if $ModDebug
						if (event[1].x == map2.events[event[0]].x && event[1].y == map2.events[event[0]].y)
								#if they are, overwrite
								#puts "They also have the same position, overwriting at pos #{event[1].x},#{event[1].y}" if $ModDebug
								merge_list[event[0]] = event[1]
						else
								#if they aren't, assign the event a new id and add it
								new_id = map2.events.keys.max + 1
								puts "they dont share the same position, assigning a new id	#{new_id}" if $ModDebug
								event[1].id == new_id
								merge_list[new_id] = event[1]
						end
				end
		}
		map1.events.merge(merge_list)
		map1.events = map1.events.sort.to_h #doesnt work because events is array of subarrays, fix pls
end

def load_map_rxdata(data_file)
		data = nil
		File.open( data_file, "r+" ) do |input_file|
			data = Marshal.load( input_file)
		end
	
		return data
end

def save_map_rxdata(data_file, data)
		File.open( data_file, "w+" ) do |output_file|
			Marshal.dump( data, output_file )
		end
	end

def compileModMaps

	mapinfos = $cache.mapinfos
	mods = $ModList

	mods.each{ |mod| 
		next if $ModSettings[mod]["Maps"] == nil
		$ModLoadHandlers[mod] = ModLoadHandler.new(mod) if $ModLoadHandlers[mod] == nil
		next if !($ModLoadHandlers[mod].load_mod?)
		maps_to_load = $ModSettings[mod]["Maps"] if $ModSettings[mod]["Maps"].class == Array
		maps_to_load = [$ModSettings[mod]["Maps"]] if $ModSettings[mod]["Maps"].class == String
		loaded_maps = []

		prefix_for_mod_maps = mods.find_index(mod) + 1 #we use this to avoid id conflicts if several mods add new maps
		maps_to_fix_references = Hash[]

		if File.exists?("Data/Mods/#{mod}/Maps/MapInfos.rxdata")
			mod_mapinfos = load_map_rxdata("Data/Mods/#{mod}/Maps/MapInfos.rxdata")
		else 
			raise _INTL("{1}: has maps but MapInfos.rxdata not found!",mod)
			next
		end

		maps_to_load.each{|mapfilename|
			
			map_id = mapfilename
			map_id = map_id.delete("^0-9").to_i
			puts "\n"
			puts "#{mod}: processing map #{map_id}" if $ModDebug
			next if !($ModLoadHandlers[mod].load_map?(map_id))
			map_path = "Data/Mods/#{mod}/Maps/#{mapfilename}.rxdata"
			if File.exists?(map_path)
				map = load_map_rxdata(map_path)
			else 
				raise _INTL("{1}: Map {2} is defined in mod_settings.txt but the rxdata file is missing!",mod,map_id)
				next
			end
			$cache.cacheMapInfos

			new_map = false
			new_mapinfos = $cache.mapinfos
			#determine if we're adding a new map or overwriting

			if $ModMaps.keys.include?(map_id)
				puts "map is a mod-overwrite" if $ModDebug
				#map is already modded, merge, but ignore tiles that are from the vanilla map
				#this is done this way so that if you add tiles, and another mod's version of that map doesn't have those tiles, 
				#but doesn't have any tiles that would conflict with it
				#you dont get your tiles erased

				vanilla_map = load_map_rxdata("Data/#{mapfilename}.rxdata")

				cached_mapinfos = load_map_rxdata("Data/Mods/Modloader/Maps/MapInfos.rxdata")
				mod_mapinfo = mod_mapinfos[map_id]

				
				cached_map = load_map_rxdata(sprintf("Data/Mods/Modloader/Maps/Map%05d.rxdata", map_id))
				
				new_mapinfos[map_id] = mod_mapinfo
				
				mergeMapTiles_ignore_vanilla_tiles(map,cached_map,vanilla_map)
				mergeMapEvents(map,cached_map)

				map_to_save = cached_map

			elsif $cache.mapinfos.keys.include?(map_id)
				#it's a map already in the game, but not a mod map.
				#puts "map #{map_id} is an overwrite map" if $ModDebug
				
				cached_mapinfo = $cache.mapinfos[map_id]
				cached_map = $cache.map_load(map_id,true)
				mod_mapinfo = mod_mapinfos[map_id]
				new_mapinfos[map_id] = mod_mapinfo

				if cached_mapinfo.name != mod_mapinfo.name
					#if they have different names, assume this is a new map that got shuffled around and assign a new id to it
					new_map = true
				else
					#same id and name as a map already in the game that is NOT a mod map, we can safely merge and call it a day
					mergeMapTiles(map,cached_map)
					mergeMapEvents(map,cached_map)
					map_to_save = cached_map
				end

				#$ModMaps[map_id] = map_path
			else
				new_map = true
			end

			if new_map
				#puts "map #{map_id} is a new map" if $ModDebug
				old_id = map_id
				new_id = (prefix_for_mod_maps.to_s + sprintf("%03d", map_id)).to_i
				new_id = sprintf("%05d", new_id).to_i
				map_id = new_id
				#puts "setting id to #{new_id}" if $ModDebug
				maps_to_fix_references[old_id] = new_id
				mod_mapinfo = mod_mapinfos[map_id]
				new_mapinfos[map_id] = mod_mapinfo
				map_to_save = map
				
			end


			#remember to update the cache here pls

			new_map_path = sprintf("Data/Mods/Modloader/Maps/Map%05d.rxdata", map_id)
			$ModMaps[map_id] = new_map_path
			$cache.mapinfos = new_mapinfos
			$cache.cachedmaps[map_id] = map_to_save
			save_map_rxdata(new_map_path,map_to_save)
			save_map_rxdata("Data/Mods/Modloader/Maps/MapInfos.rxdata",new_mapinfos)
			loaded_maps.append(new_map_path)
		}

		#we're gonna have to load every map again to fix transfer events.. we'd have to do this for each kind of reference we find that is broken so i hope there aren't too many
		maps_to_fix_references.each{ |old_id, new_id|
			loaded_maps.each{|map_path|
				puts "fixing references to map #{old_id} (now map #{new_id}): currently checking map #{map_path}" if $ModDebug
				map = load_map_rxdata(map_path)
				map.events.each{|id,event|
					event.pages.each{|page|
						page.list.each{|command|
							if command.code == 201
								if command.parameters[1] == old_id
									command.parameters[1] = new_id 
									puts "replaced a reference in map #{map_path}, #{old_id} => #{new_id}" if $ModDebug
								end
								#puts "found a reference in map #{map_path}, it points to map #{command.parameters[1]}" if $ModDebug
							end
						}
					}
				}
				save_map_rxdata(map_path,map)
				$cache.cachedmaps[new_id]
			}
		}

	}
	#after loading all the mods, save a list of each mod and it's path
	save_map_rxdata("Data/Mods/Modloader/Maps/ModMaps.dat",$ModMaps)
	#flush the map cache to prevent accessing a vanilla map accidentally
	$cache.cachedmaps = []
end

def pbCompileModMachines
	#depends on moves
	lineno=1
	havesection=false
	sectionname=nil
	sections=$cache.tm_data
	mods = $ModList
	mods.each{ |mod| 
		next if !($ModSettings[mod]["ModPBS"].include?("tm"))
		force_overwrite = true if $ModSettings[mod]["forceOverwriteAbilities"] == "true"
		path = "Data/Mods/#{mod}/PBS/tm.txt"
		$ModLoadHandlers[mod] = ModLoadHandler.new(mod) if $ModLoadHandlers[mod] == nil
		next if !($ModLoadHandlers[mod].load_mod?)
		if safeExists?(path)
		f=File.open(path,"rb")
		FileLineData.file=path
		f.each_line {|line|
			if lineno==1 && line[0]==0xEF && line[1]==0xBB && line[2]==0xBF
				line=line[3,line.length-3]
			end
			removing = false
			FileLineData.setLine(line,lineno)
			if !line[/^\#/] && !line[/^\s*$/]
				if line[/^\s*\[\s*(.*)\s*\]\s*$/]
					next if !($ModLoadHandlers[mod].load_move?($~[1])) #maybe? test it out later, pretty sure this should be the an internal id
					sectionname=parseMove($~[1])
					puts " processing tms for move #{sectionname}" if $ModDebug
					
					sections[sectionname] = [] if (sections[sectionname].nil?)
					havesection=true
				else
					if sectionname==nil
						next
					end
					specieslist=line.sub(/\s+$/,"").split(",")
					for species in specieslist
						next if !species || species==""
						next if !($ModLoadHandlers[mod].load_species?(species))
						if species[0,1] == "!"
							removing = true
							species.slice!(0)
						end
						sec=sections[sectionname]
						if removing == false
							if sec.include?(parseSpecies(species))
								next
							else
								sec[sec.length]=parseSpecies(species)
							end
						else
							sec.delete(parseSpecies(species)) if sec.include?(parseSpecies(species))
						end
					end
				end
			end
			lineno+=1
			if lineno%500==0
				Graphics.update
			end
			if lineno%50==0
				pbSetWindowText(_INTL("Processing line {1}",lineno))
			end
		}
		f.close
		end
	}
	save_data(sections,"Data/Mods/Modloader/tm.dat")
end


# def pbCompileTrainerLists
	# btTrainersRequiredTypes={
		# "Trainers"=>[0,"s"],
		# "Pokemon"=>[1,"s"],
		# "Challenges"=>[2,"*s"]
	# }
	# if !safeExists?("PBS/trainerlists.txt")
		# File.open("PBS/trainerlists.txt","wb"){|f|
			# f.write("[DefaultTrainerList]\nTrainers=bttrainers.txt\nPokemon=btpokemon.txt\n")
		# }
	# end
	# database=[]
	# sections=[]
	# MessageTypes.setMessagesAsHash(MessageTypes::BeginSpeech,[])
	# MessageTypes.setMessagesAsHash(MessageTypes::EndSpeechWin,[])
	# MessageTypes.setMessagesAsHash(MessageTypes::EndSpeechLose,[])
	# File.open("PBS/trainerlists.txt","rb"){|f|
		# pbEachFileSectionEx(f){|section,name|
				# next if name!="DefaultTrainerList" && name!="TrainerList"
				# rsection=[]
				# for key in section.keys
					# FileLineData.setSection(name,key,section[key])
					# schema=btTrainersRequiredTypes[key]
					# next if key=="Challenges" && name=="DefaultTrainerList"
					# next if !schema
					# record=pbGetCsvRecord(section[key],0,schema)
					# rsection[schema[0]]=record
				# end
				# if !rsection[0]
					# raise _INTL("No trainer data file given in section {1}\n{2}",name,FileLineData.linereport)
				# end
				# if !rsection[1]
					# raise _INTL("No trainer data file given in section {1}\n{2}",name,FileLineData.linereport)
				# end
				# rsection[3]=rsection[0]
				# rsection[4]=rsection[1]
				# rsection[5]=(name=="DefaultTrainerList")
				# if safeExists?("PBS/"+rsection[0])
					# rsection[0]=pbCompileBTTrainers("PBS/"+rsection[0])
				# else
					# rsection[0]=[]
				# end
				# if safeExists?("PBS/"+rsection[1])
					# filename="PBS/"+rsection[1]
					# rsection[1]=[]
					# pbCompilerEachCommentedLine(filename){|line,lineno|
						# rsection[1].push(PBPokemon.fromInspected(line))
					# }
				# else
					# rsection[1]=[]
				# end
				# if !rsection[2]
					# rsection[2]=[]
				# end
				# while rsection[2].include?("")
					# rsection[2].delete("")
				# end
				# rsection[2].compact!
				# sections.push(rsection)
		# }
	# }
	# save_data(sections,"Data/trainerlists.dat")
# end

def pbCompileTypes
	sections=[]
	typechart=[]
	types=[]
	nameToType={}
	requiredtypes={
		"Name"=>[1,"s"],
		"InternalName"=>[2,"s"],
	}
	optionaltypes={
		"IsPseudoType"=>[3,"b"],
		"IsSpecialType"=>[4,"b"],
		"Weaknesses"=>[5,"*s"],
		"Resistances"=>[6,"*s"],
		"Immunities"=>[7,"*s"]
	}
	currentmap=-1
	foundtypes=[]
	pbCompilerEachCommentedLine("PBS/types.txt") {|line,lineno|
		if line[/^\s*\[\s*(\d+)\s*\]\s*$/]
			sectionname=$~[1]
			if currentmap>=0
				for reqtype in requiredtypes.keys
					if !foundtypes.include?(reqtype)
						raise _INTL("Required value '{1}' not given in section '{2}'\n{3}",reqtype,currentmap,FileLineData.linereport)
					end
				end
				foundtypes.clear
			end
			currentmap=sectionname.to_i
			types[currentmap]=[currentmap,nil,nil,false,false,[],[],[]]
		else
			if currentmap<0
				raise _INTL("Expected a section at the beginning of the file\n{1}",FileLineData.linereport)
			end
			if !line[/^\s*(\w+)\s*=\s*(.*)$/]
				raise _INTL("Bad line syntax (expected syntax like XXX=YYY)\n{1}",FileLineData.linereport)
			end
			matchData=$~
			schema=nil
			FileLineData.setSection(currentmap,matchData[1],matchData[2])
			if requiredtypes.keys.include?(matchData[1])
				schema=requiredtypes[matchData[1]]
				foundtypes.push(matchData[1])
			else
				schema=optionaltypes[matchData[1]]
			end
			if schema
				record=pbGetCsvRecord(matchData[2],lineno,schema)
				types[currentmap][schema[0]]=record
			end
		end
	}
	types.compact!
	maxValue=0
	for type in types; maxValue=[maxValue,type[0]].max; end
	pseudotypes=[]
	specialtypes=[]
	typenames=[]
	typeinames=[]
	typehash={}
	for type in types
		pseudotypes.push(type[0]) if type[3]
		typenames[type[0]]=type[1]
		typeinames[type[0]]=type[2]
		typehash[type[0]]=type
	end
	for type in types
		n=type[1]
		for w in type[5]; if !typeinames.include?(w)
			raise _INTL("'{1}' is not a defined type (PBS/types.txt, {2}, Weaknesses)",w,n)
		end; end
		for w in type[6]; if !typeinames.include?(w)
			raise _INTL("'{1}' is not a defined type (PBS/types.txt, {2}, Resistances)",w,n)
		end; end
		for w in type[7]; if !typeinames.include?(w)
			raise _INTL("'{1}' is not a defined type (PBS/types.txt, {2}, Immunities)",w,n)
		end; end
	end
	for i in 0..maxValue
		pseudotypes.push(i) if !typehash[i]
	end
	pseudotypes.sort!
	for type in types; specialtypes.push(type[0]) if type[4]; end
	specialtypes.sort!
	MessageTypes.setMessages(MessageTypes::Types,typenames)
	code="class PBTypes\n"
	for type in types
		code+="#{type[2]}=#{type[0]}\n"
	end
	code+="def PBTypes.getCount; return #{types.length}; end\n"
	code+="def PBTypes.maxValue; return #{maxValue}; end\n"
	code+="def PBTypes.getName(id)\nreturn pbGetMessage(MessageTypes::Types,id)\nend\n"
	count=maxValue+1
	for i in 0...count
		type=typehash[i]
		j=0; k=i; while j<count
			typechart[k]=2
			atype=typehash[j]
			if type && atype
				typechart[k]=4 if type[5].include?(atype[2]) # weakness
				typechart[k]=1 if type[6].include?(atype[2]) # resistance
				typechart[k]=0 if type[7].include?(atype[2]) # immune
			end
			j+=1
			k+=count
		end
	end
	code+="end\n"
	eval(code)
	save_data([pseudotypes,specialtypes,typechart],"Data/types.dat")
	pbAddScript(code,"PBTypes")
	Graphics.update
end

def pbCompileModPokemonData(overwrite=true)
	mods = $ModList
	path = ""
	
	sections=[]
	requiredtypes={
		"Name"=>[0,"s"],
		"Kind"=>[0,"s"],
		"InternalName"=>[0,"c"],
		"Pokedex"=>[0,"S"],
		"Moves"=>[0,"*uE",nil,PBMoves],
		"Color"=>[:Color,"e",["Red","Blue","Yellow","Green","Black","Brown","Purple","Gray","White","Pink"]],
		"Type1"=>[:Type1,"e",PBTypes],
		"BaseStats"=>[:BaseStats,"uuuuuu"],
		"Rareness"=>[:CatchRate,"u"],
		"GenderRate"=>[:GenderRatio,"e",{"AlwaysMale"=>0,"FemaleOneEighth"=>31,
				"Female25Percent"=>63,"Female50Percent"=>127,"Female75Percent"=>191,
				"FemaleSevenEighths"=>223,"AlwaysFemale"=>254,"Genderless"=>255}],
		"Happiness"=>[:Happiness,"u"],
		"GrowthRate"=>[:GrowthRate,"e",{"Medium"=>0,"MediumFast"=>0,"Erratic"=>1,
				"Fluctuating"=>2,"Parabolic"=>3,"MediumSlow"=>3,"Fast"=>4,"Slow"=>5}],
		"StepsToHatch"=>[:EggSteps,"w"],
		"EffortPoints"=>[:EVs,"uuuuuu"],
		"Compatibility"=>[:EggGroups,"eg",{"1"=>1,"Monster"=>1,"2"=>2,"Water1"=>2,"Water 1"=>2,
				"3"=>3,"Bug"=>3,"4"=>4,"Flying"=>4,"5"=>5,"Field"=>5,"Ground"=>5,"6"=>6,
				"Fairy"=>6,"7"=>7,"Grass"=>7,"Plant"=>7,"8"=>8,"Human-like"=>8,"Human-Like"=>8,
				"Humanlike"=>8,"Humanoid"=>8,"Humanshape"=>8,"Human"=>8,"9"=>9,"Water3"=>9,
				"Water 3"=>9,"10"=>10,"Mineral"=>10,"11"=>11,"Amorphous"=>11,"Indeterminate"=>11,
				"12"=>12,"Water2"=>12,"Water 2"=>12,"13"=>13,"Ditto"=>13,"14"=>14,"Dragon"=>14,
				"15"=>15,"Undiscovered"=>15,"No eggs"=>15,"NoEggs"=>15,"None"=>15,"NA"=>15},
				{"1"=>1,"Monster"=>1,"2"=>2,"Water1"=>2,"Water 1"=>2,
				"3"=>3,"Bug"=>3,"4"=>4,"Flying"=>4,"5"=>5,"Field"=>5,"Ground"=>5,"6"=>6,
				"Fairy"=>6,"7"=>7,"Grass"=>7,"Plant"=>7,"8"=>8,"Human-like"=>8,"Human-Like"=>8,
				"Humanlike"=>8,"Humanoid"=>8,"Humanshape"=>8,"Human"=>8,"9"=>9,"Water3"=>9,
				"Water 3"=>9,"10"=>10,"Mineral"=>10,"11"=>11,"Amorphous"=>11,"Indeterminate"=>11,
				"12"=>12,"Water2"=>12,"Water 2"=>12,"13"=>13,"Ditto"=>13,"14"=>14,"Dragon"=>14,
				"15"=>15,"Undiscovered"=>15,"No eggs"=>15,"NoEggs"=>15,"None"=>15,"NA"=>15}],
		"Height"=>[:Height,"f"],
		"Weight"=>[:Weight,"f"],
		"BaseEXP"=>[:BaseEXP,"w"],
	}
	
	optionaltypes={
		"ModdedGraphics"=>[0,"i"],
		"BattlerPlayerY"=>[0,"i"],
		"BattlerEnemyY"=>[0,"i"],
		"BattlerAltitude"=>[0,"i"],
		"EggMoves"=>[0,"*E",PBMoves],
		"FormNames"=>[0,"S"],
		"RegionalNumbers"=>[0,"*w"],
		"Evolutions"=>[0,"*ses",nil,PBEvolution],
		"Habitat"=>[:Habitat,"e",["","Grassland","Forest","WatersEdge","Sea","Cave","Mountain","RoughTerrain","Urban","Rare"]],
		"Type2"=>[:Type2,"e",PBTypes],
		"Abilities"=>[:Abilities,"eg",PBAbilities,PBAbilities],
		"HiddenAbility"=>[:HiddenAbilities,"e",PBAbilities],
		"WildItemCommon"=>[:WildItemCommon,"*E",PBItems],
		"WildItemUncommon"=>[:WildItemUncommon,"*E",PBItems],
		"WildItemRare"=>[:WildItemRare,"*E",PBItems]
	}
	initdata = {}
	initdata[:ID] = 0
	initdata[:Color] = 0
	initdata[:Habitat] = 0
	initdata[:Type1] = 0
	initdata[:Type2] = 0
	initdata[:BaseStats] = []
	initdata[:CatchRate] = 0
	initdata[:GenderRatio] = 0
	initdata[:Happiness] = 0
	initdata[:GrowthRate] = 0
	initdata[:EggSteps] = 0
	initdata[:EVs] = []
	initdata[:Abilities] = []
	initdata[:EggGroups] = []
	initdata[:Height] = 0
	initdata[:Weight] = 0
	initdata[:BaseEXP] = 0
	initdata[:HiddenAbilities] = 0
	initdata[:WildItemCommon] = 0
	initdata[:WildItemUncommon] = 0
	initdata[:WildItemRare] = 0
	currentmap=-1
	#load vanilla data
	dexdatas=$cache.pkmn_dex
	eggmoves=$cache.pkmn_egg
	entries=getAllPokemonMessages(MessageTypes::Entries)
	kinds=getAllPokemonMessages(MessageTypes::Kinds)
	speciesnames=getAllPokemonMessages(MessageTypes::Species)
	moves=$cache.pkmn_moves
	evolutions=$cache.pkmn_evo
	regionals=[]
	formnames=getAllPokemonMessages(MessageTypes::FormNames)
	metrics=$cache.pkmn_metrics
	constants=moduleToHash(PBSpecies)
	maxValue=constants.values.max

	#Begin loading mod files
	mods.each{ |mod| 
		next if !($ModSettings[mod]["ModPBS"].include?("pokemon"))
		$ModLoadHandlers[mod] = ModLoadHandler.new(mod) if $ModLoadHandlers[mod] == nil
		next if !($ModLoadHandlers[mod].load_mod?)
		overwriteKeys = []
		selectiveOverwrite = false
		ignoreNewPokemon = false
		
		if $ModSettings[mod]["selectiveOverwrite"] == "true"
		ignoreNewPokemon = true if $ModSettings[mod]["ignoreNewPokemon"] == "true"
		selectiveOverwrite = true
		end
		
		File.open("Data/Mods/" + mod + "/PBS/pokemon.txt","rb"){|f|
		FileLineData.file="Data/Mods/" + mod + "/PBS/pokemon.txt"
		pbEachFileSection(f){|lastsection,currentmap|
			dexdata=initdata.clone
			
			dexdata[:ID]=currentmap
			
			abilarray = []
			evarray = []
			basestatarray = []
			egggrouparray = []
			thesemoves=[]
			theseevos=[]
			tempname = ""
			
			if !selectiveOverwrite
			if !lastsection["Type2"] || lastsection["Type2"]==""
				if !lastsection["Type1"] || lastsection["Type1"]==""
					raise _INTL("No Pokémon type is defined in section {2} (PBS/pokemon.txt)",key,sectionDisplay) if hash==requiredtypes
					next
				end
			lastsection["Type2"]=lastsection["Type1"].clone
			end
			end
			if selectiveOverwrite
			optionaltypes = requiredtypes.merge(optionaltypes)
			requiredtypes = { "InternalName"=>[0,"c"] }
			end
			[requiredtypes,optionaltypes].each{|hash|
			for key in hash.keys
				FileLineData.setSection(dexdata[:ID],key,lastsection[key])
				maxValue=[maxValue,dexdata[:ID]].max
				sectionDisplay=dexdata[:ID].to_s
				if dexdata[:ID]==0 && !ignoreNewPokemon
				raise _INTL("A Pokemon species can't be numbered 0 (PBS/pokemon.txt)")
				end
				if !lastsection[key] || lastsection[key]==""
				raise _INTL("Required entry {1} is missing or empty in section {2} (PBS/pokemon.txt)",key,sectionDisplay) if hash==requiredtypes
				next
				end
				secvalue=lastsection[key]
				rtschema=hash[key]
				schema=hash[key][1]
				valueindex=0
				loop do
				sublist=-1
				check = false
				
				for i in 0...schema.length
					next if schema[i,1]=="*"
					sublist+=1
					minus1=(schema[0,1]=="*") ? -1 : 0
					if schema[i,1]=="g" && secvalue==""
					if key=="Compatibility"
						dexdata[rtschema[0]][sublist]=dexdata[rtschema[0]][sublist-1]
					end
					break
					end
					case schema[i,1]
					when "e", "g"
						value=csvEnumField!(secvalue,rtschema[2+i+minus1],key,sectionDisplay)
					when "E"
						value=csvEnumField!(secvalue,rtschema[2+i+minus1],key,sectionDisplay)
					when "i"
						value=csvInt!(secvalue,key)
					when "u"
						value=csvPosInt!(secvalue,key)
					when "w"
						value=csvPosInt!(secvalue,key)
					when "f"
						value=csvFloat!(secvalue,key,sectionDisplay)
						value=(value*10).round
						if value<=0
						raise _INTL("Value '{1}' can't be less than or close to 0 (section {2}, PBS/pokemon.txt)",key,dexdata[:ID])
						end
					when "c", "s"
						value=csvfield!(secvalue)
					when "S"
						value=secvalue
						secvalue=""
					end
					
					if key=="InternalName"
						raise _INTL("Invalid internal name: {1} (section {2}, PBS/pokemon.txt)",value,dexdata[:ID]) if !value[/^(?![0-9])\w*$/]
						#constants+="#{value}=#{currentmap}\n"
						#puts 
						if (constants.keys.include?(value) && ($ModLoadHandlers[mod].load_species?(value)))
							#puts "overwriting " + value if $ModDebug

							dexdata[:ID] = constants[value]
							dexdata=dexdatas[dexdata[:ID]]
							speciesnames[dexdata[:ID]]=tempname
							$ListOfModPokemonByParent[dexdata[:ID]] = Hash[:parent => mod, :id => currentmap, :overwrite => overwrite]
						else
							if ignoreNewPokemon == true || !($ModLoadHandlers[mod].load_species?(value))
								dexdata[:ID] = 0
							else
								raise _INTL("#{mod} Error: pokemon #{value} is being added (not overwritten) and selectiveOverwrite is enabled in mod_settings.txt Check the internalname?") if selectiveOverwrite
								dexdata[:ID] = maxValue+1
								speciesnames[dexdata[:ID]]=tempname 
								constants[value] = dexdata[:ID]
								#puts "adding " + dexdata[:ID].to_s + " with internalname/speciesname = " + value + "/" + tempname if $ModDebug
								$ListOfModPokemonByParent[dexdata[:ID]] = Hash[:parent => mod, :id => currentmap, :overwrite => overwrite]
							end
							overwrite = false
							
						end
					elsif key=="BaseStats" && dexdata[:ID] != 0
					basestatarray[sublist]=value || 0
					elsif key=="EffortPoints" && dexdata[:ID] != 0
					evarray[sublist]=value || 0
					elsif key=="Abilities" && dexdata[:ID] != 0
					abilarray[sublist]=value || 0
					elsif key=="Compatibility" && dexdata[:ID] != 0
					egggrouparray[sublist]=value || 0
					elsif key=="EggMoves" && dexdata[:ID] != 0
					eggmoves[dexdata[:ID]]=[] if !eggmoves[dexdata[:ID]]
					eggmoves[dexdata[:ID]].push(value)
					elsif key=="Moves" && dexdata[:ID] != 0
					thesemoves.push(value)
					elsif key=="RegionalNumbers" && dexdata[:ID] != 0
					regionals[valueindex]=[] if !regionals[valueindex]
					regionals[valueindex][dexdata[:ID]]=value
					elsif key=="Evolutions" && dexdata[:ID] != 0
					theseevos.push(value)
					elsif key=="Kind" && dexdata[:ID] != 0
					raise _INTL("Kind {1} is greater than 20 characters long (section {2}, PBS/pokemon.txt)",value,dexdata[:ID]) if value.length>20
					kinds[dexdata[:ID]]=value
					elsif key=="ModdedGraphics" && dexdata[:ID] != 0
					if !($ListOfModPokemonByParent.keys.include?(dexdata[:ID]))
						$ListOfModPokemonByParent[dexdata[:ID]] = Hash[:parent => mod, :id => currentmap, :overwrite => overwrite] if value==1
					end
					elsif key=="Pokedex" && dexdata[:ID] != 0
					entries[dexdata[:ID]]=value
					elsif key=="BattlerPlayerY" && dexdata[:ID] != 0
					#pbCheckSignedWord(value,key)
					metrics[0][dexdata[:ID]]=value
					elsif key=="BattlerEnemyY" && dexdata[:ID] != 0
					#pbCheckSignedWord(value,key)
					metrics[1][dexdata[:ID]]=value
					elsif key=="BattlerAltitude" && dexdata[:ID] != 0
					#pbCheckSignedWord(value,key)
					metrics[2][dexdata[:ID]]=value
					elsif key=="Name" && dexdata[:ID] != 0
					raise _INTL("Species name {1} is greater than 20 characters long (section {2}, PBS/pokemon.txt)",value,dexdata[:ID]) if value.length>20
					tempname=value
					speciesnames[dexdata[:ID]]=tempname if selectiveOverwrite
					elsif key=="FormNames" && dexdata[:ID] != 0
					formnames[dexdata[:ID]]=value
					else
					dexdata[rtschema[0]]=value
					end
					valueindex+=1
				end
				break if secvalue==""
				break if schema[0,1]!="*"
				end
			end
			}
			movelist=[]
			evolist=[]
			for i in 0...thesemoves.length/2
			movelist.push([thesemoves[i*2],thesemoves[i*2+1],i])
			end
			movelist.sort!{|a,b| a[0]==b[0] ? a[2]<=>b[2] : a[0]<=>b[0]}
			for i in movelist; i.pop; end
			for i in 0...theseevos.length/3
			evolist.push([theseevos[i*3],theseevos[i*3+1],theseevos[i*3+2]])
			end
			moves[dexdata[:ID]]=movelist if lastsection.keys.include?("Moves") && dexdata[:ID] != 0
			evolutions[dexdata[:ID]]=evolist if lastsection.keys.include?("Evolutions") && dexdata[:ID] != 0
			dexdata[:BaseStats] = basestatarray if lastsection.keys.include?("BaseStats") && dexdata[:ID] != 0
			dexdata[:EVs] = evarray if lastsection.keys.include?("EffortPoints") && dexdata[:ID] != 0
			dexdata[:Abilities] = abilarray if lastsection.keys.include?("Abilities") && dexdata[:ID] != 0
			dexdata[:EggGroups] = egggrouparray if lastsection.keys.include?("Compatibility") && dexdata[:ID] != 0
			dexdatas.update(dexdata[:ID] => dexdata)
			if dexdata[:ID] != 0
				puts "#{mod}: Added pokemon with id " + dexdata[:ID].to_s + " and speciesname " + speciesnames[dexdata[:ID]].to_s + " Overwrite? " + overwrite.to_s + " selectiveOverwrite? " + selectiveOverwrite.to_s
			else 
				puts "#{mod}: Ignored pokemon #{currentmap}, ignoreNewPokemon is set to #{ignoreNewPokemon} (from mod_settings.ini), ModloadHandler response: #{$ModLoadHandlers[mod].load_species?(currentmap)}"
			end
		}
		
		}
	}
	if dexdatas.length==0
		raise _INTL("No Pokémon species are defined in pokemon.txt")
	end
	count=dexdatas.compact.length
	code="module PBSpecies\n#{hashtoString(constants)}"
	for i in 0...speciesnames.length
		speciesnames[i]="????????" if !speciesnames[i]
	end
	code+="def PBSpecies.getName(id)\nreturn pbGetMessage(MessageTypes::Species,id)\nend\n"
	code+="def PBSpecies.getCount\nreturn #{count}\nend\n"
	code+="def PBSpecies.maxValue\nreturn #{maxValue}\nend\nend"
	eval(code)
	pbAddModScript(code,"PBSpecies")
	for e in 0...evolutions.length
		evolist=evolutions[e]
		next if !evolist
		for i in 0...evolist.length
			FileLineData.setSection(i,"Evolutions","")
			evonib=evolist[i][1]
		if !(evolist[i][0].class == 1.class)
			evolist[i][0]=csvEnumField!(evolist[i][0],PBSpecies,"Evolutions",i)
			case PBEvolution::EVOPARAM[evonib]
			when 1
				evolist[i][2]=csvPosInt!(evolist[i][2])
			when 2
				evolist[i][2]=csvEnumField!(evolist[i][2],PBItems,"Evolutions",i)
			when 3
				evolist[i][2]=csvEnumField!(evolist[i][2],PBMoves,"Evolutions",i)
			when 4
				evolist[i][2]=csvEnumField!(evolist[i][2],PBSpecies,"Evolutions",i)
			when 5
				evolist[i][2]=csvEnumField!(evolist[i][2],PBTypes,"Evolutions",i)
			else
				evolist[i][2]=0
		end
			end
		end
	end
	
	$cache.pkmn_dex = dexdatas
	$cache.pkmn_metrics = metrics
	$cache.pkmn_moves = moves
	$cache.pkmn_egg = eggmoves
	$cache.pkmn_evo = evolutions
	
	File.open("Data/Mods/Modloader/graphicpaths.dat","wb"){|f|
		Marshal.dump($ListOfModPokemonByParent,f)
	}	
	File.open("Data/Mods/Modloader/evolutions.dat","wb"){|f|
		Marshal.dump(evolutions,f)
	}
	save_data(metrics,"Data/Mods/Modloader/metrics.dat")
	File.open("Data/Mods/Modloader/regionals.dat","wb"){|f|
		Marshal.dump(regionals,f)
	}
	File.open("Data/Mods/Modloader/dexdata.dat","wb"){|f|
		Marshal.dump(dexdatas,f)
	}
	File.open("Data/Mods/Modloader/eggEmerald.dat","wb"){|f|
		Marshal.dump(eggmoves,f)
	}
	MessageTypes.setMessages(MessageTypes::Species,speciesnames)
	MessageTypes.setMessages(MessageTypes::Kinds,kinds)
	MessageTypes.setMessages(MessageTypes::Entries,entries)
	MessageTypes.setMessages(MessageTypes::FormNames,formnames)
	File.open("Data/Mods/Modloader/attacksRS.dat","wb"){|f|
		Marshal.dump(moves,f)
	}
	
	
	MessageTypes.setMessages(MessageTypes::Species,speciesnames)
	MessageTypes.setMessages(MessageTypes::Kinds,kinds)
	MessageTypes.setMessages(MessageTypes::Entries,entries)
	MessageTypes.setMessages(MessageTypes::FormNames,formnames)
	
	
end

def saveModMessages(filename=nil)
	filename="Data/Mods/Modloader/messages.dat" if !filename
	messages = MessageTypes.messages
	
	File.open(filename,"wb"){|f|
		Marshal.dump(messages,f)
	}
end

def pbCompileAllModData(mustcompile)
	compilerruntime = Time.now
	#CP_Profiler.begin
	FileLineData.clear
	if mustcompile
		if (!$INEDITOR || LANGUAGES.length<2) && pbRgssExists?("Data/messages.dat")
			MessageTypes.loadMessageFile("Mods/Data/messages.dat")
		end
		# # No dependencies
		# yield(_INTL("Compiling type data"))
		# pbCompileModTypes
		# # No dependencies
		# yield(_INTL("Compiling town map data"))
		# #pbCompileModTownMap
		# # No dependencies
		# yield(_INTL("Compiling map connection data"))
		# #pbCompileModConnections
		# # No dependencies
		puts "Compiling mod ability data"
		pbCompileModAbilities
		# # Depends on PBTypes
		puts "Compiling mod move data"
		pbCompileModMoves
		# # Depends on PBMoves
		puts "Compiling mod item data"
		pbCompileModItems
		# # Depends on PBMoves, PBItems, PBTypes, PBAbilities
		puts "Compiling mod Pokemon data"
		pbCompileModPokemonData
		# # Depends on PBSpecies, PBMoves
		puts "Compiling mod machine data"
		pbCompileModMachines
		puts "Compiling mod maps..."
		compileModMaps
		# # Depends on PBSpecies, PBItems, PBMoves
		# yield(_INTL("Compiling Trainer data"))
		# #pbCompileModTrainers
		# # Depends on PBTrainers
		# yield(_INTL("Compiling phone data"))
		# #pbCompileModPhoneData
		# # Depends on PBTrainers
		# yield(_INTL("Compiling metadata"))
		# #pbCompileModMetadata
		# # Depends on PBTrainers
		# yield(_INTL("Compiling battle Trainer data"))
		# #pbCompileModTrainerLists
		# # Depends on PBSpecies
		puts "Compiling encounter data"
		pbCompileModEncounters
		# # Depends on PBSpecies, PBMoves
		# yield(_INTL("Compiling shadow move data"))
		# #pbCompileModShadowMoves
		# yield(_INTL("Compiling messages"))
		# # Depends on PBMoves, PBFieldEffects
		# yield(_INTL("Compiling field data"))
		# #pbCompileModFields
		# yield(_INTL("Compiling field notes"))
		# #pbCompileModFieldNotes if GAMETITLE == "Pokemon Reborn"
	doneCompiling
	else
		if (!$INEDITOR || LANGUAGES.length<2) && safeExists?("Data/messages.dat")
			MessageTypes.loadMessageFile("Data/messages.dat")
		end
	end
	#pbCompileModAnimations
	#pbCompileModTrainerEvents(mustcompile)
	#CP_Profiler.print
	#pbSetTextMessages
	#pbCombineScripts
	MessageTypes.saveMessages("Data/Mods/Modloader/messages.dat")
	if !$INEDITOR && LANGUAGES.length>=2
		pbLoadMessages("Data/"+LANGUAGES[$idk[:settings].language][1])
	end
	totalcompilertime = Time.now - compilerruntime
	#print totalcompilertime
end



# def quickCompile
	# msgwindow=Kernel.pbCreateMessageWindow;pbCompileAllData(true) {|msg| Kernel.pbMessageDisplay(msgwindow,msg,false) }
# end

# def pbCompileFields
	# fields = []
	# for i in 0...43
		# rawfield = FIELDEFFECTS[i]
		# next if !rawfield
		# currentfield = FEData.new
		# #Basic data copying
		# currentfield.fieldname = rawfield[:FIELDNAME] 			if rawfield[:FIELDNAME]
		# currentfield.intromessage = rawfield[:INTROMESSAGE] 		if rawfield[:INTROMESSAGE] 
		# currentfield.fieldgraphics = rawfield[:FIELDGRAPHICS] 		if rawfield[:FIELDGRAPHICS] 
		# currentfield.secretpoweranim = rawfield[:SECRETPOWERANIM]	if rawfield[:SECRETPOWERANIM] 
		# currentfield.naturemoves = rawfield[:NATUREMOVES] 		if rawfield[:NATUREMOVES] 
		# currentfield.mimicry = rawfield[:MIMICRY] 			if rawfield[:MIMICRY]
		# currentfield.statusmoveboost = rawfield[:STATUSMOVEBOOST]	if rawfield[:STATUSMOVEBOOST]
		# #now for worse shit
		# #invert hashes such that move => mod
		# movedamageboost = pbHashForwardizer(rawfield[:MOVEDAMAGEBOOST]) 	|| {}
		# movetypemod = pbHashForwardizer(rawfield[:MOVETYPEMOD])			|| {}
		# movetypechange = pbHashForwardizer(rawfield[:MOVETYPECHANGE])		|| {}
		# moveaccuracyboost = pbHashForwardizer(rawfield[:MOVEACCURACYBOOST]) 	|| {}
		# typedamageboost = pbHashForwardizer(rawfield[:TYPEDAMAGEBOOST]) 	|| {}
		# typetypemod = pbHashForwardizer(rawfield[:TYPETYPEMOD])			|| {}
		# typetypechange = pbHashForwardizer(rawfield[:TYPETYPECHANGE])		|| {}
		# fieldchange = pbHashForwardizer(rawfield[:FIELDCHANGE]) 		|| {}
		# typecondition = rawfield[:TYPECONDITION] 	? rawfield[:TYPECONDITION]	: {}
		# changecondition = rawfield[:CHANGECONDITION] ? rawfield[:CHANGECONDITION] : {}
		# dontchangebackup = rawfield[:DONTCHANGEBACKUP] ? rawfield[:DONTCHANGEBACKUP] : {}
		# changeeffects = rawfield[:CHANGEEFFECTS] 	? rawfield[:CHANGEEFFECTS]	: {}
		# #messages get stored separately and are replaced by an index
		# movemessages = rawfield[:MOVEMESSAGES]	|| {}
		# typemessages = rawfield[:TYPEMESSAGES]	|| {} 
		# changemessage = rawfield[:CHANGEMESSAGE] || {}
		# movemessagelist = []
		# typemessagelist = []
		# changemessagelist = []
		# [movemessages,typemessages,changemessage].each_with_index{|hashdata, index|
			# messagelist = hashdata.keys
			# newhashdata = {}
			# hashdata.each {|key, value|
				# newhashdata[messagelist.index(key)+1] = value
			# }
			# invhash = pbHashForwardizer(newhashdata)
			# case index
			# when 0
				# movemessagelist = messagelist
				# movemessages = invhash
			# when 1
				# typemessagelist = messagelist
				# typemessages = invhash
			# when 2
				# changemessagelist = messagelist
				# changemessage = invhash
			# end
		# }
		# #now we have all our hashes de-backwarded, and can fuse them all together.
		# #first, moves:
		# #get all the keys in one place
		# keys = (movedamageboost.keys << movetypemod.keys << movetypechange.keys << moveaccuracyboost.keys << fieldchange.keys).flatten 
		# #now we take all the old hashes and squish them into one:
		# fieldmovedata = {}
		# for move in keys
			# movedata = {}
			# movedata[:mult] = movedamageboost[move] if movedamageboost[move]
			# movedata[:typemod] = movetypemod[move] if movetypemod[move]
			# movedata[:typechange] = movetypechange[move] if movetypechange[move]
			# movedata[:accmod] = moveaccuracyboost[move] if moveaccuracyboost[move]
			# movedata[:multtext] = movemessages[move] if movemessages[move]
			# movedata[:fieldchange] = fieldchange[move] if fieldchange[move]
			# movedata[:changetext] = changemessage[move] if changemessage[move]
			# movedata[:changeeffect] = changeeffects[move] if changeeffects[move]
			# movedata[:dontchangebackup] = dontchangebackup.include?(move) ? true : false
			# fieldmovedata[move] = movedata
		# end
		# #now, types!
		# fieldtypedata = {}
		# keys = (typedamageboost.keys << typetypemod.keys << typetypechange.keys).flatten
		# for type in keys
			# typedata = {}
			# typedata[:mult] = typedamageboost[type] if typedamageboost[type]
			# typedata[:typemod] = typetypemod[type] if typetypemod[type]
			# typedata[:typechange] = typetypechange[type] if typetypechange[type]
			# typedata[:multtext] = typemessages[type] if typemessages[type]
			# typedata[:condition] = typecondition[type] if typecondition[type]
			# fieldtypedata[type] = typedata
		# end
		# #seeds for good measure.
		# seeddata = {}
		# seeddata = {
			# :seedtype => rawfield[:SEED],
			# :effect => rawfield[:SEEDEFFECT],
			# :duration => rawfield[:SEEDEFFECTVAL],
			# :message => rawfield[:SEEDEFFECTSTR],
			# :animation => rawfield[:SEEDANIM],
			# :stats => rawfield[:SEEDSTATS]
		# }
		# currentfield.fieldtypedata = fieldtypedata
		# currentfield.fieldmovedata = fieldmovedata
		# currentfield.seeddata = seeddata
		# currentfield.movemessagelist = movemessagelist
		# currentfield.typemessagelist = typemessagelist
		# currentfield.changemessagelist = changemessagelist
		# currentfield.fieldchangeconditions = changecondition
		# #all done!
		# fields.push(currentfield)
	# end
	# save_data(fields,"Data/fields.dat")
	# $cache.FEData = fields
# end