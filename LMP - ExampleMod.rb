$ModPBSToLoad=Hash[] if !defined?($ModPBSToLoad)
$ModPBSToLoad = Hash["LMP - ExampleMod" => [:newabilties, :newmoves, :newpokemon, :pokemonoverwrites, :moveoverwrites, :abilityoverwrites]]

#This is all you need to do to import/overwrite pokemon. At the moment load order is not implemented, but once it is this file will be obsolete.
#What it does is store which files it needs to load in a hash to be accessed by the pbs loader.
#Syntax notes:
#If your pokemon requires graphics files which aren't present in the base games, you need a line with "ModdedGraphics=1" in your pokemon section in newpokemon.txt,
#and put the graphics files in newpokemon/Graphics or overwritepokemon/Graphics, depending on which txt the pokemon is in. 
#If not overwriting, the pokemon ID as defined in newpokemon.txt is only used for graphics and otherwise does not matter
#Moves need a valid function code to have an effect, refer to pokemon essentials wiki for details.
#Abilities