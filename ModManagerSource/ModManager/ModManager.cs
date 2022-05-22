using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Drawing;
using System.IO;
using System.Linq;
using System.Text;
using Newtonsoft.Json;
using System.Text.RegularExpressions;
using System.Windows.Forms;
using System.Diagnostics;

namespace ModManager
{
    public partial class ModManager : Form
    {
        readonly List<Mod> modList = new List<Mod>();
        readonly List<Mod> loadOrder = new List<Mod>();
        readonly List<Mod> disabledMods = new List<Mod>();
        readonly BindingList<Mod> boundList;

        private string BasePath { get; set; } = "";
        private string ModsDirectory => Path.Combine(BasePath, "Data/Mods");
        private string SettingsFile => Path.Combine(BasePath, "Data/Mods/Modloader/modloader_settings.json");
        private ModManagerSettings Settings;
        private BindingList<Mod> boundListDisabled;

        private Mod SelectedEnabledMod => enabledListBox.SelectedItem as Mod;
        private Mod SelectedDisabledMod => disabledListBox.SelectedItem as Mod;
        private bool Updating { get; set; }
        private bool ClickedAdvanced { get; set; }= false;

        public ModManager()
        {
        
            InitializeComponent();
            labelDescription.MaximumSize = new Size(tableLayoutPanel2.Width, labelDescription.MaximumSize.Height);
            

            
            while (!Directory.Exists("./Data/Mods/") && !Directory.Exists(ModsDirectory))
            {
                var diag = new FolderBrowserDialog();
                diag.SelectedPath = Environment.CurrentDirectory;
                diag.Description = "Select the root folder for Pokemon Reborn, or move the mod loader's executable to where the game is.";
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
            Settings = GetModManagerSettings(SettingsFile);
            FindMods();

            if (File.Exists(SettingsFile))
            {
                GetLoadOrder();
            }
            else
            {
                SortByDefaultOrder();
            }
            boundList = new BindingList<Mod>(loadOrder);
            enabledListBox.DataSource = boundList;
            boundListDisabled = new BindingList<Mod>(disabledMods);
            disabledListBox.DataSource = boundListDisabled;
            UpdateUI();
        }



        async void FindMods()
        {
            modList.Clear();

            var mod_settings_list = Directory.GetFiles(ModsDirectory, "mod_settings.ini", SearchOption.AllDirectories);

            foreach (string modIniFile in mod_settings_list)
            {
                string modname = new DirectoryInfo(modIniFile).Parent.Name;

                var customIni = await IniReader.Read(modIniFile);
                Mod mod = new Mod();
                mod.PathToIni = modIniFile;
                foreach (var x in customIni)
                {
                    ModSetting setting = new ModSetting();
                    setting.Key = x.PropertyName;
                    setting.Value = x.Value;
                    if (x.Header == "settings")
                    {
                        mod.ModSettingsList.Add(setting);
                    }
                    else if (x.Header == "custom_settings")
                    {
                        mod.CustomModSettingsList.Add(setting);
                    }

                }
                mod.ini_result = customIni;
                if (mod.ModName != modname)
                {
                    MessageBox.Show($"Folder name {modname} and mod name {mod.ModName} in ini do not match", "ModManager");
                    continue;
                }

                modList.Add(mod);
            }
        }

        void GetLoadOrder()
        {

            var modOrder = Settings.loadOrder;
            List<Mod> temp = new List<Mod>();
            foreach (string modname in modOrder.ToArray())
            {
                var mod = modList.FirstOrDefault(x => x.ModName == modname);
                if(mod == null) continue;
                temp.Add(mod);
            }
            loadOrder.Clear();
            loadOrder.AddRange(temp);
            disabledMods.Clear();
            disabledMods.AddRange(modList.Where(x => !loadOrder.Contains(x)));
        }

        /// <summary>
        /// Should call <see cref="UpdateUI"/> after this.
        /// </summary>
        void SortByDefaultOrder()
        {
            loadOrder.Sort((a,b) => a.DefaultLoadOrder.CompareTo(b.DefaultLoadOrder));
            foreach(var group in loadOrder.GroupBy(x=>x.DefaultLoadOrder))
            {
                int count = group.Count();
                if (count <= 1) continue;
                var lowestIndex = group.Min(x => loadOrder.IndexOf(x));

                loadOrder.Sort(lowestIndex, count, Comparer<Mod>.Default);
            }    

        }
        private ModManagerSettings GetModManagerSettings(string path)
        {
            string jsonString = File.ReadAllText(path);
            ModManagerSettings settings = JsonConvert.DeserializeObject<ModManagerSettings>(jsonString);
            return settings;
        }
 




        private void listBox1_SelectedIndexChanged(object sender, EventArgs e)
        {
            var list = (ListBox)sender;
            var selecteditem = (Mod)list.SelectedItem;
            if (selecteditem == null) return;
            if (boundListDisabled == null) return;
            if (list == enabledListBox) disabledListBox.SelectedIndex = -1;
            else enabledListBox.SelectedIndex = -1;
            UpdateUI(selecteditem);
        }


        private void Form1_SizeChanged(object sender, EventArgs e)
        {
            labelDescription.MaximumSize = new Size(tableLayoutPanel2.Width,labelDescription.MaximumSize.Height);
        }





        private void buttonMoveUp_Click(object sender, EventArgs e)
        {
            if (SelectedEnabledMod == null) return;
            var selected = SelectedEnabledMod;
            var index = loadOrder.IndexOf(selected);
            if(index == 0) return;
            (loadOrder[index], loadOrder[index-1]) = (loadOrder[index-1], loadOrder[index]);
            UpdateUI();
        }

        private void buttonMoveDown_Click(object sender, EventArgs e)
        {
            if (SelectedEnabledMod == null) return;
            var selected = SelectedEnabledMod;
            var index = loadOrder.IndexOf(selected);
            if (index == loadOrder.Count -1) return;
            (loadOrder[index], loadOrder[index + 1]) = (loadOrder[index + 1], loadOrder[index]);
            UpdateUI();
        }

        private void buttonSave_Click(object sender, EventArgs e)
        {
            SaveLoadOrderToDisk();
            UpdateUI();
        }

        private void SaveLoadOrderToDisk()
        {
            List<string> new_load_order = new List<string>();
            foreach (var mod in loadOrder)
            {
                new_load_order.Add(mod.ModName);
            }

            
            foreach (var mod in modList)
            {
                IniWriter.Write(mod.PathToIni, mod.ini_result);
            }
            Settings.loadOrder = new_load_order;
            File.WriteAllText(SettingsFile, JsonConvert.SerializeObject(Settings,Formatting.Indented));


            
            MessageBox.Show($"{loadOrder.Count} Mods are now enabled!", "ModManager");
        }

        private void ResetDefaults_Click(object sender, EventArgs e)
        {
            var result = MessageBox.Show("Are you sure you want to restore the default load order?", "ModManager", MessageBoxButtons.YesNo);
            if (result == DialogResult.No) return;

            var selected = SelectedEnabledMod;
            SortByDefaultOrder();
            enabledListBox.SelectedItem = selected;

            UpdateUI();

            MessageBox.Show("Restored defaults, however, changes are not yet saved", "ModManager");
        }

        void UpdateUI(Mod selectedmod = null)
        {
            if (Updating) return;

            Updating = true;
            var selected = SelectedEnabledMod;

            var selecteddisabled = SelectedDisabledMod;
            boundList.ResetBindings();
            boundListDisabled.ResetBindings();

            if (Settings.settings.recompile == "true") {
                forceRecompileToolStripMenuItem.Checked = true;
                    }
            if (Settings.settings.debug == "true")
            {
                debugMessagesToolStripMenuItem.Checked = true;
            }
            enabledListBox.SelectedItem = selected;
            disabledListBox.SelectedItem = selecteddisabled;
            if (selectedmod == null)
            {
                labelDescription.Text = SelectedEnabledMod?.ModDesc ?? "";
                groupBoxMod.Text = $"Mod: {SelectedEnabledMod?.ModName ?? ""}";
            }
            else
            {
                labelDescription.Text = selectedmod.ModDesc;
                groupBoxMod.Text = selectedmod.ModName;
                dgwModAdvSettings.DataSource = null;
                dgwModSettings.DataSource = null;
                dgwModAdvSettings.DataSource = selectedmod.ini_result.Where(x => x.Header=="settings").ToArray();
                dgwModSettings.DataSource = selectedmod.ini_result.Where(x => x.Header == "custom_settings").ToArray();
                dgwModSettings.Visible = dgwModSettings.Rows.Count > 0;
                labelNoSettings.Visible = !(dgwModSettings.Rows.Count > 0);
                dgwModSettings.Columns["header"].Visible = false;
                dgwModAdvSettings.Columns["header"].Visible = false;
                dgwModAdvSettings.Columns["PropertyName"].ReadOnly = true;
                dgwModSettings.Columns["PropertyName"].ReadOnly = true;
            }
            Updating = false;
        }

        private void clickedCheckableToolStripMenuItem(object sender, EventArgs e)
        {
            var menuItem = sender as ToolStripMenuItem;
            menuItem.Checked = !menuItem.Checked;
            if ((string)menuItem.Tag == "debug")
            {
                Settings.settings.debug = menuItem.Checked.ToString().ToLower();
            }
            else if ((string)menuItem.Tag == "recompile")
            {
                Settings.settings.recompile = menuItem.Checked.ToString().ToLower();
            }
            
        }

        private void buttonEnable_Click(object sender, EventArgs e)
        {
            var selected = SelectedDisabledMod;
            if (selected == null) return;
            disabledMods.Remove(selected);
            loadOrder.Add(selected);
            UpdateUI();
        }

        private void buttonDisable_Click(object sender, EventArgs e)
        {
            var selected = SelectedEnabledMod;
            if (selected == null) return;
            loadOrder.Remove(selected);
            disabledMods.Add(selected);
            UpdateUI();
        }

        private void buttonRun_Click(object sender, EventArgs e)
        {
            SaveLoadOrderToDisk();
            if (Settings.settings.debug == "true")
            {
                Process.Start(Path.Combine(BasePath, "Game.exe"), "debug");
            }
            else Process.Start(Path.Combine(BasePath,"Game.exe"));

        }

        private void advancedSettings_Click(object sender, TabControlEventArgs e)
        {
            var source = (TabControl)sender;
            if (!ClickedAdvanced && source.SelectedIndex == 2)
            {
                MessageBox.Show("Warning! These settings might break the mod. \n It is not recommended to change them.", "ModManager");
                ClickedAdvanced = true;
            }
        }
    }
}