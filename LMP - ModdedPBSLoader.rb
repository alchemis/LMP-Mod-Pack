$ListOfModPokemonByParent = Hash[]
$ModPBSToLoad = Hash[] if !defined?($ModPBSToLoad)
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
	

def pbCompileModPokemonData(mod,overwrite=true)

  if overwrite == true
	path = mod + "/pokemonoverwrites.txt"
  else
    path = mod + "/newpokemon.txt"
  end
  
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
  File.open("Data/Mods/" + path,"rb"){|f|
    FileLineData.file="Data/Mods/" + path
    pbEachFileSection(f){|lastsection,currentmap|
      dexdata=initdata.clone
	  dexdata[:ID]=currentmap if overwrite
	  dexdata[:ID]=maxValue + 1 if !overwrite
      abilarray = []
      evarray = []
      basestatarray = []
      egggrouparray = []
      thesemoves=[]
      theseevos=[]
	  
	  
	  
      if !lastsection["Type2"] || lastsection["Type2"]==""
        if !lastsection["Type1"] || lastsection["Type1"]==""
          raise _INTL("No Pokémon type is defined in section {2} (PBS/pokemon.txt)",key,sectionDisplay) if hash==requiredtypes
          next
        end
        lastsection["Type2"]=lastsection["Type1"].clone
      end
      [requiredtypes,optionaltypes].each{|hash|
        for key in hash.keys
          FileLineData.setSection(dexdata[:ID],key,lastsection[key])
          maxValue=[maxValue,dexdata[:ID]].max
          sectionDisplay=dexdata[:ID].to_s
          if dexdata[:ID]==0
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
              if key=="BaseStats"
                basestatarray[sublist]=value || 0
              elsif key=="EffortPoints"
                evarray[sublist]=value || 0
              elsif key=="Abilities"
                abilarray[sublist]=value || 0
              elsif key=="Compatibility"
                egggrouparray[sublist]=value || 0
              elsif key=="EggMoves"
                eggmoves[dexdata[:ID]]=[] if !eggmoves[dexdata[:ID]]
                eggmoves[dexdata[:ID]].push(value)
              elsif key=="Moves"
                thesemoves.push(value)
              elsif key=="RegionalNumbers"
                regionals[valueindex]=[] if !regionals[valueindex]
                regionals[valueindex][dexdata[:ID]]=value
              elsif key=="Evolutions"
                theseevos.push(value)
              elsif key=="InternalName"
                raise _INTL("Invalid internal name: {1} (section {2}, PBS/pokemon.txt)",value,dexdata[:ID]) if !value[/^(?![0-9])\w*$/]
                #constants+="#{value}=#{currentmap}\n"
				constants.delete(constants.key(dexdata[:ID]))
				constants[value] = dexdata[:ID]
              elsif key=="Kind"
                raise _INTL("Kind {1} is greater than 20 characters long (section {2}, PBS/pokemon.txt)",value,dexdata[:ID]) if value.length>20
                kinds[dexdata[:ID]]=value
			  elsif key=="ModdedGraphics"
				$ListOfModPokemonByParent[dexdata[:ID]] = Hash[:parent => mod, :id => currentmap, :overwrite => overwrite] if value==1
			  
              elsif key=="Pokedex"
                entries[dexdata[:ID]]=value
              elsif key=="BattlerPlayerY"
                #pbCheckSignedWord(value,key)
                metrics[0][dexdata[:ID]]=value
              elsif key=="BattlerEnemyY"
                #pbCheckSignedWord(value,key)
                metrics[1][dexdata[:ID]]=value
              elsif key=="BattlerAltitude"
                #pbCheckSignedWord(value,key)
                metrics[2][dexdata[:ID]]=value
              elsif key=="Name"
                raise _INTL("Species name {1} is greater than 20 characters long (section {2}, PBS/pokemon.txt)",value,dexdata[:ID]) if value.length>20
                speciesnames[dexdata[:ID]]=value
              elsif key=="FormNames"
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
      moves[dexdata[:ID]]=movelist
      evolutions[dexdata[:ID]]=evolist
      dexdata[:BaseStats] = basestatarray
      dexdata[:EVs] = evarray
      dexdata[:Abilities] = abilarray
      dexdata[:EggGroups] = egggrouparray
	  ##modded
	  #if overwrite == false && !(dexdatas.length==0)
		#dexdata[:ID] = maxValue
	  #end
	  dexdatas.update(dexdata[:ID] => dexdata)
	  puts "Added pokemon with id " + dexdata[:ID].to_s + " and speciesname " + speciesnames[dexdata[:ID]] +" Overwrite? " + overwrite.to_s
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
  
  
  
  MessageTypes.setMessages(MessageTypes::Species,speciesnames)
  MessageTypes.setMessages(MessageTypes::Kinds,kinds)
  MessageTypes.setMessages(MessageTypes::Entries,entries)
  MessageTypes.setMessages(MessageTypes::FormNames,formnames)
  
  
end

def pbCompileModAbilities(mod,overwrite=true)

  if overwrite == true
	path = mod + "/abilityoverwrites.txt"
  else
    path = mod + "/newabilities.txt"
  end
  
  records=moduleToHash(PBAbilities)
  movenames=getAllPokemonMessages(MessageTypes::Abilities)
  movedescs=getAllPokemonMessages(MessageTypes::AbilityDescs)
  maxValue=PBAbilities.maxValue
  
  pbCompilerEachPreppedLine("Data/Mods/"+path){|line,lineno|
     record=pbGetCsvRecord(line,lineno,[0,"vnss"])
	  if overwrite == false
	    record[0] = maxValue+1
	  end
     movenames[record[0]]=record[2]
     movedescs[record[0]]=record[3]
     maxValue=[maxValue,record[0]].max
	 
	 records.delete(records.key(records[0]))
	 records[record[1]] = record[0]
	 puts "Added Ability with id " + record[0].to_s + " Overwrite? " + overwrite.to_s
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

def pbCompileModMoves(mod,overwrite=true)

  if overwrite == true
	path = mod + "/moveoverwrites.txt"
  else
    path = mod + "/newmoves.txt"
  end
  

  records=moduleToHash(PBMoves)
  movenames=getAllPokemonMessages(MessageTypes::Moves)
  movedescs=getAllPokemonMessages(MessageTypes::MoveDescriptions)
  movedata=$cache.pkmn_move
  movedata[0] = [0,0,0,0,0,0,0,0,0,0]
  
  maxValue=PBMoves.maxValue
  
  pbCompilerEachPreppedLine("Data/Mods/"+path){|line,lineno|
      thisline=line.clone
      record=[]
      flags=0
      record=pbGetCsvRecord(line,lineno,[0,"vnsxueeuuuxiss",
        nil,nil,nil,nil,nil,PBTypes,["Physical","Special","Status"],
        nil,nil,nil,nil,nil,nil,nil])
      #pbCheckWord(record[3],_INTL("Function code"))
	  if overwrite == false
	    record[0] = maxValue+1
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
      
      movedata[record[0]]=[                                             #movedata[fuckinpieceofshit][3]
        record[3],  # Function code
        record[4],  # Damage
        record[5],  # Type
        record[6],  # Category
        record[7],  # Accuracy
        record[8],  # Total PP
        record[9],  # Effect chance
        record[10], # Target
        record[11], # Priority
        flags,      # Flags
      ]
      movenames[record[0]]=record[2]  # Name
      movedescs[record[0]]=record[13] # Description

		maxValue=[maxValue,record[0]].max
		records.delete(records.key(records[0]))
		records[record[1]] = record[0]
		puts "Added move with id " + record[0].to_s + " Overwrite? " + overwrite.to_s

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

def pbLoadModdedPBS
	for key,value in $ModPBSToLoad
		puts "Loading "+key.to_s+" PBS Files.."
		if :newmoves in value
			pbCompileModMoves(key,overwrite=false)
		end
		if :moveoverwrites in value
			pbCompileModMoves(key,overwrite=true)
		end
		if :newabilities in value
			pbCompileModAbilities(key,overwrite=false)
		end
		if :abilityoverwrites in value
			pbCompileModAbilities(key,overwrite=true)
		end
		if :newpokemon in value
			pbCompileModPokemonData(key,overwrite=false)
		end
		if :pokemonoverwrites in value
			pbCompileModPokemonData(key,overwrite=true)
		end
	
	end
end

pbLoadModdedPBS
=begin
pbCompileModMoves("LMP - DummyPokemon",overwrite=false)
pbCompileModMoves("LMP - DummyPokemon")
pbCompileModAbilities("LMP - DummyPokemon",overwrite=true)
pbCompileModAbilities("LMP - DummyPokemon",overwrite=false)
pbCompileModPokemonData("LMP - DummyPokemon")
pbCompileModPokemonData("LMP - DummyPokemon",overwrite=false)
=end

