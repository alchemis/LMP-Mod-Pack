# Welcome to LMP Mod Pack
This is a mod pack for **Pokémon Reborn.**
How to install:

 - Download the latest release and extract it into a working installation of Reborn.
 
 WARNING: The GUI .exe file has a false positive in virustotal, and Windows Defender will scan it upon launch (and find nothing wrong with it), the source code is avaliable and you may compile it yourself, instructions coming soon.
 
 
**Dependencies**:
 - **LMPModloader**: depends on **LMP - ModdedPokemonGraphicsLoader** and **LMPModcompiler**
 - **All LMP Mods**: depend on **LMPModloader**

**What the mods do:**
 - **LMP - FastHatch:** Skips the animation when hatching eggs, if **AMB - AddOpt** is installed it adds a toggle in the menu.
 - **LMPModloader:** Loads Pokémon, abilities and moves from dat files in Mods folder at runtime, does absolutely nothing on its own.
 - **LMPModCompiler:** Compiles PBS files in mods folder and data from vanilla into new .dat files in Mods folder, only runs if Mods/mustcompile.ini doesn't exist.
 - **LMP - ModdedPokemonGraphicsLoader:** Loads Pókemon graphics from Mods folder at runtime, does nothing on its own.
 - **LMP - CreateAllFields:** Allows most fields to be created with a move, like Misty Terrain. These moves are signature moves of otherwise subpar Pokémon. (See list in uhhh i'll make it sometime)
 - **LMP - ExampleMod:** Using ModdedPBSLoader and ModdedPokemonGraphicsLoader, implements a few pokemon as an example on how to make a mod using this framework. (This mod is intended for developers, see code)
 - **LMP - ExampleSelectiveOverwriteMod:** Showcases the selectiveOverwrite setting, to overwrite only some Pokemon data, for example, only edit moves, or overwrite mod pokemon if they exist.

**TO-DO:**
 - Handle all pbs files
 - Handle maps and events :eyes:
 - Implement ExtendedLearnsets
 - Change CreateAllFields into ExtraMoves

# ModLoader

**Coming soon!**
[![Build Status](https://dev.azure.com/lyraLMP/LMP-Modloader/_apis/build/status/alchemis.LMP-Mod-Pack?branchName=main)](https://dev.azure.com/lyraLMP/LMP-Modloader/_build/latest?definitionId=1&branchName=main)

A simple modloader GUI to sort and toggle LMP mods easily. Works from any folder (asks you where the game is) or you can drop it in the root folder of the game.
To toggle mods you can use the checkbox or after selecting a mod from the list, press `space` or `enter` to toggle it.

Requires:
- .Net Framework 3.5

## How to contribute

Contributions must be:
- On a separate branch named: `modloader/*`
- Detailed enough and markdown formatted if possible
- Automatic build & release works only with changes inside the `ModLoaderSource` folder
