
class ExampleModMegas

    ModForms = {
        PBSpecies::EXAMPLEMODPOKEMON => {
            :FormName => {1 => "Mega"},
            :DefaultForm => 0,
        :MegaForm => 1,

            "Mega" => {
                :BaseStats => [79,103,120,78,135,115],
                :Ability => PBAbilities::DRIZZLE,
                :Weight => 1011
            }
        }
    }

    ModMegaStones = {
        PBSpecies::EXAMPLEMODPOKEMON  => [:EXAMPLEITE],
    }
end

$MegaStones.merge(ExampleModMegas::ModMegaStones)
PokemonForms.merge(ExampleModMegas::ModForms)
PBStuff.reloadMegastones