# v1.0.0
# Made by Waynolt
# Usage:
# (any of the values can be omitted, in which case the defaults will be used instead)
# ('Kenko' and 'Kogeki' in this example are the names of the trainers we are going to add)

# Call a battle with a custom backdrop from an event:
# lcmal_pbTrainerBattle(PBTrainers::WANDERER, 'Kenko', 'gg wp!', false, 0, false, 0, backdrop: 'Starlight')

# Code to be put in your mod:


$lcmal_trainerClasses={} if !defined?(lcmal_trainerClasses)
$lcmal_trainerClasses['ExampleTrainerClass']={
  :title => "ExampleTrainerClass",
  :skill => 100,
  :moneymult => 17,
  :battleBGM => "Magical Girl's Crusade.ogg",
  :winBGM => "Victory2",
  :sprites => {
    :fullFigure => 'Data/Mods/libCommonModAssets/trainer400.png',
    :overworld => 'Data/Mods/libCommonModAssets/trchar400.png',
    :vsBar => 'Data/Mods/libCommonModAssets/vsBar400.png',
    :vsTrainer => 'Data/Mods/libCommonModAssets/vsTrainer400.png'
  }
}

$lcmal_trainers={} if !defined?(lcmal_trainers)
$lcmal_trainers['TrainerName'] = {
  :party => [
    {
      TPSPECIES => PBSpecies::EXAMPLEMODPOKEMON,
      TPLEVEL => 1,
      TPFORM => 0,
      TPITEM => 0,
      TPMOVE1 => PBMoves::EXAMPLEMOVE,
      TPMOVE2 => 0,
      TPMOVE3 => 0,
      TPMOVE4 => 0,
      TPABILITY => 0,
      TPGENDER => 0, # 0 Male, 1 Female, 2 Other
      TPSHINY => false,
      TPNATURE => 0,
      TPIV => 10,
      TPHPEV => 0,
      TPATKEV => 0,
      TPDEFEV => 0,
      TPSPEEV => 0,
      TPSPAEV => 0,
      TPSPDEV => 0,
      TPHAPPINESS => 70,
      TPNAME => '',
      TPSHADOW => false,
      TPBALL => 0
    },
    {
      TPSPECIES => PBSpecies::CHARMANDER,
      TPMOVE1 => PBMoves::EMBER
    }
  ]
}
$lcmal_trainers['Jonathan'] = {
  :party => [
    {
      TPSPECIES => 34,
      TPMOVE1 => 364
    }
  ],
  :items => [
    # This works too if you prefer
    PBItems::MAXPOTION,
    PBItems::BUBBLETEA
  ]
}

#################################################################