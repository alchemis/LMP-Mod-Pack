using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Drawing;
using System.IO;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;
using System.Windows.Forms;

namespace ModLoader
{
    public partial class ModLoader : Form
    {
        readonly List<Mod> modList = new List<Mod>();
        readonly BindingList<Mod> boundList;

        private string BasePath { get; set; } = "";
        private string ModsDirectory => Path.Combine(BasePath, "Data/Mods");
        private string LoadOrderFile => Path.Combine(BasePath, "Data/Mods/load_order.ini");
        private string MustCompileFile => Path.Combine(BasePath, "Data/Mods/mustcompile.ini");
        private Mod SelectedMod => listBox1.SelectedItem as Mod;
        
        private bool Updating { get; set; }

        public ModLoader()
        {
            InitializeComponent();
            labelDescription.MaximumSize = new Size(tableLayoutPanel2.Width, labelDescription.MaximumSize.Height);
            while(!Directory.Exists("./Data/Mods/") && !Directory.Exists(ModsDirectory))
            {
                var diag = new FolderBrowserDialog();
                diag.SelectedPath = Environment.CurrentDirectory;
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
                ReadLoadOrderFromFile();
                SortByLoadOrder();
            }
            else
            {
                SortByDefaultOrder();
            }

            UpdateUI();
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

        /// <summary>
        /// Should call <see cref="UpdateUI"/> after this.
        /// </summary>
        void SortByDefaultOrder()
        {
            modList.Sort((a,b) => a.DefaultLoadOrder.CompareTo(b.DefaultLoadOrder));
            modList.ForEach((x) => x.LoadOrder = modList.IndexOf(x));
        }

        /// <summary>
        /// Should call <see cref="UpdateUI"/> after this.
        /// </summary>
        void ReadLoadOrderFromFile()
        {
            SortByDefaultOrder();
            List<Mod> modsInFile = new List<Mod>();
            var lines = File.ReadAllLines(LoadOrderFile);
            int lastI = 0;
            for(int i = 0; i < lines.Length; i++)
            {
                var modname = lines[i].Trim();
                if (string.IsNullOrEmpty(modname)) continue;

                bool isEnabled = modname[0] != '!';

                if (!isEnabled) modname = new string(modname.Skip(1).ToArray());

                var mod = modList.FirstOrDefault(x=>x.ModName == modname);
                if (mod == null)
                {
                    MessageBox.Show($"The mod {mod} is missing.", "Modloader");
                    continue;
                }
                modsInFile.Add(mod);
                mod.LoadOrder = i;
                mod.Enabled = isEnabled;
                lastI = i;
            }        
        }

        void SortByLoadOrder()
        {
            modList.Sort((a, b) => a.LoadOrder.CompareTo(b.LoadOrder));
        }

        private void listBox1_SelectedIndexChanged(object sender, EventArgs e)
        {
            if (SelectedMod == null) return;
            labelDescription.Text = SelectedMod.ModDesc;
            groupBoxMod.Text = $"Mod: {SelectedMod.ModName}";
            checkBoxModEnabled.Checked = SelectedMod.Enabled;
            UpdateUI();
        }

        private void Form1_SizeChanged(object sender, EventArgs e)
        {
            labelDescription.MaximumSize = new Size(tableLayoutPanel2.Width,labelDescription.MaximumSize.Height);
        }

        private void checkBoxModEnabled_CheckedChanged(object sender, EventArgs e)
        {
            if (SelectedMod == null) return;
            SelectedMod.Enabled = checkBoxModEnabled.Checked;
            UpdateUI();
        }

        private void listBox1_KeyDown(object sender, KeyEventArgs e)
        {
            if (e.KeyCode == Keys.Space|| e.KeyCode == Keys.Enter)
            {
                if (SelectedMod == null) return;
                SelectedMod.Enabled = !SelectedMod.Enabled;
                checkBoxModEnabled.Checked = SelectedMod.Enabled;
                UpdateUI();
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

            UpdateUI();
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

            UpdateUI();
        }

        private void buttonSave_Click(object sender, EventArgs e)
        {
            SaveLoadOrderToDisk();
            UpdateUI();
        }

        private void SaveLoadOrderToDisk()
        {
            StringBuilder sb = new StringBuilder();
            for (int i = 0; i < modList.Count; i++)
            {
                var mod = modList[i];
                if (!mod.Enabled) sb.Append('!');
                sb.AppendLine(mod.ModName);
            }
            File.WriteAllText(LoadOrderFile, sb.ToString());

            if (checkBoxForceRecompile.Checked && File.Exists(MustCompileFile))
                File.Delete(MustCompileFile);

            MessageBox.Show($"{modList.Count(x => x.Enabled)} Mods are now enabled!", "Modloader");
        }

        private void buttonResetDefaults_Click(object sender, EventArgs e)
        {
            var result = MessageBox.Show("Are you sure you want to restore the default load order?", "Modloader", MessageBoxButtons.YesNo);
            if (result == DialogResult.No) return;

            var selected = SelectedMod;
            FindMods();
            SortByDefaultOrder();
            listBox1.SelectedItem = selected;

            UpdateUI();

            MessageBox.Show("Restored defaults, however, changes are not yet saved", "ModLoader");
        }

        void UpdateUI()
        {
            if (Updating) return;

            Updating = true;
            boundList.ResetBindings();
            checkBoxModEnabled.Checked = SelectedMod.Enabled;
            labelDescription.Text = SelectedMod.ModDesc;
            groupBoxMod.Text = $"Mod: {SelectedMod.ModName}";
            Updating = false;
        }
    }
}