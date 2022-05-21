using System.Windows.Forms;

namespace ModManager
{
    partial class ModManager
    {
        /// <summary>
        ///  Required designer variable.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary>
        ///  Clean up any resources being used.
        /// </summary>
        /// <param name="disposing">true if managed resources should be disposed; otherwise, false.</param>
        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        #region Windows Form Designer generated code

        /// <summary>
        ///  Required method for Designer support - do not modify
        ///  the contents of this method with the code editor.
        /// </summary>
        private void InitializeComponent()
        {
            this.tableLayoutPanel1 = new System.Windows.Forms.TableLayoutPanel();
            this.groupBox1 = new System.Windows.Forms.GroupBox();
            this.listBox1 = new System.Windows.Forms.ListBox();
            this.groupBoxMod = new System.Windows.Forms.GroupBox();
            this.tableLayoutPanel2 = new System.Windows.Forms.TableLayoutPanel();
            this.buttonMoveUp = new System.Windows.Forms.Button();
            this.buttonMoveDown = new System.Windows.Forms.Button();
            this.checkBoxModEnabled = new System.Windows.Forms.CheckBox();
            this.checkBoxForceRecompile = new System.Windows.Forms.CheckBox();
            this.buttonSave = new System.Windows.Forms.Button();
            this.buttonResetDefaults = new System.Windows.Forms.Button();
            this.menuStrip1 = new System.Windows.Forms.MenuStrip();
            this.toolStripMenuItem1 = new System.Windows.Forms.ToolStripMenuItem();
            this.forceRecompileToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.loadModToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.forceRecompileToolStripMenuItem1 = new System.Windows.Forms.ToolStripMenuItem();
            this.debugMessagesToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.uninstallModloaderToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.cleanUpSavesToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.toolStripSeparator1 = new System.Windows.Forms.ToolStripSeparator();
            this.debugOptionsToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.dangerousThingsToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.tabControl1 = new System.Windows.Forms.TabControl();
            this.tabPage2 = new System.Windows.Forms.TabPage();
            this.tabPage3 = new System.Windows.Forms.TabPage();
            this.dgwModAdvSettings = new System.Windows.Forms.DataGridView();
            this.tabPage1 = new System.Windows.Forms.TabPage();
            this.labelDescription = new System.Windows.Forms.Label();
            this.dgwModSettings = new System.Windows.Forms.DataGridView();
            this.tableLayoutPanel1.SuspendLayout();
            this.groupBox1.SuspendLayout();
            this.groupBoxMod.SuspendLayout();
            this.tableLayoutPanel2.SuspendLayout();
            this.menuStrip1.SuspendLayout();
            this.tabControl1.SuspendLayout();
            this.tabPage2.SuspendLayout();
            this.tabPage3.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.dgwModAdvSettings)).BeginInit();
            this.tabPage1.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.dgwModSettings)).BeginInit();
            this.SuspendLayout();
            // 
            // tableLayoutPanel1
            // 
            this.tableLayoutPanel1.ColumnCount = 3;
            this.tableLayoutPanel1.ColumnStyles.Add(new System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType.Percent, 50F));
            this.tableLayoutPanel1.ColumnStyles.Add(new System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType.Percent, 50.00001F));
            this.tableLayoutPanel1.ColumnStyles.Add(new System.Windows.Forms.ColumnStyle());
            this.tableLayoutPanel1.Controls.Add(this.groupBox1, 0, 0);
            this.tableLayoutPanel1.Controls.Add(this.groupBoxMod, 1, 0);
            this.tableLayoutPanel1.Controls.Add(this.checkBoxForceRecompile, 1, 2);
            this.tableLayoutPanel1.Controls.Add(this.buttonSave, 2, 2);
            this.tableLayoutPanel1.Controls.Add(this.buttonResetDefaults, 1, 1);
            this.tableLayoutPanel1.Dock = System.Windows.Forms.DockStyle.Fill;
            this.tableLayoutPanel1.Location = new System.Drawing.Point(0, 24);
            this.tableLayoutPanel1.Name = "tableLayoutPanel1";
            this.tableLayoutPanel1.RowCount = 4;
            this.tableLayoutPanel1.RowStyles.Add(new System.Windows.Forms.RowStyle());
            this.tableLayoutPanel1.RowStyles.Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType.Percent, 100F));
            this.tableLayoutPanel1.RowStyles.Add(new System.Windows.Forms.RowStyle());
            this.tableLayoutPanel1.RowStyles.Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType.Absolute, 20F));
            this.tableLayoutPanel1.Size = new System.Drawing.Size(404, 357);
            this.tableLayoutPanel1.TabIndex = 0;
            // 
            // groupBox1
            // 
            this.groupBox1.Controls.Add(this.listBox1);
            this.groupBox1.Dock = System.Windows.Forms.DockStyle.Fill;
            this.groupBox1.Location = new System.Drawing.Point(3, 3);
            this.groupBox1.Name = "groupBox1";
            this.tableLayoutPanel1.SetRowSpan(this.groupBox1, 3);
            this.groupBox1.Size = new System.Drawing.Size(160, 331);
            this.groupBox1.TabIndex = 0;
            this.groupBox1.TabStop = false;
            this.groupBox1.Text = "Load Order";
            // 
            // listBox1
            // 
            this.listBox1.Dock = System.Windows.Forms.DockStyle.Fill;
            this.listBox1.FormattingEnabled = true;
            this.listBox1.Location = new System.Drawing.Point(3, 16);
            this.listBox1.Name = "listBox1";
            this.listBox1.Size = new System.Drawing.Size(154, 312);
            this.listBox1.TabIndex = 0;
            this.listBox1.SelectedIndexChanged += new System.EventHandler(this.listBox1_SelectedIndexChanged);
            this.listBox1.KeyDown += new System.Windows.Forms.KeyEventHandler(this.listBox1_KeyDown);
            // 
            // groupBoxMod
            // 
            this.groupBoxMod.AutoSize = true;
            this.groupBoxMod.AutoSizeMode = System.Windows.Forms.AutoSizeMode.GrowAndShrink;
            this.tableLayoutPanel1.SetColumnSpan(this.groupBoxMod, 2);
            this.groupBoxMod.Controls.Add(this.tableLayoutPanel2);
            this.groupBoxMod.Dock = System.Windows.Forms.DockStyle.Top;
            this.groupBoxMod.Location = new System.Drawing.Point(169, 3);
            this.groupBoxMod.MinimumSize = new System.Drawing.Size(0, 250);
            this.groupBoxMod.Name = "groupBoxMod";
            this.groupBoxMod.Size = new System.Drawing.Size(232, 250);
            this.groupBoxMod.TabIndex = 2;
            this.groupBoxMod.TabStop = false;
            this.groupBoxMod.Text = "Modname here...";
            // 
            // tableLayoutPanel2
            // 
            this.tableLayoutPanel2.AutoSize = true;
            this.tableLayoutPanel2.AutoSizeMode = System.Windows.Forms.AutoSizeMode.GrowAndShrink;
            this.tableLayoutPanel2.ColumnCount = 3;
            this.tableLayoutPanel2.ColumnStyles.Add(new System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType.Percent, 100F));
            this.tableLayoutPanel2.ColumnStyles.Add(new System.Windows.Forms.ColumnStyle());
            this.tableLayoutPanel2.ColumnStyles.Add(new System.Windows.Forms.ColumnStyle());
            this.tableLayoutPanel2.Controls.Add(this.buttonMoveUp, 1, 2);
            this.tableLayoutPanel2.Controls.Add(this.buttonMoveDown, 2, 2);
            this.tableLayoutPanel2.Controls.Add(this.checkBoxModEnabled, 0, 2);
            this.tableLayoutPanel2.Controls.Add(this.tabControl1, 0, 1);
            this.tableLayoutPanel2.Dock = System.Windows.Forms.DockStyle.Fill;
            this.tableLayoutPanel2.Location = new System.Drawing.Point(3, 16);
            this.tableLayoutPanel2.Name = "tableLayoutPanel2";
            this.tableLayoutPanel2.RowCount = 3;
            this.tableLayoutPanel2.RowStyles.Add(new System.Windows.Forms.RowStyle());
            this.tableLayoutPanel2.RowStyles.Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType.Percent, 100F));
            this.tableLayoutPanel2.RowStyles.Add(new System.Windows.Forms.RowStyle());
            this.tableLayoutPanel2.Size = new System.Drawing.Size(226, 231);
            this.tableLayoutPanel2.TabIndex = 0;
            // 
            // buttonMoveUp
            // 
            this.buttonMoveUp.Anchor = System.Windows.Forms.AnchorStyles.Right;
            this.buttonMoveUp.AutoSize = true;
            this.buttonMoveUp.AutoSizeMode = System.Windows.Forms.AutoSizeMode.GrowAndShrink;
            this.buttonMoveUp.Location = new System.Drawing.Point(81, 205);
            this.buttonMoveUp.Name = "buttonMoveUp";
            this.buttonMoveUp.Size = new System.Drawing.Size(61, 23);
            this.buttonMoveUp.TabIndex = 1;
            this.buttonMoveUp.Text = "Move Up";
            this.buttonMoveUp.UseVisualStyleBackColor = true;
            this.buttonMoveUp.Click += new System.EventHandler(this.buttonMoveUp_Click);
            // 
            // buttonMoveDown
            // 
            this.buttonMoveDown.Anchor = System.Windows.Forms.AnchorStyles.Right;
            this.buttonMoveDown.AutoSize = true;
            this.buttonMoveDown.AutoSizeMode = System.Windows.Forms.AutoSizeMode.GrowAndShrink;
            this.buttonMoveDown.Location = new System.Drawing.Point(148, 205);
            this.buttonMoveDown.Name = "buttonMoveDown";
            this.buttonMoveDown.Size = new System.Drawing.Size(75, 23);
            this.buttonMoveDown.TabIndex = 2;
            this.buttonMoveDown.Text = "Move Down";
            this.buttonMoveDown.UseVisualStyleBackColor = true;
            this.buttonMoveDown.Click += new System.EventHandler(this.buttonMoveDown_Click);
            // 
            // checkBoxModEnabled
            // 
            this.checkBoxModEnabled.Anchor = System.Windows.Forms.AnchorStyles.Left;
            this.checkBoxModEnabled.AutoSize = true;
            this.checkBoxModEnabled.Location = new System.Drawing.Point(3, 208);
            this.checkBoxModEnabled.Name = "checkBoxModEnabled";
            this.checkBoxModEnabled.Size = new System.Drawing.Size(65, 17);
            this.checkBoxModEnabled.TabIndex = 3;
            this.checkBoxModEnabled.Text = "Enabled";
            this.checkBoxModEnabled.UseVisualStyleBackColor = true;
            this.checkBoxModEnabled.CheckedChanged += new System.EventHandler(this.checkBoxModEnabled_CheckedChanged);
            // 
            // checkBoxForceRecompile
            // 
            this.checkBoxForceRecompile.Anchor = System.Windows.Forms.AnchorStyles.Right;
            this.checkBoxForceRecompile.AutoSize = true;
            this.checkBoxForceRecompile.Checked = true;
            this.checkBoxForceRecompile.CheckState = System.Windows.Forms.CheckState.Checked;
            this.checkBoxForceRecompile.Location = new System.Drawing.Point(229, 315);
            this.checkBoxForceRecompile.Name = "checkBoxForceRecompile";
            this.checkBoxForceRecompile.Size = new System.Drawing.Size(101, 17);
            this.checkBoxForceRecompile.TabIndex = 1;
            this.checkBoxForceRecompile.Text = "Force recompile";
            this.checkBoxForceRecompile.UseVisualStyleBackColor = true;
            // 
            // buttonSave
            // 
            this.buttonSave.Anchor = System.Windows.Forms.AnchorStyles.Right;
            this.buttonSave.Location = new System.Drawing.Point(337, 314);
            this.buttonSave.Name = "buttonSave";
            this.buttonSave.Size = new System.Drawing.Size(64, 20);
            this.buttonSave.TabIndex = 3;
            this.buttonSave.Text = "Save";
            this.buttonSave.UseVisualStyleBackColor = true;
            this.buttonSave.Click += new System.EventHandler(this.buttonSave_Click);
            // 
            // buttonResetDefaults
            // 
            this.buttonResetDefaults.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Bottom | System.Windows.Forms.AnchorStyles.Right)));
            this.buttonResetDefaults.AutoSize = true;
            this.buttonResetDefaults.AutoSizeMode = System.Windows.Forms.AutoSizeMode.GrowAndShrink;
            this.tableLayoutPanel1.SetColumnSpan(this.buttonResetDefaults, 2);
            this.buttonResetDefaults.Location = new System.Drawing.Point(220, 285);
            this.buttonResetDefaults.Name = "buttonResetDefaults";
            this.buttonResetDefaults.Size = new System.Drawing.Size(181, 23);
            this.buttonResetDefaults.TabIndex = 4;
            this.buttonResetDefaults.Text = "Reset load orders to default values";
            this.buttonResetDefaults.UseVisualStyleBackColor = true;
            this.buttonResetDefaults.Click += new System.EventHandler(this.buttonResetDefaults_Click);
            // 
            // menuStrip1
            // 
            this.menuStrip1.Items.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.toolStripMenuItem1});
            this.menuStrip1.Location = new System.Drawing.Point(0, 0);
            this.menuStrip1.Name = "menuStrip1";
            this.menuStrip1.Size = new System.Drawing.Size(404, 24);
            this.menuStrip1.TabIndex = 1;
            this.menuStrip1.Text = "menuStrip1";
            // 
            // toolStripMenuItem1
            // 
            this.toolStripMenuItem1.DropDownItems.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.forceRecompileToolStripMenuItem,
            this.loadModToolStripMenuItem});
            this.toolStripMenuItem1.Name = "toolStripMenuItem1";
            this.toolStripMenuItem1.Size = new System.Drawing.Size(37, 20);
            this.toolStripMenuItem1.Text = "File";
            this.toolStripMenuItem1.Click += new System.EventHandler(this.toolStripMenuItem1_Click);
            // 
            // forceRecompileToolStripMenuItem
            // 
            this.forceRecompileToolStripMenuItem.DropDownItems.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.debugOptionsToolStripMenuItem,
            this.debugMessagesToolStripMenuItem,
            this.forceRecompileToolStripMenuItem1,
            this.toolStripSeparator1,
            this.dangerousThingsToolStripMenuItem,
            this.uninstallModloaderToolStripMenuItem,
            this.cleanUpSavesToolStripMenuItem});
            this.forceRecompileToolStripMenuItem.Name = "forceRecompileToolStripMenuItem";
            this.forceRecompileToolStripMenuItem.Size = new System.Drawing.Size(180, 22);
            this.forceRecompileToolStripMenuItem.Text = "Modloader settings";
            this.forceRecompileToolStripMenuItem.Click += new System.EventHandler(this.forceRecompileToolStripMenuItem_Click);
            // 
            // loadModToolStripMenuItem
            // 
            this.loadModToolStripMenuItem.Name = "loadModToolStripMenuItem";
            this.loadModToolStripMenuItem.Size = new System.Drawing.Size(180, 22);
            this.loadModToolStripMenuItem.Text = "Add mod";
            this.loadModToolStripMenuItem.Click += new System.EventHandler(this.loadModToolStripMenuItem_Click);
            // 
            // forceRecompileToolStripMenuItem1
            // 
            this.forceRecompileToolStripMenuItem1.Name = "forceRecompileToolStripMenuItem1";
            this.forceRecompileToolStripMenuItem1.Size = new System.Drawing.Size(181, 22);
            this.forceRecompileToolStripMenuItem1.Text = "Force recompile";
            // 
            // debugMessagesToolStripMenuItem
            // 
            this.debugMessagesToolStripMenuItem.Name = "debugMessagesToolStripMenuItem";
            this.debugMessagesToolStripMenuItem.Size = new System.Drawing.Size(181, 22);
            this.debugMessagesToolStripMenuItem.Text = "Debug messages";
            // 
            // uninstallModloaderToolStripMenuItem
            // 
            this.uninstallModloaderToolStripMenuItem.Name = "uninstallModloaderToolStripMenuItem";
            this.uninstallModloaderToolStripMenuItem.Size = new System.Drawing.Size(181, 22);
            this.uninstallModloaderToolStripMenuItem.Text = "Uninstall Modloader";
            this.uninstallModloaderToolStripMenuItem.Click += new System.EventHandler(this.uninstallModloaderToolStripMenuItem_Click);
            // 
            // cleanUpSavesToolStripMenuItem
            // 
            this.cleanUpSavesToolStripMenuItem.Name = "cleanUpSavesToolStripMenuItem";
            this.cleanUpSavesToolStripMenuItem.Size = new System.Drawing.Size(181, 22);
            this.cleanUpSavesToolStripMenuItem.Text = "Clean up saves";
            // 
            // toolStripSeparator1
            // 
            this.toolStripSeparator1.Name = "toolStripSeparator1";
            this.toolStripSeparator1.Size = new System.Drawing.Size(178, 6);
            // 
            // debugOptionsToolStripMenuItem
            // 
            this.debugOptionsToolStripMenuItem.Enabled = false;
            this.debugOptionsToolStripMenuItem.Name = "debugOptionsToolStripMenuItem";
            this.debugOptionsToolStripMenuItem.Size = new System.Drawing.Size(181, 22);
            this.debugOptionsToolStripMenuItem.Text = "Debug options";
            // 
            // dangerousThingsToolStripMenuItem
            // 
            this.dangerousThingsToolStripMenuItem.Enabled = false;
            this.dangerousThingsToolStripMenuItem.Name = "dangerousThingsToolStripMenuItem";
            this.dangerousThingsToolStripMenuItem.Size = new System.Drawing.Size(181, 22);
            this.dangerousThingsToolStripMenuItem.Text = "Dangerous things";
            // 
            // tabControl1
            // 
            this.tableLayoutPanel2.SetColumnSpan(this.tabControl1, 3);
            this.tabControl1.Controls.Add(this.tabPage1);
            this.tabControl1.Controls.Add(this.tabPage2);
            this.tabControl1.Controls.Add(this.tabPage3);
            this.tabControl1.Dock = System.Windows.Forms.DockStyle.Fill;
            this.tabControl1.Location = new System.Drawing.Point(3, 3);
            this.tabControl1.Name = "tabControl1";
            this.tabControl1.SelectedIndex = 0;
            this.tabControl1.Size = new System.Drawing.Size(220, 196);
            this.tabControl1.TabIndex = 4;
            // 
            // tabPage2
            // 
            this.tabPage2.BackColor = System.Drawing.SystemColors.Control;
            this.tabPage2.Controls.Add(this.dgwModSettings);
            this.tabPage2.Location = new System.Drawing.Point(4, 22);
            this.tabPage2.Name = "tabPage2";
            this.tabPage2.Padding = new System.Windows.Forms.Padding(3);
            this.tabPage2.Size = new System.Drawing.Size(212, 170);
            this.tabPage2.TabIndex = 1;
            this.tabPage2.Text = "Settings";
            // 
            // tabPage3
            // 
            this.tabPage3.BackColor = System.Drawing.SystemColors.Control;
            this.tabPage3.Controls.Add(this.dgwModAdvSettings);
            this.tabPage3.Location = new System.Drawing.Point(4, 22);
            this.tabPage3.Name = "tabPage3";
            this.tabPage3.Padding = new System.Windows.Forms.Padding(3);
            this.tabPage3.Size = new System.Drawing.Size(212, 170);
            this.tabPage3.TabIndex = 2;
            this.tabPage3.Text = "Advanced settings";
            // 
            // dgwModAdvSettings
            // 
            this.dgwModAdvSettings.AllowUserToAddRows = false;
            this.dgwModAdvSettings.AllowUserToDeleteRows = false;
            this.dgwModAdvSettings.BackgroundColor = System.Drawing.SystemColors.ActiveCaption;
            this.dgwModAdvSettings.BorderStyle = System.Windows.Forms.BorderStyle.None;
            this.dgwModAdvSettings.ColumnHeadersHeightSizeMode = System.Windows.Forms.DataGridViewColumnHeadersHeightSizeMode.AutoSize;
            this.dgwModAdvSettings.Dock = System.Windows.Forms.DockStyle.Fill;
            this.dgwModAdvSettings.Location = new System.Drawing.Point(3, 3);
            this.dgwModAdvSettings.MultiSelect = false;
            this.dgwModAdvSettings.Name = "dgwModAdvSettings";
            this.dgwModAdvSettings.SelectionMode = System.Windows.Forms.DataGridViewSelectionMode.CellSelect;
            this.dgwModAdvSettings.Size = new System.Drawing.Size(206, 164);
            this.dgwModAdvSettings.TabIndex = 0;
            // 
            // tabPage1
            // 
            this.tabPage1.BackColor = System.Drawing.SystemColors.Control;
            this.tabPage1.BackgroundImageLayout = System.Windows.Forms.ImageLayout.Zoom;
            this.tabPage1.Controls.Add(this.labelDescription);
            this.tabPage1.Location = new System.Drawing.Point(4, 22);
            this.tabPage1.Name = "tabPage1";
            this.tabPage1.Padding = new System.Windows.Forms.Padding(3);
            this.tabPage1.Size = new System.Drawing.Size(212, 170);
            this.tabPage1.TabIndex = 0;
            this.tabPage1.Text = "Description";
            // 
            // labelDescription
            // 
            this.labelDescription.BackColor = System.Drawing.SystemColors.Control;
            this.labelDescription.Dock = System.Windows.Forms.DockStyle.Fill;
            this.labelDescription.Location = new System.Drawing.Point(3, 3);
            this.labelDescription.Name = "labelDescription";
            this.labelDescription.Size = new System.Drawing.Size(206, 164);
            this.labelDescription.TabIndex = 1;
            this.labelDescription.Text = "Mod description here...";
            // 
            // dgwModSettings
            // 
            this.dgwModSettings.AllowUserToAddRows = false;
            this.dgwModSettings.AllowUserToDeleteRows = false;
            this.dgwModSettings.BackgroundColor = System.Drawing.SystemColors.ActiveCaption;
            this.dgwModSettings.BorderStyle = System.Windows.Forms.BorderStyle.None;
            this.dgwModSettings.ColumnHeadersHeightSizeMode = System.Windows.Forms.DataGridViewColumnHeadersHeightSizeMode.AutoSize;
            this.dgwModSettings.Dock = System.Windows.Forms.DockStyle.Fill;
            this.dgwModSettings.Location = new System.Drawing.Point(3, 3);
            this.dgwModSettings.MultiSelect = false;
            this.dgwModSettings.Name = "dgwModSettings";
            this.dgwModSettings.SelectionMode = System.Windows.Forms.DataGridViewSelectionMode.CellSelect;
            this.dgwModSettings.Size = new System.Drawing.Size(206, 164);
            this.dgwModSettings.TabIndex = 1;
            // 
            // ModManager
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(404, 381);
            this.Controls.Add(this.tableLayoutPanel1);
            this.Controls.Add(this.menuStrip1);
            this.MainMenuStrip = this.menuStrip1;
            this.MinimumSize = new System.Drawing.Size(420, 420);
            this.Name = "ModManager";
            this.StartPosition = System.Windows.Forms.FormStartPosition.CenterScreen;
            this.Text = "ModManager";
            this.SizeChanged += new System.EventHandler(this.Form1_SizeChanged);
            this.tableLayoutPanel1.ResumeLayout(false);
            this.tableLayoutPanel1.PerformLayout();
            this.groupBox1.ResumeLayout(false);
            this.groupBoxMod.ResumeLayout(false);
            this.groupBoxMod.PerformLayout();
            this.tableLayoutPanel2.ResumeLayout(false);
            this.tableLayoutPanel2.PerformLayout();
            this.menuStrip1.ResumeLayout(false);
            this.menuStrip1.PerformLayout();
            this.tabControl1.ResumeLayout(false);
            this.tabPage2.ResumeLayout(false);
            this.tabPage3.ResumeLayout(false);
            ((System.ComponentModel.ISupportInitialize)(this.dgwModAdvSettings)).EndInit();
            this.tabPage1.ResumeLayout(false);
            ((System.ComponentModel.ISupportInitialize)(this.dgwModSettings)).EndInit();
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private TableLayoutPanel tableLayoutPanel1;
        private GroupBox groupBox1;
        private CheckBox checkBoxForceRecompile;
        private GroupBox groupBoxMod;
        private TableLayoutPanel tableLayoutPanel2;
        private Button buttonMoveUp;
        private Button buttonMoveDown;
        private Button buttonSave;
        private ListBox listBox1;
        private CheckBox checkBoxModEnabled;
        private Button buttonResetDefaults;
        private MenuStrip menuStrip1;
        private ToolStripMenuItem toolStripMenuItem1;
        private ToolStripMenuItem forceRecompileToolStripMenuItem;
        private ToolStripMenuItem loadModToolStripMenuItem;
        private ToolStripMenuItem forceRecompileToolStripMenuItem1;
        private ToolStripMenuItem debugMessagesToolStripMenuItem;
        private ToolStripMenuItem debugOptionsToolStripMenuItem;
        private ToolStripSeparator toolStripSeparator1;
        private ToolStripMenuItem dangerousThingsToolStripMenuItem;
        private ToolStripMenuItem uninstallModloaderToolStripMenuItem;
        private ToolStripMenuItem cleanUpSavesToolStripMenuItem;
        private TabControl tabControl1;
        private TabPage tabPage2;
        private TabPage tabPage3;
        private DataGridView dgwModAdvSettings;
        private TabPage tabPage1;
        private Label labelDescription;
        private DataGridView dgwModSettings;
    }
}