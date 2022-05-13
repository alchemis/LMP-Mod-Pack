using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;

namespace ModLoader
{
    public static class IniReader
    {
        public static IniResult Read(string filePath)
        {
            IniResult iniResult = new IniResult();
            Regex headerDetector = new Regex(@"\[(.*)\]");
            Regex commentExtractor = new Regex(@"[#].*");
            var lines = File.ReadAllLines(filePath, Encoding.UTF8);
            int startPos = 0;

            string lastHeader = string.Empty;

            for (int i = startPos; i < lines.Length; i++)
            {
                var curatedLine = lines[i];
                if (commentExtractor.IsMatch(curatedLine))
                {
                    curatedLine = commentExtractor.Replace(curatedLine, "").Trim();
                }

                if (string.IsNullOrEmpty(curatedLine)) continue;

                if (curatedLine.Contains('='))
                {
                    var propertyName = curatedLine.Split('=')[0].Trim();
                    var propertyValue = curatedLine.Split('=')[1].Trim();

                    if (string.IsNullOrEmpty(propertyName))
                    {
                        throw new FormatException($"The property at: {i} is empty");
                    }

                    iniResult[propertyName] = propertyValue;
                }
                else
                {
                    throw new FormatException($"The line {i} in the file {filePath} does not contains \"=\" \nLine: {curatedLine}");
                }
            }

            return iniResult;
        }
    }
}
