# Welcome to LMP Mod Pack
This is a mod pack for **Pokémon Reborn.**
How to install:

 - Download the project zip and copy it into a working installation of Reborn,
 - Download the GUI from releases and put it in the same folder as Game.exe
 
 WARNING: The GUI .exe file has a false positive in virustotal, and windows defender will scan it, however the source code is avaliable and you may compile it yourself, instructions coming soon.
 
 
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

**TO-DO:**
 - Handle all pbs files
 - Handle maps and events :eyes:
 - Implement ExtendedLearnsets
 - Change CreateAllFields into ExtraMoves
