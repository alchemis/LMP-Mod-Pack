using System.Collections.Generic;

namespace ModLoader
{
    internal class Mod
    {
        public override string ToString()
        {
            return $"{(Enabled ? "✅" : "❌")} {ModName}";
        }
        public string PathToIni { get; set; }
        public string ModName { get; set; }
        public string ModDesc { get; set; }

        /// <summary>
        /// Which files to load from the mod directory/PBS, currently only pokemon, moves, items, tms and abilities are supported. comma separated list.
        /// </summary>
        public List<string> ModPBS { get; set; }

        /// <summary>
        /// #this line decides whether to append tms to the existing list (define only the pokemon that you want to add or remove from each tm in the tms.txt if so),
        ///<para>use !INTERNALID to remove and INTENALID to add a pokemon to a tm</para>
        ///<para>if this is true just use a normal tms.txt, in that case you must include the compatibility list for ALL pokemon,</para>
        ///<para>only use this when making a big content mod (for example updating all the tms to gen 8), and defaultLoadOrder should also be set to 1 for best results</para>
        /// </summary>
        public bool ForceOverwriteAbilities { get; set; }

        /// <summary>
        /// Whether the mod has scripts, true = load all .rb files inside the mod folder or false (or anything else) = don't load any .rb files
        /// </summary>
        public bool HasScripts { get; set; }
        public int LoadOrder { get; set; }

        /// <summary>
        /// The default order in which to load mods, 1=pre, 2=main, 3=post
        /// <para> Big content mods should generally use 0, small mods should use 1 and mods that mod other mods should use 2 </para>
        /// </summary>
        public int DefaultLoadOrder { get; set; }
        public bool Enabled { get; set; }
    }
}
