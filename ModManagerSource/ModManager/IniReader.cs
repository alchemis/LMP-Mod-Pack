using System;
using System.IO;

namespace ModManager
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
                if (string.IsNullOrEmpty(curatedLine)) continue;
                if (curatedLine[0] == '#') continue;

                var parts = curatedLine.Split('=');

                if (parts.Length == 1) throw new FormatException($"The line {i} in the file {filePath} does not contains \"=\" \nLine: {curatedLine}");
                
                var propertyName = parts[0].Trim();

                if (string.IsNullOrEmpty(propertyName)) throw new FormatException($"The property at: {i} is empty");

                iniResult[propertyName] = parts[1].Trim();
            }
            return iniResult;
        }
    }
}
