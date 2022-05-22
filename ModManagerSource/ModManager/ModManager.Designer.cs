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
            this.tableLayoutPanel3 = new System.Windows.Forms.TableLayoutPanel();
            this.groupBox1 = new System.Windows.Forms.GroupBox();
            this.enabledListBox = new System.Windows.Forms.ListBox();
            this.groupBox2 = new System.Windows.Forms.GroupBox();
            this.disabledListBox = new System.Windows.Forms.ListBox();
            this.buttonEnable = new System.Windows.Forms.Button();
            this.buttonDisable = new System.Windows.Forms.Button();
            this.groupBoxMod = new System.Windows.Forms.GroupBox();
            this.tableLayoutPanel2 = new System.Windows.Forms.TableLayoutPanel();
            this.buttonMoveUp = new System.Windows.Forms.Button();
            this.buttonMoveDown = new System.Windows.Forms.Button();
            this.tabControl1 = new System.Windows.Forms.TabControl();
            this.tabPage1 = new System.Windows.Forms.TabPage();
            this.labelDescription = new System.Windows.Forms.Label();
            this.tabPage2 = new System.Windows.Forms.TabPage();
            this.dgwModSettings = new System.Windows.Forms.DataGridView();
            this.tabPage3 = new System.Windows.Forms.TabPage();
            this.dgwModAdvSettings = new System.Windows.Forms.DataGridView();
            this.buttonSave = new System.Windows.Forms.Button();
            this.menuStrip1 = new System.Windows.Forms.MenuStrip();
            this.toolStripMenuItem1 = new System.Windows.Forms.ToolStripMenuItem();
            this.loadModToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.actionsToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.modloaderSettingsToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.forceRecompileToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.debugMessagesToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.resetLoadOrderToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.toolStripSeparator1 = new System.Windows.Forms.ToolStripSeparator();
            this.dangerousThingsToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.cleanUpSavesToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.uninstallModloaderToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.tableLayoutPanel1.SuspendLayout();
            this.tableLayoutPanel3.SuspendLayout();
            this.groupBox1.SuspendLayout();
            this.groupBox2.SuspendLayout();
            this.groupBoxMod.SuspendLayout();
            this.tableLayoutPanel2.SuspendLayout();
            this.tabControl1.SuspendLayout();
            this.tabPage1.SuspendLayout();
            this.tabPage2.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.dgwModSettings)).BeginInit();
            this.tabPage3.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.dgwModAdvSettings)).BeginInit();
            this.menuStrip1.SuspendLayout();
            this.SuspendLayout();
            // 
            // tableLayoutPanel1
            // 
            this.tableLayoutPanel1.ColumnCount = 3;
            this.tableLayoutPanel1.ColumnStyles.Add(new System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType.Percent, 50F));
            this.tableLayoutPanel1.ColumnStyles.Add(new System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType.Percent, 50.00001F));
            this.tableLayoutPanel1.ColumnStyles.Add(new System.Windows.Forms.ColumnStyle());
            this.tableLayoutPanel1.Controls.Add(this.tableLayoutPanel3, 0, 0);
            this.tableLayoutPanel1.Controls.Add(this.groupBoxMod, 1, 0);
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
            // tableLayoutPanel3
            // 
            this.tableLayoutPanel3.ColumnCount = 2;
            this.tableLayoutPanel3.ColumnStyles.Add(new System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType.Percent, 50F));
            this.tableLayoutPanel3.ColumnStyles.Add(new System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType.Percent, 50F));
            this.tableLayoutPanel3.Controls.Add(this.groupBox1, 0, 0);
            this.tableLayoutPanel3.Controls.Add(this.groupBox2, 0, 2);
            this.tableLayoutPanel3.Controls.Add(this.buttonEnable, 0, 1);
            this.tableLayoutPanel3.Controls.Add(this.buttonDisable, 1, 1);
            this.tableLayoutPanel3.Dock = System.Windows.Forms.DockStyle.Fill;
            this.tableLayoutPanel3.Location = new System.Drawing.Point(3, 3);
            this.tableLayoutPanel3.Name = "tableLayoutPanel3";
            this.tableLayoutPanel3.RowCount = 3;
            this.tableLayoutPanel1.SetRowSpan(this.tableLayoutPanel3, 4);
            this.tableLayoutPanel3.RowStyles.Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType.Percent, 50F));
            this.tableLayoutPanel3.RowStyles.Add(new System.Windows.Forms.RowStyle());
            this.tableLayoutPanel3.RowStyles.Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType.Percent, 50F));
            this.tableLayoutPanel3.RowStyles.Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType.Absolute, 20F));
            this.tableLayoutPanel3.RowStyles.Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType.Absolute, 20F));
            this.tableLayoutPanel3.RowStyles.Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType.Absolute, 20F));
            this.tableLayoutPanel3.RowStyles.Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType.Absolute, 20F));
            this.tableLayoutPanel3.RowStyles.Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType.Absolute, 20F));
            this.tableLayoutPanel3.Size = new System.Drawing.Size(136, 351);
            this.tableLayoutPanel3.TabIndex = 0;
            // 
            // groupBox1
            // 
            this.tableLayoutPanel3.SetColumnSpan(this.groupBox1, 2);
            this.groupBox1.Controls.Add(this.enabledListBox);
            this.groupBox1.Dock = System.Windows.Forms.DockStyle.Fill;
            this.groupBox1.Location = new System.Drawing.Point(3, 3);
            this.groupBox1.Name = "groupBox1";
            this.groupBox1.Size = new System.Drawing.Size(130, 155);
            this.groupBox1.TabIndex = 0;
            this.groupBox1.TabStop = false;
            this.groupBox1.Text = "Load Order";
            // 
            // enabledListBox
            // 
            this.enabledListBox.Dock = System.Windows.Forms.DockStyle.Fill;
            this.enabledListBox.FormattingEnabled = true;
            this.enabledListBox.Location = new System.Drawing.Point(3, 16);
            this.enabledListBox.Name = "enabledListBox";
            this.enabledListBox.Size = new System.Drawing.Size(124, 136);
            this.enabledListBox.TabIndex = 1;
            this.enabledListBox.SelectedIndexChanged += new System.EventHandler(this.listBox1_SelectedIndexChanged);
            // 
            // groupBox2
            // 
            this.tableLayoutPanel3.SetColumnSpan(this.groupBox2, 2);
            this.groupBox2.Controls.Add(this.disabledListBox);
            this.groupBox2.Dock = System.Windows.Forms.DockStyle.Fill;
            this.groupBox2.Location = new System.Drawing.Point(3, 193);
            this.groupBox2.Name = "groupBox2";
            this.groupBox2.Size = new System.Drawing.Size(130, 155);
            this.groupBox2.TabIndex = 2;
            this.groupBox2.TabStop = false;
            this.groupBox2.Text = "Disabled Mods";
            // 
            // disabledListBox
            // 
            this.disabledListBox.Dock = System.Windows.Forms.DockStyle.Fill;
            this.disabledListBox.FormattingEnabled = true;
            this.disabledListBox.Location = new System.Drawing.Point(3, 16);
            this.disabledListBox.Name = "disabledListBox";
            this.disabledListBox.Size = new System.Drawing.Size(124, 136);
            this.disabledListBox.TabIndex = 2;
            this.disabledListBox.SelectedIndexChanged += new System.EventHandler(this.listBox1_SelectedIndexChanged);
            // 
            // buttonEnable
            // 
            this.buttonEnable.Location = new System.Drawing.Point(3, 164);
            this.buttonEnable.Name = "buttonEnable";
            this.buttonEnable.Size = new System.Drawing.Size(62, 23);
            this.buttonEnable.TabIndex = 3;
            this.buttonEnable.Text = "▲";
            this.buttonEnable.UseVisualStyleBackColor = true;
            this.buttonEnable.Click += new System.EventHandler(this.buttonEnable_Click);
            // 
            // buttonDisable
            // 
            this.buttonDisable.Location = new System.Drawing.Point(71, 164);
            this.buttonDisable.Name = "buttonDisable";
            this.buttonDisable.Size = new System.Drawing.Size(62, 23);
            this.buttonDisable.TabIndex = 4;
            this.buttonDisable.Text = "▼";
            this.buttonDisable.UseVisualStyleBackColor = true;
            this.buttonDisable.Click += new System.EventHandler(this.buttonDisable_Click);
            // 
            // groupBoxMod
            // 
            this.groupBoxMod.AutoSize = true;
            this.groupBoxMod.AutoSizeMode = System.Windows.Forms.AutoSizeMode.GrowAndShrink;
            this.tableLayoutPanel1.SetColumnSpan(this.groupBoxMod, 2);
            this.groupBoxMod.Controls.Add(this.tableLayoutPanel2);
            this.groupBoxMod.Dock = System.Windows.Forms.DockStyle.Fill;
            this.groupBoxMod.Location = new System.Drawing.Point(145, 3);
            this.groupBoxMod.MinimumSize = new System.Drawing.Size(0, 250);
            this.groupBoxMod.Name = "groupBoxMod";
            this.tableLayoutPanel1.SetRowSpan(this.groupBoxMod, 4);
            this.groupBoxMod.Size = new System.Drawing.Size(256, 351);
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
            this.tableLayoutPanel2.Controls.Add(this.tabControl1, 0, 1);
            this.tableLayoutPanel2.Controls.Add(this.buttonSave, 0, 2);
            this.tableLayoutPanel2.Dock = System.Windows.Forms.DockStyle.Fill;
            this.tableLayoutPanel2.Location = new System.Drawing.Point(3, 16);
            this.tableLayoutPanel2.Name = "tableLayoutPanel2";
            this.tableLayoutPanel2.RowCount = 3;
            this.tableLayoutPanel2.RowStyles.Add(new System.Windows.Forms.RowStyle());
            this.tableLayoutPanel2.RowStyles.Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType.Percent, 100F));
            this.tableLayoutPanel2.RowStyles.Add(new System.Windows.Forms.RowStyle());
            this.tableLayoutPanel2.Size = new System.Drawing.Size(250, 332);
            this.tableLayoutPanel2.TabIndex = 0;
            // 
            // buttonMoveUp
            // 
            this.buttonMoveUp.Anchor = System.Windows.Forms.AnchorStyles.Right;
            this.buttonMoveUp.AutoSize = true;
            this.buttonMoveUp.AutoSizeMode = System.Windows.Forms.AutoSizeMode.GrowAndShrink;
            this.buttonMoveUp.Location = new System.Drawing.Point(105, 306);
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
            this.buttonMoveDown.Location = new System.Drawing.Point(172, 306);
            this.buttonMoveDown.Name = "buttonMoveDown";
            this.buttonMoveDown.Size = new System.Drawing.Size(75, 23);
            this.buttonMoveDown.TabIndex = 2;
            this.buttonMoveDown.Text = "Move Down";
            this.buttonMoveDown.UseVisualStyleBackColor = true;
            this.buttonMoveDown.Click += new System.EventHandler(this.buttonMoveDown_Click);
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
            this.tabControl1.Size = new System.Drawing.Size(244, 297);
            this.tabControl1.TabIndex = 4;
            // 
            // tabPage1
            // 
            this.tabPage1.BackColor = System.Drawing.SystemColors.Control;
            this.tabPage1.BackgroundImageLayout = System.Windows.Forms.ImageLayout.Zoom;
            this.tabPage1.Controls.Add(this.labelDescription);
            this.tabPage1.Location = new System.Drawing.Point(4, 22);
            this.tabPage1.Name = "tabPage1";
            this.tabPage1.Padding = new System.Windows.Forms.Padding(3);
            this.tabPage1.Size = new System.Drawing.Size(236, 271);
            this.tabPage1.TabIndex = 0;
            this.tabPage1.Text = "Description";
            // 
            // labelDescription
            // 
            this.labelDescription.BackColor = System.Drawing.SystemColors.Control;
            this.labelDescription.Dock = System.Windows.Forms.DockStyle.Fill;
            this.labelDescription.Location = new System.Drawing.Point(3, 3);
            this.labelDescription.Name = "labelDescription";
            this.labelDescription.Size = new System.Drawing.Size(230, 265);
            this.labelDescription.TabIndex = 1;
            this.labelDescription.Text = "Mod description here...";
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
            // tabPage3
            // 
            this.tabPage3.BackColor = System.Drawing.SystemColors.Control;
            this.tabPage3.Controls.Add(this.dgwModAdvSettings);
            this.tabPage3.Location = new System.Drawing.Point(4, 22);
            this.tabPage3.Name = "tabPage3";
            this.tabPage3.Padding = new System.Windows.Forms.Padding(3);
            this.tabPage3.Size = new System.Drawing.Size(236, 271);
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
            this.dgwModAdvSettings.Size = new System.Drawing.Size(230, 265);
            this.dgwModAdvSettings.TabIndex = 0;
            // 
            // buttonSave
            // 
            this.buttonSave.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Left | System.Windows.Forms.AnchorStyles.Right)));
            this.buttonSave.Location = new System.Drawing.Point(3, 307);
            this.buttonSave.Name = "buttonSave";
            this.buttonSave.Size = new System.Drawing.Size(96, 20);
            this.buttonSave.TabIndex = 3;
            this.buttonSave.Text = "Save";
            this.buttonSave.UseVisualStyleBackColor = true;
            this.buttonSave.Click += new System.EventHandler(this.buttonSave_Click);
            // 
            // menuStrip1
            // 
            this.menuStrip1.Items.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.toolStripMenuItem1,
            this.actionsToolStripMenuItem,
            this.modloaderSettingsToolStripMenuItem});
            this.menuStrip1.Location = new System.Drawing.Point(0, 0);
            this.menuStrip1.Name = "menuStrip1";
            this.menuStrip1.Padding = new System.Windows.Forms.Padding(2, 0, 0, 0);
            this.menuStrip1.Size = new System.Drawing.Size(404, 24);
            this.menuStrip1.TabIndex = 1;
            this.menuStrip1.Text = "menuStrip1";
            // 
            // toolStripMenuItem1
            // 
            this.toolStripMenuItem1.DropDownItems.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.loadModToolStripMenuItem});
            this.toolStripMenuItem1.Name = "toolStripMenuItem1";
            this.toolStripMenuItem1.Size = new System.Drawing.Size(37, 24);
            this.toolStripMenuItem1.Text = "File";
            // 
            // loadModToolStripMenuItem
            // 
            this.loadModToolStripMenuItem.Name = "loadModToolStripMenuItem";
            this.loadModToolStripMenuItem.Size = new System.Drawing.Size(180, 22);
            this.loadModToolStripMenuItem.Text = "Add mod";
            // 
            // actionsToolStripMenuItem
            // 
            this.actionsToolStripMenuItem.DropDownItems.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.resetLoadOrderToolStripMenuItem,
            this.toolStripSeparator1,
            this.dangerousThingsToolStripMenuItem,
            this.cleanUpSavesToolStripMenuItem,
            this.uninstallModloaderToolStripMenuItem});
            this.actionsToolStripMenuItem.Name = "actionsToolStripMenuItem";
            this.actionsToolStripMenuItem.Size = new System.Drawing.Size(59, 24);
            this.actionsToolStripMenuItem.Text = "Actions";
            // 
            // modloaderSettingsToolStripMenuItem
            // 
            this.modloaderSettingsToolStripMenuItem.DropDownItems.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.debugMessagesToolStripMenuItem,
            this.forceRecompileToolStripMenuItem});
            this.modloaderSettingsToolStripMenuItem.Name = "modloaderSettingsToolStripMenuItem";
            this.modloaderSettingsToolStripMenuItem.Size = new System.Drawing.Size(122, 24);
            this.modloaderSettingsToolStripMenuItem.Text = "Modloader Settings";
            // 
            // forceRecompileToolStripMenuItem
            // 
            this.forceRecompileToolStripMenuItem.Name = "forceRecompileToolStripMenuItem";
            this.forceRecompileToolStripMenuItem.Size = new System.Drawing.Size(180, 22);
            this.forceRecompileToolStripMenuItem.Tag = "recompile";
            this.forceRecompileToolStripMenuItem.Text = "Force recompile";
            this.forceRecompileToolStripMenuItem.Click += new System.EventHandler(this.clickedCheckableToolStripMenuItem);
            // 
            // debugMessagesToolStripMenuItem
            // 
            this.debugMessagesToolStripMenuItem.Name = "debugMessagesToolStripMenuItem";
            this.debugMessagesToolStripMenuItem.Size = new System.Drawing.Size(180, 22);
            this.debugMessagesToolStripMenuItem.Tag = "debug";
            this.debugMessagesToolStripMenuItem.Text = "Debug messages";
            this.debugMessagesToolStripMenuItem.Click += new System.EventHandler(this.clickedCheckableToolStripMenuItem);
            // 
            // resetLoadOrderToolStripMenuItem
            // 
            this.resetLoadOrderToolStripMenuItem.Name = "resetLoadOrderToolStripMenuItem";
            this.resetLoadOrderToolStripMenuItem.Size = new System.Drawing.Size(181, 22);
            this.resetLoadOrderToolStripMenuItem.Text = "Reset load order";
            this.resetLoadOrderToolStripMenuItem.Click += new System.EventHandler(this.ResetDefaults_Click);
            // 
            // toolStripSeparator1
            // 
            this.toolStripSeparator1.Name = "toolStripSeparator1";
            this.toolStripSeparator1.Size = new System.Drawing.Size(178, 6);
            // 
            // dangerousThingsToolStripMenuItem
            // 
            this.dangerousThingsToolStripMenuItem.Enabled = false;
            this.dangerousThingsToolStripMenuItem.Name = "dangerousThingsToolStripMenuItem";
            this.dangerousThingsToolStripMenuItem.Size = new System.Drawing.Size(181, 22);
            this.dangerousThingsToolStripMenuItem.Text = "Dangerous things";
            // 
            // cleanUpSavesToolStripMenuItem
            // 
            this.cleanUpSavesToolStripMenuItem.Name = "cleanUpSavesToolStripMenuItem";
            this.cleanUpSavesToolStripMenuItem.Size = new System.Drawing.Size(181, 22);
            this.cleanUpSavesToolStripMenuItem.Text = "Clean up saves";
            // 
            // uninstallModloaderToolStripMenuItem
            // 
            this.uninstallModloaderToolStripMenuItem.Name = "uninstallModloaderToolStripMenuItem";
            this.uninstallModloaderToolStripMenuItem.Size = new System.Drawing.Size(181, 22);
            this.uninstallModloaderToolStripMenuItem.Text = "Uninstall Modloader";
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
            this.tableLayoutPanel3.ResumeLayout(false);
            this.groupBox1.ResumeLayout(false);
            this.groupBox2.ResumeLayout(false);
            this.groupBoxMod.ResumeLayout(false);
            this.groupBoxMod.PerformLayout();
            this.tableLayoutPanel2.ResumeLayout(false);
            this.tableLayoutPanel2.PerformLayout();
            this.tabControl1.ResumeLayout(false);
            this.tabPage1.ResumeLayout(false);
            this.tabPage2.ResumeLayout(false);
            ((System.ComponentModel.ISupportInitialize)(this.dgwModSettings)).EndInit();
            this.tabPage3.ResumeLayout(false);
            ((System.ComponentModel.ISupportInitialize)(this.dgwModAdvSettings)).EndInit();
            this.menuStrip1.ResumeLayout(false);
            this.menuStrip1.PerformLayout();
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private TableLayoutPanel tableLayoutPanel1;
        private GroupBox groupBox1;
        private GroupBox groupBoxMod;
        private TableLayoutPanel tableLayoutPanel2;
        private Button buttonMoveUp;
        private Button buttonMoveDown;
        private Button buttonSave;
        private MenuStrip menuStrip1;
        private ToolStripMenuItem toolStripMenuItem1;
        private ToolStripMenuItem loadModToolStripMenuItem;
        private TabControl tabControl1;
        private TabPage tabPage2;
        private TabPage tabPage3;
        private DataGridView dgwModAdvSettings;
        private TabPage tabPage1;
        private Label labelDescription;
        private DataGridView dgwModSettings;
        private TableLayoutPanel tableLayoutPanel3;
        private GroupBox groupBox2;
        private ListBox disabledListBox;
        private ListBox enabledListBox;
        private Button buttonEnable;
        private Button buttonDisable;
        private ToolStripMenuItem actionsToolStripMenuItem;
        private ToolStripMenuItem resetLoadOrderToolStripMenuItem;
        private ToolStripSeparator toolStripSeparator1;
        private ToolStripMenuItem dangerousThingsToolStripMenuItem;
        private ToolStripMenuItem cleanUpSavesToolStripMenuItem;
        private ToolStripMenuItem uninstallModloaderToolStripMenuItem;
        private ToolStripMenuItem modloaderSettingsToolStripMenuItem;
        private ToolStripMenuItem debugMessagesToolStripMenuItem;
        private ToolStripMenuItem forceRecompileToolStripMenuItem;
    }
}