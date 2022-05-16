#gem load example
$LOAD_PATH.append("#{$LOAD_PATH[0]}\\Data\\Mods\\lib") #append the path where the gems are to the LOAD_PATH

#just require them like so
require 'json'
require 'neatjson'
require 'Scripts/Reborn/montext.rb'
require 'yaml'



def jsonWritePokemon
  puts "dumping cass new pokemon hashes into json huehueheu"
  File.open("YAML/bulba.json","w") do |f|
      f.write(JSON.neat_generate(MONHASH[:BULBASAUR]))
  end
end

def yamlWritePokemon
  puts "dumping cass new pokemon hashes into json huehueheu"
  File.open("YAML/bulba.yaml","w") do |f|
      f.write(YAML.dump(MONHASH[:BULBASAUR]))
  end
end


jsonWritePokemon
yamlWritePokemon


f = File.read("YAML/bulba.yaml")
test_parse = YAML.load(f)
puts "loaded object is the same as the saved object" if test_parse == MONHASH[:BULBASAUR]
puts "done"

# File.open("moves.json","w") do |f|
#     f.write(JSON.pretty_generate(MOVEHASH))
# end