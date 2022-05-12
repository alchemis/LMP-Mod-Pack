# img_viewer.py

import PySimpleGUI as sg
import os.path
import os
import glob
import textwrap

# First the window layout in 2 columns
Modlist = {}
ModnameList = []
def findMods(rebuild=False):
	mod_settings_list = glob.glob("Data\Mods\*\mod_settings.ini")
	for mod in mod_settings_list:
		modname = mod.split("\\")[2]
		Modlist[modname] = {}
		with open(mod,"r") as modfile:
			for line in modfile.readlines():
				line = line.rstrip()
				if line == "":
					continue
				elif line.startswith("#"):
					continue
				else:
					line = line.split("=")
					Modlist[modname][line[0]] = line[1]
		
		if rebuild: ModnameList.append(modname)
	return(ModnameList)
	
def defaultSort():
	ModnameList = findMods(rebuild=True)
	load_first = []
	load_main = []
	load_after = []
	
	for mod in ModnameList:
		if Modlist[mod]["defaultLoadOrder"] == "1":
			load_first.append(mod)
		elif Modlist[mod]["defaultLoadOrder"] == "2":
			load_main.append(mod)
		else:
			load_after.append(mod)
			
	ModnameList = load_first + load_main + load_after
	return load_first + load_main + load_after

def getLoadOrder():
	try:
		Modnamelist = []
		with open("Data\Mods\load_order.ini","r") as load_order_file:
			for line in load_order_file.readlines():
				Modnamelist.append(line.rstrip())
		findMods()
		return Modnamelist
	except FileNotFoundError:
		return defaultSort()
			
def swapPositions(list, pos1, pos2):
     
    list[pos1], list[pos2] = list[pos2], list[pos1]
    return list
	
ModnameList = getLoadOrder()

mod_list_column = [
	 [
		sg.Text("Load order"),
		sg.Button("Move up"),
		sg.Button("Move down"),
	 ],
	[
		sg.Listbox(
			values=ModnameList, enable_events=True, size=(40, 20), key="-MOD LIST-"
		)
	],
]

# For now will only show the name of the file that was chosen
mod_viewer_column = [
	[sg.Text("Choose a mod from list in the left:")],
	[sg.Text(size=(40, 4), key="-MODDESC-")],
	[sg.Checkbox('Enabled', default=True, key="-CHECK-"),sg.Push(),sg.Button("Save")],
]

# ----- Full layout -----
layout = [
	[
		sg.Column(mod_list_column),
		sg.VSeperator(),
		sg.Column(mod_viewer_column),
	]
]

window = sg.Window("LMPModloader", layout)

# Run the Event Loop
while True:
	event, values = window.read()
	if event == "Exit" or event == sg.WIN_CLOSED:
		break
	# Folder name was filled in, make a list of files in the folder
	# if event == "-FOLDER-":
		# folder = values["-FOLDER-"]
		# try:
			# Get list of files in folder
			# file_list = os.listdir(folder)
		# except:
			# file_list = []

		# fnames = [
			# f
			# for f in file_list
			# if os.path.isfile(os.path.join(folder, f))
			# and f.lower().endswith((".png", ".gif"))
		# ]
		# window["-FILE LIST-"].update(fnames)
	elif event == "Move up":
		try:
			tmp = ModnameList
			old_index = ModnameList.index(values["-MOD LIST-"][0])
			index_to_swap = old_index - 1
			if old_index == 0:
				pass
			else:
				ModnameList = swapPositions(ModnameList,old_index,index_to_swap)
				window["-MOD LIST-"].update(ModnameList)
		except IndexError:
			pass
			
	elif event == "Move down":
		try:
			tmp = ModnameList
			old_index = ModnameList.index(values["-MOD LIST-"][0])
			index_to_swap = old_index + 1
			if old_index == len(ModnameList)-1:
				pass
			else:
				ModnameList = swapPositions(ModnameList,old_index,index_to_swap)
				window["-MOD LIST-"].update(ModnameList)
		except IndexError:
			pass
	elif event == "Save":
		with open("Data\Mods\load_order.ini","w") as load_order_file:
			load_order_file.write("\n".join(ModnameList))
		try:
			os.remove("Data\Mods\mustcompile.ini")
		except FileNotFoundError:
			pass
		sg.Popup('Saved!', keep_on_top=True)
	elif event == "-MOD LIST-":	 # A mod was chosen from the listbox
		#try:
		modname = values["-MOD LIST-"][0]
		window["-MODDESC-"].update(Modlist[modname]["ModDesc"])
		#except:
		#	pass

window.close()