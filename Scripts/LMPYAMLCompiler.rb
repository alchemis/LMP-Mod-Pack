#$LOAD_PATH.clear
$LOAD_PATH.append(Dir.pwd)
$LOAD_PATH.append("#{Dir.pwd}/Data/Mods/lib")
require 'yaml'
require 'stringsuwu'
require 'Scripts/Reborn/montext.rb'

Dir[File.join(__dir__, 'Scripts', '*.rb')].each { |file| require file }
loadMods
MonHash = Hash[]
MonHash[:MAGIKARP] = MONHASH[:BULBASAUR]
$ModListYAML = ["yamltest"]

def pbCompileYAMLPokemonData(output)
  mods = $ModListYAML
  mod_pokemon_hash = Hash[]

  #define an initial dexdata hash
  initdata = Hash[
    :ID => 0,
    :Color => 0,
    :Habitat => 0,
    :Type1 => 0,
    :Type2 => 0,
    :BaseStats => [],
    :CatchRate => 0,
    :GenderRatio => 0,
    :Happiness => 0,
    :GrowthRate => 0,
    :EggSteps => 0,
    :EVs => [],
    :Abilities => [],
    :EggGroups => [],
    :Height => 0,
    :Weight => 0,
    :BaseEXP => 0,
    :HiddenAbilities => 0,
    :WildItemCommon => 0,
    :WildItemUncommon => 0,
    :WildItemRare => 0
  ]

  #load vanilla data

  dexdatas=$cache.pkmn_dex #array of hashes
  eggmoves=$cache.pkmn_egg 
  entries=getAllPokemonMessages(MessageTypes::Entries)
  kinds=getAllPokemonMessages(MessageTypes::Kinds)
  speciesnames=getAllPokemonMessages(MessageTypes::Species)
  moves=$cache.pkmn_moves
  evolutions=$cache.pkmn_evo
  regionals=[]
  formnames=getAllPokemonMessages(MessageTypes::FormNames)
  metrics=$cache.pkmn_metrics
  constants=moduleToHash(PBSpecies) # hash containing a list of all pokemon, formatted like: {internalname => id}
  maxValue=constants.values.max # the highest ID that's occupied by a pokemon

  #load mod data
  mods.each{ |mod| 

    #handle stuff from mod settings
    next if !($ModSettings[mod]["ModPBS"].include?("pokemon"))
    mod_tms_hash = Hash[]
    selectiveOverwrite = false
    ignoreNewPokemon = false
    overwrite = true
    selectiveOverwrite = true if $ModSettings[mod]["selectiveOverwrite"] == "true"
    ignoreNewPokemon = true if $ModSettings[mod]["ignoreNewPokemon"] == "true"

    #load the yaml file and begin creating the objects we need to output
    File.open("Data/Mods/" + mod + "/PBS/pokemon.yaml","rb"){|f|
      dexdata=initdata.clone
      thesemoves = []
      theseevos = []
      pokemon_hash = YAML.load(f)
      pokemon_hash.each{ |species , species_hash|
        species = species.to_s
      if constants.keys.include?(species)
        dexdata[:ID] = constants[species]
        dexdata=dexdatas[dexdata[:ID]] #if the pokemon already exists, load its data as a template
        #speciesnames[dexdata[:ID]]=tempname
      else
        next if ignoreNewPokemon
        dexdata[:ID] = maxValue+1 #if it doesn't, give it the next avaliable ID
        constants[species] = maxValue+1
        overwrite = false
      end
    
      species_hash.each{|key , value|

        dexdata[key] = value if initdata.include?(key) #each key gets put in initdata if a key with the same name exists in there

        case
        when key == :EggMoves
          eggmoves[dexdata[:ID]] = value.stringify
        when key == :moveset
          thesemoves.push(value.stringify)
        when key == :RegionalNumbers
          next
        when key==:evolutions
          theseevos.push(value.stringify)
        when key == :kind
          raise _INTL("Kind {1} is greater than 20 characters long (section {2}, {3}/PBS/pokemon.txt)",value,dexdata[:ID],mod) if value.length>20
          kinds[dexdata[:ID]]=value
        when key == :tmlist
          key.each{ |move|
            move = move.stringify
            mod_tms_hash[move] = [] if !mod_tms_hash.keys.include?[move]
            mod_tms_hash[move].append(species)
          }
        when key==:ModdedGraphics
          if !($ListOfModPokemonByParent.keys.include?(dexdata[:ID]))
            $ListOfModPokemonByParent[dexdata[:ID]] = Hash[:parent => mod, :id => currentmap, :overwrite => overwrite] if value==1
          end
        when key == :dexentry
          entries[dexdata[:ID]]=value
        when key == :BattlerPlayerY
          metrics[0][dexdata[:ID]]=value
        when key == :BattlerEnemyY
          metrics[1][dexdata[:ID]]=value
        when key == :BattlerAltitude
          metrics[2][dexdata[:ID]]=value
        when key == :name
          raise _INTL("Species name {1} is greater than 20 characters long (section {2}, PBS/pokemon.txt)",value,dexdata[:ID]) if value.length>20
          speciesnames[dexdata[:ID]]=value 
        when key == :FormNames
          #???
          next
        else
            next
        end
    }
      }
      

    }
  }
end
# def pbCompileYAMLPokemonData()



                    

#                     elsif key=="Name" && dexdata[:ID] != 0
#                       raise _INTL("Species name {1} is greater than 20 characters long (section {2}, PBS/pokemon.txt)",value,dexdata[:ID]) if value.length>20
#                       tempname=value
#                       speciesnames[dexdata[:ID]]=tempname if selectiveOverwrite
#                     elsif key=="FormNames" && dexdata[:ID] != 0
#                       formnames[dexdata[:ID]]=value
#                     else
#                       dexdata[rtschema[0]]=value
#                     end
#                     valueindex+=1
#                   end
#                   break if secvalue==""
#                   break if schema[0,1]!="*"
#                 end
#               end
#             }
#             movelist=[]
#             evolist=[]
#             for i in 0...thesemoves.length/2
#               movelist.push([thesemoves[i*2],thesemoves[i*2+1],i])
#             end
#             movelist.sort!{|a,b| a[0]==b[0] ? a[2]<=>b[2] : a[0]<=>b[0]}
#             for i in movelist; i.pop; end
#             for i in 0...theseevos.length/3
#               evolist.push([theseevos[i*3],theseevos[i*3+1],theseevos[i*3+2]])
#             end
#             moves[dexdata[:ID]]=movelist if lastsection.keys.include?("Moves") && dexdata[:ID] != 0
#             evolutions[dexdata[:ID]]=evolist if lastsection.keys.include?("Evolutions") && dexdata[:ID] != 0
#             dexdata[:BaseStats] = basestatarray if lastsection.keys.include?("BaseStats") && dexdata[:ID] != 0
#             dexdata[:EVs] = evarray if lastsection.keys.include?("EffortPoints") && dexdata[:ID] != 0
#             dexdata[:Abilities] = abilarray if lastsection.keys.include?("Abilities") && dexdata[:ID] != 0
#             dexdata[:EggGroups] = egggrouparray if lastsection.keys.include?("Compatibility") && dexdata[:ID] != 0
#             dexdatas.update(dexdata[:ID] => dexdata)
#             if dexdata[:ID] != 0
#               puts "#{mod}: Added pokemon with id " + dexdata[:ID].to_s + " and speciesname " + speciesnames[dexdata[:ID]].to_s + " Overwrite? " + overwrite.to_s + " selectiveOverwrite? " + selectiveOverwrite.to_s
#             else 
#               puts "#{mod}: Ignored pokemon #{currentmap}, Reason: ignoreNewPokemon is set to true in mod_settings.ini"
#             end
#           }
          
#         }
#     }
#     if dexdatas.length==0
#       raise _INTL("No Pokémon species are defined in pokemon.txt")
#     end
#     count=dexdatas.compact.length
#     code="module PBSpecies\n#{hashtoString(constants)}"
#     for i in 0...speciesnames.length
#       speciesnames[i]="????????" if !speciesnames[i]
#     end
#     code+="def PBSpecies.getName(id)\nreturn pbGetMessage(MessageTypes::Species,id)\nend\n"
#     code+="def PBSpecies.getCount\nreturn #{count}\nend\n"
#     code+="def PBSpecies.maxValue\nreturn #{maxValue}\nend\nend"
#     eval(code)
#     pbAddModScript(code,"PBSpecies")
#     for e in 0...evolutions.length
#       evolist=evolutions[e]
#       next if !evolist
#       for i in 0...evolist.length
#         FileLineData.setSection(i,"Evolutions","")
#         evonib=evolist[i][1]
#         if !(evolist[i][0].class == 1.class)
#             evolist[i][0]=csvEnumField!(evolist[i][0],PBSpecies,"Evolutions",i)
#             case PBEvolution::EVOPARAM[evonib]
#               when 1
#                 evolist[i][2]=csvPosInt!(evolist[i][2])
#               when 2
#                 evolist[i][2]=csvEnumField!(evolist[i][2],PBItems,"Evolutions",i)
#               when 3
#                 evolist[i][2]=csvEnumField!(evolist[i][2],PBMoves,"Evolutions",i)
#               when 4
#                 evolist[i][2]=csvEnumField!(evolist[i][2],PBSpecies,"Evolutions",i)
#               when 5
#                 evolist[i][2]=csvEnumField!(evolist[i][2],PBTypes,"Evolutions",i)
#               else
#                 evolist[i][2]=0
#           end
#         end
#       end
#     end
    
#     $cache.pkmn_dex = dexdatas
#     $cache.pkmn_metrics = metrics
#     $cache.pkmn_moves = moves
#     $cache.pkmn_egg = eggmoves
#     $cache.pkmn_evo = evolutions
    
#     File.open("Data/Mods/graphicpaths.dat","wb"){|f|
#       Marshal.dump($ListOfModPokemonByParent,f)
#     }  
#     File.open("Data/Mods/evolutions.dat","wb"){|f|
#       Marshal.dump(evolutions,f)
#     }
#     save_data(metrics,"Data/Mods/metrics.dat")
#     File.open("Data/Mods/regionals.dat","wb"){|f|
#       Marshal.dump(regionals,f)
#     }
#     File.open("Data/Mods/dexdata.dat","wb"){|f|
#       Marshal.dump(dexdatas,f)
#     }
#     File.open("Data/Mods/eggEmerald.dat","wb"){|f|
#       Marshal.dump(eggmoves,f)
#     }
#     MessageTypes.setMessages(MessageTypes::Species,speciesnames)
#     MessageTypes.setMessages(MessageTypes::Kinds,kinds)
#     MessageTypes.setMessages(MessageTypes::Entries,entries)
#     MessageTypes.setMessages(MessageTypes::FormNames,formnames)
#     File.open("Data/Mods/attacksRS.dat","wb"){|f|
#       Marshal.dump(moves,f)
#     }
    
    
#     MessageTypes.setMessages(MessageTypes::Species,speciesnames)
#     MessageTypes.setMessages(MessageTypes::Kinds,kinds)
#     MessageTypes.setMessages(MessageTypes::Entries,entries)
#     MessageTypes.setMessages(MessageTypes::FormNames,formnames)
    
    
#   end