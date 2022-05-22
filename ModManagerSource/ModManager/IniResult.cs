using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;

namespace ModManager
{
    public class IniResult : IEnumerable<IniProperty>
    {
        private readonly List<IniProperty> Values;

        public IniResult()
        {
            Values = new List<IniProperty>();
        }

        public bool ContainsHeader(string header)
        {
            return Values.Any(x => x.Header == header);
        }

        public bool ContainsProperty(string header, string property)
        {
            var asd = Values.Where(x => x.Header == header).ToArray();
            if (asd.Length == 0) return false;

            return asd.Any(x => x.PropertyName == property);
        }

        public void RemoveHeader(string header)
        {
            Values.RemoveAll(x => x.Header == header.ToLower());
        }

        public void RemoveProperty(string header, string property)
        {
            Values.RemoveAll(x => x.Header == header.ToLower() && x.PropertyName == property.ToLower());
        }

        public void Set(string header, string property, string value)
        {
            string h = header.ToLower();
            string p = property.ToLower();
            var val = Get(header, property);
            if (val == null) val = new IniProperty { Header = h, PropertyName = p };
            val.Value = value;
            Values.Add(val);
        }

        public IniProperty Get(string header, string property)
        {
            return Values.FirstOrDefault(x => x.Header == header && x.PropertyName == property);
        }

        public string AsString(string header, string property)
        {
            if (string.IsNullOrWhiteSpace(header) || string.IsNullOrWhiteSpace(property))
                throw new ArgumentException($"La cabecera {header}, o la propiedad {property}, estan en blanco.");

            var lowerHead = header.ToLower().Trim();
            var lowerProperty = property.ToLower().Trim();

            var val = Get(lowerHead, lowerProperty);
            return val?.Value ?? string.Empty;
        }

        public bool AsBool(string header, string property)
        {
            if (string.IsNullOrWhiteSpace(header) || string.IsNullOrWhiteSpace(property))
                throw new ArgumentException($"La cabecera {header}, o la propiedad {property}, estan en blanco.");

            var lowerHead = header.ToLower().Trim();
            var lowerProperty = property.ToLower().Trim();

            var val = Get(lowerHead, lowerProperty);

            return Convert.ToBoolean(val.Value);
        }

        public int AsInt(string header, string property, int defaultvalue = 0)
        {
            if (string.IsNullOrWhiteSpace(header) || string.IsNullOrWhiteSpace(property))
                throw new ArgumentException($"La cabecera {header}, o la propiedad {property}, estan en blanco.");

            var lowerHead = header.ToLower().Trim();
            var lowerProperty = property.ToLower().Trim();

            var val = Get(lowerHead, lowerProperty);

            if (val == null) return defaultvalue;
            if (!int.TryParse(Get(lowerHead, lowerProperty).Value, out int result))
            {
                throw new FormatException($"El header {header} y propiedad {property} no tienen un valor convertible a int. Valor {Get(lowerHead, lowerProperty).Value}");
            }
            else
            {
                result = defaultvalue;
            }
            return result;
        }

        public List<string> AsList(string header, string property, char separator)
        {
            if (string.IsNullOrWhiteSpace(header) || string.IsNullOrWhiteSpace(property))
                throw new ArgumentException($"La cabecera {header}, o la propiedad {property}, estan en blanco.");

            var lowerHead = header.ToLower().Trim();
            var lowerProperty = property.ToLower().Trim();

            var val = Get(lowerHead, lowerProperty);

            var list = new List<string>();
            if (val == null) return list;

            list.AddRange(Get(lowerHead, lowerProperty).Value.Split(separator));
            return list;
        }

        public string[] GetHeaders()
        {
            return Values.Select(x => x.Header).ToArray();
        }

        public string[] GetPropertyNames(string header)
        {
            return Values.Where(x => x.Header == header.ToLower()).Select(x => x.PropertyName).ToArray();
        }

        public IEnumerator<IniProperty> GetEnumerator()
        {
            return Values.GetEnumerator();
        }

        IEnumerator IEnumerable.GetEnumerator()
        {
            return Values.GetEnumerator();
        }
    }
}
