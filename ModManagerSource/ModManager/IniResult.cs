using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ModManager
{
    public class IniResult
    {
        public IniResult()
        {
            Values = new List<IniProperty>();
        }


        public string AsString(string header, string property)
        {
            if (string.IsNullOrWhiteSpace(header) ||
                   string.IsNullOrWhiteSpace(property))
                throw new ArgumentException($"La cabecera {header}, o la propiedad {property}, estan en blanco.");

            var lowerHead = header.ToLower().Trim();
            var lowerProperty = property.ToLower().Trim();
            if (!Values.ContainsKey(lowerHead))
            {
                //Logger.LogInfo($"La llave {lowerHead} no existe.");
                return string.Empty;
            }
            if (!Values[lowerHead].ContainsKey(lowerProperty)) return string.Empty;

            return Values[lowerHead][lowerProperty];
        }


        internal bool IsHeaderPresent(string header)
        {
            if (string.IsNullOrWhiteSpace(header)) throw new ArgumentException($"La cabecera {header}, esta en blanco.");
            var lowerHead = header.ToLower().Trim();
            return Values.ContainsKey(lowerHead);
        }

        public int AsInt(string header, string property, int defaultvalue = 0)
        {
            if (string.IsNullOrWhiteSpace(header) ||
                   string.IsNullOrWhiteSpace(property))
                throw new ArgumentException($"La cabecera {header}, o la propiedad {property}, estan en blanco.");

            var lowerHead = header.ToLower().Trim();
            var lowerProperty = property.ToLower().Trim();
            if (!Values.ContainsKey(lowerHead))
            {
                //Logger.LogInfo($"La llave {lowerHead} no existe.");
                return defaultvalue;
            }
            if (!Values[lowerHead].ContainsKey(lowerProperty)) return defaultvalue;

            if (!int.TryParse(Values[lowerHead][lowerProperty], out int result))
            {
                throw new FormatException($"El header {header} y propiedad {property} no tienen un valor convertible a int. Valor {Values[lowerHead][lowerProperty]}");
            }
            return result;
        }
        public List<string> AsList(string header,string property,char separator)
        {
            var list = new List<string>();
            if (string.IsNullOrWhiteSpace(header) || string.IsNullOrWhiteSpace(property))
                throw new ArgumentException($"La cabecera {header}, o la propiedad {property}, estan en blanco.");

            var lowerHead = header.ToLower().Trim();
            var lowerProperty = property.ToLower().Trim();
            if (!Values.ContainsKey(lowerHead))
            {
                //Logger.LogInfo($"La llave {lowerHead} no existe.");
                return list;
            }
            if (!Values[lowerHead].ContainsKey(lowerProperty)) return list;

            list.AddRange(Values[lowerHead][lowerProperty].Split(separator));
            return list;
        }

        public string this[string header, string property]
        {
            get
            {
                if (string.IsNullOrWhiteSpace(header) ||
                    string.IsNullOrWhiteSpace(property))
                    throw new ArgumentException($"La cabecera {header}, o la propiedad {property}, estan en blanco.");

                var lowerHead = header.ToLower().Trim();
                var lowerProperty = property.ToLower().Trim();
                if (!Values.ContainsKey(lowerHead))
                {
                    //Logger.LogInfo($"La llave {lowerHead} no existe.");
                    return string.Empty;
                }
                if (!Values[lowerHead].ContainsKey(lowerProperty)) return string.Empty;
                return Values[lowerHead][lowerProperty];
            }
            set
            {
                if (string.IsNullOrWhiteSpace(header) ||
                    string.IsNullOrWhiteSpace(property))
                    throw new ArgumentException($"La cabecera {header}, o la propiedad {property}, estan en blanco.");

                var lowerHead = header.ToLower().Trim();
                var lowerProperty = property.ToLower().Trim();

                if (!Values.ContainsKey(lowerHead)) Values.Add(lowerHead, new Dictionary<string, string>());
                var properties = Values[lowerHead];
                if (!properties.ContainsKey(lowerProperty)) properties.Add(lowerProperty, "");
                properties[lowerProperty] = value;
            }
        }

        private readonly List<IniProperty> Values;

        /// <summary>
        /// 
        /// </summary>
        /// <returns>Si no existe, devuelve un array de 0 elementos.</returns>
        public string[] GetHeaders()
        {
            if (Values.Keys.Count == 0) return new string[0];
            return Values.Keys.ToArray();
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="header"></param>
        /// <returns>Si no existe, devuelve un array de 0 elementos.</returns>
        public string[] GetPropertyNames(string header)
        {
            if (!Values.ContainsKey(header)) return new string[0];
            return Values[header].Keys.ToArray();
        }

        /// <summary>
        /// Devuelve el valor de la propiedad, si existe.
        /// </summary>
        /// <param name="header">La cabecera del ini, delimitada por [].</param>
        /// <param name="property">El nombre de la propiedad que se quiere obtener el valor.</param>
        /// <returns>Si no existe el header o property, <see cref="string.Empty"/></returns>
        public string GetPropertyValue(string header, string property)
        {
            if (Values.Keys.Count == 0) return string.Empty;
            if (!Values.ContainsKey(header)) return string.Empty;
            if (!Values[header].ContainsKey(property)) return string.Empty;
            return Values[header][property];
        }
    }
}
