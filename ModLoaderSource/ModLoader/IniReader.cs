using System;
using System.IO;

namespace ModLoader
{
    public static class IniReader
    {
        public static IniResult Read(string filePath)
        {
            IniResult iniResult = new IniResult();
            var lines = File.ReadAllLines(filePath);
            for (int i = 0; i < lines.Length; i++)
            {
                var curatedLine = lines[i].Trim();
                if (curatedLine[0] == '#') continue;
                if (string.IsNullOrEmpty(curatedLine)) continue;

                if (curatedLine.IndexOf('=') != -1)
                {
                    var propertyName = curatedLine.Split('=')[0].Trim();
                    var propertyValue = curatedLine.Split('=')[1].Trim();

                    if (string.IsNullOrEmpty(propertyName)) throw new FormatException($"The property at: {i} is empty");

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
