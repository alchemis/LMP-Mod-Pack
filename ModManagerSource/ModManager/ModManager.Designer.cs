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
            this.labelDescription = new System.Windows.Forms.Label();
            this.buttonMoveUp = new System.Windows.Forms.Button();
            this.buttonMoveDown = new System.Windows.Forms.Button();
            this.checkBoxModEnabled = new System.Windows.Forms.CheckBox();
            this.checkBoxForceRecompile = new System.Windows.Forms.CheckBox();
            this.buttonSave = new System.Windows.Forms.Button();
            this.buttonResetDefaults = new System.Windows.Forms.Button();
            this.tableLayoutPanel1.SuspendLayout();
            this.groupBox1.SuspendLayout();
            this.groupBoxMod.SuspendLayout();
            this.tableLayoutPanel2.SuspendLayout();
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
            this.tableLayoutPanel1.Location = new System.Drawing.Point(0, 0);
            this.tableLayoutPanel1.Name = "tableLayoutPanel1";
            this.tableLayoutPanel1.RowCount = 3;
            this.tableLayoutPanel1.RowStyles.Add(new System.Windows.Forms.RowStyle());
            this.tableLayoutPanel1.RowStyles.Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType.Percent, 100F));
            this.tableLayoutPanel1.RowStyles.Add(new System.Windows.Forms.RowStyle());
            this.tableLayoutPanel1.Size = new System.Drawing.Size(404, 381);
            this.tableLayoutPanel1.TabIndex = 0;
            // 
            // groupBox1
            // 
            this.groupBox1.Controls.Add(this.listBox1);
            this.groupBox1.Dock = System.Windows.Forms.DockStyle.Fill;
            this.groupBox1.Location = new System.Drawing.Point(3, 3);
            this.groupBox1.Name = "groupBox1";
            this.tableLayoutPanel1.SetRowSpan(this.groupBox1, 3);
            this.groupBox1.Size = new System.Drawing.Size(160, 375);
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
            this.listBox1.Size = new System.Drawing.Size(154, 356);
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
            this.tableLayoutPanel2.Controls.Add(this.labelDescription, 0, 0);
            this.tableLayoutPanel2.Controls.Add(this.buttonMoveUp, 1, 2);
            this.tableLayoutPanel2.Controls.Add(this.buttonMoveDown, 2, 2);
            this.tableLayoutPanel2.Controls.Add(this.checkBoxModEnabled, 0, 2);
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
            // labelDescription
            // 
            this.labelDescription.AutoSize = true;
            this.tableLayoutPanel2.SetColumnSpan(this.labelDescription, 3);
            this.labelDescription.Location = new System.Drawing.Point(3, 0);
            this.labelDescription.Name = "labelDescription";
            this.labelDescription.Size = new System.Drawing.Size(115, 13);
            this.labelDescription.TabIndex = 0;
            this.labelDescription.Text = "Mod description here...";
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
            this.checkBoxForceRecompile.Location = new System.Drawing.Point(229, 359);
            this.checkBoxForceRecompile.Name = "checkBoxForceRecompile";
            this.checkBoxForceRecompile.Size = new System.Drawing.Size(101, 17);
            this.checkBoxForceRecompile.TabIndex = 1;
            this.checkBoxForceRecompile.Text = "Force recompile";
            this.checkBoxForceRecompile.UseVisualStyleBackColor = true;
            // 
            // buttonSave
            // 
            this.buttonSave.Anchor = System.Windows.Forms.AnchorStyles.Right;
            this.buttonSave.Location = new System.Drawing.Point(337, 358);
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
            this.buttonResetDefaults.Location = new System.Drawing.Point(220, 329);
            this.buttonResetDefaults.Name = "buttonResetDefaults";
            this.buttonResetDefaults.Size = new System.Drawing.Size(181, 23);
            this.buttonResetDefaults.TabIndex = 4;
            this.buttonResetDefaults.Text = "Reset load orders to default values";
            this.buttonResetDefaults.UseVisualStyleBackColor = true;
            this.buttonResetDefaults.Click += new System.EventHandler(this.buttonResetDefaults_Click);
            // 
            // ModManager
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(404, 381);
            this.Controls.Add(this.tableLayoutPanel1);
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
            this.ResumeLayout(false);

        }

        #endregion

        private TableLayoutPanel tableLayoutPanel1;
        private GroupBox groupBox1;
        private CheckBox checkBoxForceRecompile;
        private GroupBox groupBoxMod;
        private TableLayoutPanel tableLayoutPanel2;
        private Label labelDescription;
        private Button buttonMoveUp;
        private Button buttonMoveDown;
        private Button buttonSave;
        private ListBox listBox1;
        private CheckBox checkBoxModEnabled;
        private Button buttonResetDefaults;
    }
}