using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Drawing;
using System.IO;
using System.Linq;
using System.Text.RegularExpressions;
using System.Windows.Forms;

namespace ModLoader
{
    public partial class ModLoader : Form
    {
        readonly List<Mod> modList = new List<Mod>();
        readonly BindingList<Mod> boundList;

        readonly List<string> errors = new List<string>();

        private string BasePath { get; set; } = "";
        private string ModsDirectory => Path.Combine(BasePath, "Data/Mods");
        private string LoadOrderFile => Path.Combine(BasePath, "Data/Mods/load_order.ini");
        private string MustCompileFile => Path.Combine(BasePath, "Data/Mods/mustcompile.ini");
        private Mod SelectedMod => listBox1.SelectedItem as Mod;
        
        public ModLoader()
        {
            InitializeComponent();
            labelDescription.MaximumSize = new Size(tableLayoutPanel2.Width, labelDescription.MaximumSize.Height);
            if (!Directory.Exists("./Data/Mods/"))
            {
                var diag = new FolderBrowserDialog();
                diag.Description = "Select the root folder for Pokemon Reborn, or move the mod loader's executable where the game is.";
                var result = diag.ShowDialog();
                if (result == DialogResult.OK)
                {
                    BasePath = diag.SelectedPath;
                }
                else
                {
                    Environment.Exit(1);
                }
            }

            FindMods();

            boundList = new BindingList<Mod>(modList);

            listBox1.DataSource = boundList;
            
            if (File.Exists(LoadOrderFile))
            {
                SortByLoadOrder();
            }
            boundList.ResetBindings();
        }

        void FindMods()
        {
            modList.Clear();

            var mod_settings_list = Directory.GetFiles(ModsDirectory, "mod_settings.ini", SearchOption.AllDirectories);

            foreach (string modIniFile in mod_settings_list)
            {
                string modname = new DirectoryInfo(modIniFile).Parent.Name;

                var customIni = IniReader.Read(modIniFile);

                Mod mod = new Mod
                {
                    PathToIni = modIniFile,
                    ModName = customIni.AsString("ModName"),
                    ModDesc = customIni.AsString("ModDesc"),
                    ModPBS = customIni.AsString("ModPBS").Split(',').ToList(),
                    DefaultLoadOrder = customIni.AsInt("defaultLoadOrder"),
                    Enabled = customIni.AsBool("enabled"),
                    ForceOverwriteAbilities = customIni.AsBool("forceOverwriteAbilities"),
                    HasScripts = customIni.AsBool("hasscripts"),
                    LoadOrder = modList.Count
                };

                if (mod.ModName != modname)
                {
                    MessageBox.Show($"Folder name {modname} and mod name {mod.ModName} in ini do not match", "Modloader");
                    continue;
                }

                modList.Add(mod);
            }
        }
        
        void DefaultSort()
        {
            FindMods();
            modList.Sort((a,b) => a.DefaultLoadOrder.CompareTo(b.DefaultLoadOrder));
            modList.ForEach((x) => x.LoadOrder = modList.IndexOf(x));
            boundList.ResetBindings();
        }


        void SortByLoadOrder()
        {
            // Only get lines with text
            var lines = File.ReadAllLines(LoadOrderFile).Select(x => x.Trim()).Where(x => !string.IsNullOrEmpty(x)).ToArray();

            for(int i = 0; i < lines.Length; i++)
            {
                var modname = lines[i];
                var mod = modList.FirstOrDefault(x=>x.ModName == modname);
                if (mod == null)
                {
                    MessageBox.Show($"The mod {mod} doesn't exist", "Modloader");
                    continue;
                }
                mod.LoadOrder = i;
            }
            modList.Sort((a, b) => a.LoadOrder.CompareTo(b.LoadOrder));
        }

        private void listBox1_SelectedIndexChanged(object sender, EventArgs e)
        {
            if (SelectedMod == null) return;
            labelDescription.Text = SelectedMod.ModDesc;
            groupBoxMod.Text = $"Mod: {SelectedMod.ModName}";
            checkBoxModEnabled.Checked = SelectedMod.Enabled;
        }

        private void Form1_SizeChanged(object sender, EventArgs e)
        {
            labelDescription.MaximumSize = new Size(tableLayoutPanel2.Width,labelDescription.MaximumSize.Height);
        }

        private void checkBoxModEnabled_CheckedChanged(object sender, EventArgs e)
        {
            if (SelectedMod == null) return;
            SelectedMod.Enabled = checkBoxModEnabled.Checked;
            boundList.ResetBindings();
        }

        private void listBox1_KeyDown(object sender, KeyEventArgs e)
        {
            if (e.KeyCode == Keys.Space|| e.KeyCode == Keys.Enter)
            {
                if (SelectedMod == null) return;
                SelectedMod.Enabled = !SelectedMod.Enabled;
                checkBoxModEnabled.Checked = SelectedMod.Enabled;
                boundList.ResetBindings();
            }
        }

        private void buttonMoveUp_Click(object sender, EventArgs e)
        {
            if (SelectedMod == null) return;
            var selected = SelectedMod;

            var previous = modList.FirstOrDefault(x => x.LoadOrder == selected.LoadOrder - 1);
            if (previous == null) return;
            var temp = previous.LoadOrder;
            previous.LoadOrder = SelectedMod.LoadOrder;
            SelectedMod.LoadOrder = temp;
            modList.Sort((a, b) => a.LoadOrder.CompareTo(b.LoadOrder));
            boundList.ResetBindings();
            listBox1.SelectedItem = selected;

        }

        private void buttonMoveDown_Click(object sender, EventArgs e)
        {
            if (SelectedMod == null) return;
            var selected = SelectedMod;
            var next = modList.FirstOrDefault(x => x.LoadOrder == selected.LoadOrder + 1);
            if (next == null) return;
            var temp = next.LoadOrder;
            next.LoadOrder = SelectedMod.LoadOrder;
            SelectedMod.LoadOrder = temp;
            modList.Sort((a, b) => a.LoadOrder.CompareTo(b.LoadOrder));
            boundList.ResetBindings();
            listBox1.SelectedItem = selected;
        }

        private void buttonSave_Click(object sender, EventArgs e)
        {
            foreach(var mod in modList)
            {
                var txt = File.ReadAllText(mod.PathToIni);
                var newTxt = Regex.Replace(txt, @"\benabled\s*=.*", $"enabled={mod.Enabled}".ToLower());
                File.WriteAllText(mod.PathToIni, newTxt);
            }
            File.WriteAllLines(LoadOrderFile, modList.Where(x=>x.Enabled == true).Select(x => x.ModName).ToArray());
            if (checkBoxForceRecompile.Checked && File.Exists(MustCompileFile)) File.Delete(MustCompileFile);

            MessageBox.Show($"{modList.Count(x=>x.Enabled)} Mods are now enabled!", "Modloader");
        }

        private void buttonResetDefaults_Click(object sender, EventArgs e)
        {
            var result = MessageBox.Show("Are you sure you want to restore the default load order?", "Modloader", MessageBoxButtons.YesNo);
            if (result == DialogResult.No) return;

            var selected = SelectedMod;
            DefaultSort();
            listBox1.SelectedItem = selected;
            boundList.ResetBindings();

            MessageBox.Show("Restored defaults, however, changes are not yet saved", "ModLoader");
        }
    }
}