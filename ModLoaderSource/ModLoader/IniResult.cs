using System;
using System.Collections.Generic;

namespace ModLoader
{
    public class IniResult
    {
        public const string ForcedHeader = "LMP";
        private readonly Dictionary<string, Dictionary<string, string>> Values;


        public IniResult()
        {
            Values = new Dictionary<string, Dictionary<string, string>>();
        }

        public string AsString(string property)
        {
            var lowerProperty = property.ToLower().Trim();
            if (!Values[ForcedHeader].ContainsKey(lowerProperty)) return string.Empty;
            return Values[ForcedHeader][lowerProperty];
        }

        public int AsInt(string property)
        {
            var lowerProperty = property.ToLower().Trim();
            if (!Values[ForcedHeader].ContainsKey(lowerProperty)) throw new FormatException($"Property {property} does not exists.");
            if (!int.TryParse(Values[ForcedHeader][lowerProperty], out int result)) throw new FormatException($"The property {property} is not an int.\nValue {Values[ForcedHeader][lowerProperty]}");
            return result;
        }

        public bool AsBool(string property)
        {
            var lowerProperty = property.ToLower().Trim();
            if (!Values[ForcedHeader].ContainsKey(lowerProperty)) return false;
            if (!bool.TryParse(Values[ForcedHeader][lowerProperty], out bool result)) return false;
            return result;
        }

        public string this[string property]
        {
            get
            {
                var lowerProperty = property.ToLower().Trim();
                if (!Values[ForcedHeader].ContainsKey(lowerProperty)) return string.Empty;
                return Values[ForcedHeader][lowerProperty];
            }
            set
            {
                var lowerProperty = property.ToLower().Trim();

                if (!Values.ContainsKey(ForcedHeader)) Values.Add(ForcedHeader, new Dictionary<string, string>());
                var properties = Values[ForcedHeader];
                if (!properties.ContainsKey(lowerProperty)) properties.Add(lowerProperty, "");
                properties[lowerProperty] = value;
            }
        }
    }
}
