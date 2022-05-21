
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

            // Se seleccionan las lineas del ini que tienen texto
            //var usefulLines = lines.Select(x => x.Trim()).Where(x => x.Length > 0).ToArray();

            for (int i = 0; i < lines.Length; i++)
            {
                var curatedLine = lines[i];
                if (commentExtractor.IsMatch(curatedLine))
                {
                    curatedLine = commentExtractor.Replace(curatedLine, "");
                }

                if (string.IsNullOrWhiteSpace(curatedLine)) continue;

                // Busqueda de headers, y lo mantiene en memoria hasta encontrar otro
                if (headerDetector.IsMatch(curatedLine))
                {
                    lastHeader = headerDetector.Replace(curatedLine, "$1");
                }
                // Si no es header, me fijo si tiene un =, que define que es una propiedad
                else if (curatedLine.Contains('='))
                {
                    // Divido la linea por el = y quito los espacios en blanco
                    // De la izquierda del = es el nombre de la propiedad
                    // De la derecha del = es el valor de la propiedad
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

                    // Guardo el header, el nombre de la propiedad y su valor (se crean automaticamente los
                    // headers y propiedades si en la coleccion no existen)
                    iniResult[lastHeader, propertyName] = propertyValue;
                }
                else
                {
                    throw new FormatException($"La linea {i} del archivo {filePath} no contiene un simbolo = que delimite el nombre de la propiedad y su valor.\nLinea: {curatedLine}");
                }
            }

            return Task.FromResult(iniResult);
        }
    }
}
