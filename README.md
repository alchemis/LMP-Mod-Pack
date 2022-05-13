# Welcome to LMP Mod Pack
This is a mod pack for **Pokémon Reborn.**
How to install:

 - Download the project zip and copy it into a working installation of Reborn,
 - Heavily WIP, won't run without extra tweaking, gui is not finished yet and you'd need python installed to run it
 - Will update this doc when it's more usable.
 
 
**Dependencies**:
 - **LMPModloader**: depends on **LMP - ModdedPokemonGraphicsLoader** and **LMPModcompiler**
 - **LMP - CreateAllFields**: depends on **LMPModloader**
 - **LMP - ExampleMod**: depends on **LMPModloader**

**What the mods do:**
 - **LMP - FastHatch:** Skips the animation when hatching eggs, if **AMB - AddOpt** is installed it adds a toggle in the menu.
 - **LMPModloader:** Loads Pokémon, abilities and moves from dat files in Mods folder at runtime, does absolutely nothing on its own.
 - **LMPModCompiler:** Compiles PBS files in mods folder and data from vanilla into new .dat files in Mods folder, only runs if Mods/mustcompile.ini doesn't exist.
 - **LMP - ModdedPokemonGraphicsLoader:** Loads Pókemon graphics from Mods folder at runtime, does nothing on its own.
 - **LMP - CreateAllFields:** Allows most fields to be created with a move, like Misty Terrain. These moves are signature moves of otherwise subpar Pokémon. (See list in uhhh i'll make it sometime)
 - **LMP - ExampleMod:** Using ModdedPBSLoader and ModdedPokemonGraphicsLoader, implements a few pokemon as an example on how to make a mod using this framework. (This mod is intended for developers, see code)

**TO-DO:**
 - Finish gui
 - Allow overwriting only one field in pbs files.
 - Handle all pbs files
 - Implement ExtendedLearnsets
 - Change CreateAllFields into ExtraMoves

# ModLoader
[![Build Status](https://armisius.visualstudio.com/ModLoader/_apis/build/status/Tilation.LMP-Mod-Pack-with-modloader?branchName=main)](https://armisius.visualstudio.com/ModLoader/_build/latest?definitionId=5&branchName=main)

A simple modloader GUI to sort and toggle mods easily. Works from any folder (asks you where the game is) or you can drop it in the root folder of the game.
To toggle mods you can use the checkbox or after selecting a mod from the list, press `space` or `enter` to toggle it.

Requires:
- .Net Framework 3.5

## How to contribute

Contributions must be:
- On a separate branch named: `modloader/*` (automatic build & release only works with pull request in this manner)
- Detailed enough and markdown formatted if possible
