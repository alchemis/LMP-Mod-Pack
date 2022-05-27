
class ExampleModForms #change this to the name of your mod
    #refer to Scripts/MultipleForms.rb to see how these are done in the base game
    #if you put a vanilla species here you'll have to define ALL of its forms because they will be overwritten.
    ModForms = {
        PBSpecies::EXAMPLEMODPOKEMON => {
            :FormName => {
                2 => "Alolan",
                1 => "Mega"
            },
            :DefaultForm => 0, 
            #known limitation: if a mon has both permanent and mega forms it will revert to the default form after battle, will look into this later.
            :MegaForm => 1,
            :OnCreation => proc{
                maps=[38]
                # Map IDs for alolan form
                # the "2" in the next line refers to form 2
                next $game_map && maps.include?($game_map.map_id) ? 2 : 0
             },
            "Mega" => {
                :BaseStats => [79,103,120,78,135,115],
                :Ability => PBAbilities::DRIZZLE,
                :Weight => 1011
            },
            "Alolan" => {
                :DexEntry => "In hot weather, this Pokémon makes ice shards with its six tails and sprays them around to cool itself off.",
                :Type1 => PBTypes::ICE,
                :Type2 => PBTypes::ICE,
                :Ability => [PBAbilities::SNOWCLOAK,PBAbilities::SNOWWARNING],
                :Movelist => [[1,PBMoves::POWDERSNOW],[4,PBMoves::TAILWHIP],[7,PBMoves::ROAR],
                    [9,PBMoves::BABYDOLLEYES],[10,PBMoves::ICESHARD],[12,PBMoves::CONFUSERAY],
                    [15,PBMoves::ICYWIND],[18,PBMoves::PAYBACK],[20,PBMoves::MIST],
                    [23,PBMoves::FEINTATTACK],[26,PBMoves::HEX],[28,PBMoves::AURORABEAM],
                    [31,PBMoves::EXTRASENSORY],[34,PBMoves::SAFEGUARD],[36,PBMoves::ICEBEAM],
                    [39,PBMoves::IMPRISON],[42,PBMoves::BLIZZARD],[44,PBMoves::GRUDGE],
                    [47,PBMoves::CAPTIVATE],[50,PBMoves::SHEERCOLD]],
                :EggMoves => [PBMoves::AGILITY,PBMoves::CHARM,PBMoves::DISABLE,PBMoves::ENCORE,
                        PBMoves::EXTRASENSORY,PBMoves::FLAIL,PBMoves::FREEZEDRY,PBMoves::HOWL,
                        PBMoves::HYPNOSIS,PBMoves::MOONBLAST,PBMoves::POWERSWAP,PBMoves::SPITE,
                        PBMoves::SECRETPOWER,PBMoves::TAILSLAP],
                :WildHoldItems => [0,PBItems::SNOWBALL,0],
                :GetEvo => [[38,7,692]]
            }
        }
    }

    ModMegaStones = {
        PBSpecies::EXAMPLEMODPOKEMON  => [:EXAMPLEITE],
    }
end

#run these threee lines after defining your forms
$MegaStones.merge!(ExampleModForms::ModMegaStones)
PokemonForms.merge!(ExampleModForms::ModForms)
PBStuff.reloadMegastones
