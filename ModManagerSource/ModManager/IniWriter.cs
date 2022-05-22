
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;
using System.Threading.Tasks;

namespace ModManager
{
    public static class IniWriter
    {
        private static readonly char[] CommentCharacters = new[] { '#', '\'', ';' };

        public static void Write(string file, IniResult data, bool commentInsteadOfDelete = true)
        {
            string currentHeader = "";

            var original = File.ReadAllLines(file);

            var lines = original.ToList();

            int totalLines = lines.Count;

            List<IniProperty> propertyStack = data.ToList();

            List<IniProperty> properties = new List<IniProperty>();

            for (int i = 0; i < totalLines; i++)
            {
                var line = lines[i].Trim();
                var startingChar = line[0];

                if (string.IsNullOrEmpty(line)) continue;
                if (CommentCharacters.Contains(startingChar)) continue;
                if (startingChar == '[')
                {
                    if (properties.Count > 0)
                    {
                        foreach(var prop in properties)
                        {
                            lines.Insert(i, $"{prop.PropertyName}={prop.Value}");
                            propertyStack.Remove(prop);
                        }
                        totalLines = lines.Count;
                        i += properties.Count;
                    }
                    currentHeader = line.TrimStart('[');
                    currentHeader = currentHeader.TrimEnd(']').ToLower();
                    properties.Clear();
                    properties.AddRange(data.Where(x => x.Header == currentHeader));
                    continue;
                }
                if (!line.Contains('=')) continue;

                var parts = line.Split('=');
                string currentPropertyName = parts[0].Trim().ToLower();
                string currentPropertyValue = parts[1].Trim();

                var property = properties.FirstOrDefault(x => x.PropertyName == currentPropertyName);
                if (property == null)
                {
                    if (commentInsteadOfDelete)
                    {
                        lines[i] = $"#{line}";
                        continue;
                    }
                    else
                    {
                        lines.RemoveAt(i);
                        totalLines = lines.Count;
                        i--;
                        continue;
                    }
                }
                properties.Remove(property);
                propertyStack.Remove(property);
                lines[i] = line.Replace(currentPropertyValue, property.Value);
            }

            // Write new properties and headers
            if (propertyStack.Count > 0)
            {
                /* Group by header, this returns:
                 *  Header1:
                 *          -prop1
                 *          -prop2
                 *          -prop3
                 *  Header2:
                 *          -prop1
                 *          -prop2
                 *  [etc]
                 */
                var groups = propertyStack.GroupBy(x => x.Header);

                // Iterate each header
                foreach(var props in groups)
                {
                    lines.Add($"[{props.Key}]");

                    // Iterate each property of the header
                    foreach(var prop in props)
                    {
                        lines.Add($"{prop.PropertyName}={prop.Value}");
                    }
                }
            }
            File.WriteAllLines(file, lines);
        }
    }
}
