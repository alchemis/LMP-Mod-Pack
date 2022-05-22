
using System.Collections.Generic;

namespace ModManager
{
    public class ModManagerSettings
    {
        public Settings settings { get; set; }
        public List<string> loadOrder { get; set; }
    }

    public class Settings
    {
        public string recompile { get; set; }
        public string debug { get; set; }
    }
}