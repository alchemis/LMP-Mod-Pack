
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;
using System.Threading.Tasks;

namespace ModManager
{
    public static class IniReader
    {


        public static Task<IniResult> Read(string filePath)
        {
            IniResult iniResult = new IniResult();
            Regex headerDetector = new Regex(@"\[(.*)\]");
            Regex commentExtractor = new Regex(@"['#;].*");
            var lines = File.ReadAllLines(filePath,Encoding.UTF8);
            

            string lastHeader = string.Empty;

            // Select ini lines which have text
            //var usefulLines = lines.Select(x => x.Trim()).Where(x => x.Length > 0).ToArray();

            for (int i = 0; i < lines.Length; i++)
            {
                var curatedLine = lines[i];
                if (commentExtractor.IsMatch(curatedLine))
                {
                    curatedLine = commentExtractor.Replace(curatedLine, "");
                }

                if (string.IsNullOrWhiteSpace(curatedLine)) continue;

                // Looks for a header and keeps it in memory until finding another
                if (headerDetector.IsMatch(curatedLine))
                {
                    lastHeader = headerDetector.Replace(curatedLine, "$1");

                }
                // If not a header, check if it has an =
                else if (curatedLine.Contains('='))
                {
                    // Split the line by = and remove whitespace
                    // On the left there's the key
                    // On the right there's the property
                    var propertyName = curatedLine.Split('=')[0].Trim();
                    var propertyValue = curatedLine.Split('=')[1].Trim();

                    if (string.IsNullOrWhiteSpace(lastHeader))
                    {
                        throw new FormatException($"la cabecera esta vacía en linea: {i}");
                    }
                    if (string.IsNullOrWhiteSpace(propertyName))
                    {
                        throw new FormatException($"la propiedad esta vacía en linea: {i}");
                    }

                    // Save the header, property and value (headers and properties
                    // that dont exist are automatically created)
                    iniResult.Set(lastHeader,propertyName,propertyValue);
                }
                else
                {
                    throw new FormatException($"line {i} of file {filePath} does not contain an = to split the value and the key .\nLine: {curatedLine}");
                }
            }

            return Task.FromResult(iniResult);
        }
    }
}
