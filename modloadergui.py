# img_viewer.py

import PySimpleGUI as sg
import os.path
import os
import glob
import textwrap

# First the window layout in 2 columns
Modlist = {}
LoadOrder = []
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
		
		if rebuild: LoadOrder.append(modname)
	return(Modlist)
	
def defaultSort():
	findMods(rebuild=True)
	load_first = []
	load_main = []
	load_after = []
	
	for mod in LoadOrder:
		if Modlist[mod]["defaultLoadOrder"] == "1":
			load_first.append(mod)
		elif Modlist[mod]["defaultLoadOrder"] == "2":
			load_main.append(mod)
		else:
			load_after.append(mod)
			
	LoadOrder = load_first + load_main + load_after
	return load_first + load_main + load_after

def getLoadOrder():
	try:
		LoadOrder = []
		with open("Data\Mods\load_order.ini","r") as load_order_file:
			for line in load_order_file.readlines():
				LoadOrder.append(line.rstrip())
		findMods()
		return LoadOrder
	except FileNotFoundError:
		return defaultSort()

def getDisabledMods():
	disabled = []
	for mod in Modlist.keys():
		if mod not in LoadOrder: disabled.append(mod)
	return disabled
	
def swapPositions(list, pos1, pos2):
     
    list[pos1], list[pos2] = list[pos2], list[pos1]
    return list
	
LoadOrder = getLoadOrder()
disabledMods = getDisabledMods()
mod_list_column = [
	[
		sg.Frame("Load Order",[[sg.Listbox(values=LoadOrder+disabledMods, enable_events=True, size=(40, 20), key="-MOD LIST-"),]],),
	]
]

mod_stuff_group = [
	[
		sg.Text("Choose a mod from list in the left:", size=(40, 4), key="-MODDESC-"),
		sg.VPush(),

	],
	[
		sg.Checkbox('Enable',enable_events=True, default=True, key="-SEL ENABLED-"),
		sg.Push(),
		sg.Button("Move up"),
		sg.Button("Move down"),
	]
]

settings_group = [
	[sg.Checkbox('Force Recompile', default=True, key="-RECOMPILE-"),sg.Push(),sg.Button("Save")],
]


# For now will only show the name of the file that was chosen
mod_viewer_column = [
	[
		sg.Frame("Selected Mod", mod_stuff_group, key="-SELECTED-"),
	],
	[sg.VPush()],
	[sg.vbottom(sg.Frame("",settings_group,))],
	
]

# ----- Full layout -----
layout = [
	[
		sg.Column(mod_list_column),
		sg.VSeperator(),
		sg.vtop(sg.Column(mod_viewer_column,element_justification='r')),
	]
]

window = sg.Window("LMPModloader", layout)

def updateGui():
	modname = values["-MOD LIST-"][0]
	#print(modname + " is enabled? " + str(not modname in disabledMods))
	window["-SEL ENABLED-"].update(modname not in disabledMods)
	window["Move up"].update(disabled=modname in disabledMods)
	window["Move down"].update(disabled=modname in disabledMods)
	window["-MODDESC-"].update(Modlist[modname]["ModDesc"])
	window["-SELECTED-"].update(Modlist[modname]["ModName"])

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
			tmp = LoadOrder
			old_index = LoadOrder.index(values["-MOD LIST-"][0])
			index_to_swap = old_index - 1
			if old_index == 0:
				pass
			else:
				LoadOrder = swapPositions(LoadOrder,old_index,index_to_swap)
				window["-MOD LIST-"].update(LoadOrder)
		except IndexError:
			pass
			
	elif event == "Move down":
		try:
			tmp = LoadOrder
			old_index = LoadOrder.index(values["-MOD LIST-"][0])
			index_to_swap = old_index + 1
			if old_index == len(LoadOrder)-1:
				pass
			else:
				LoadOrder = swapPositions(LoadOrder,old_index,index_to_swap)
				window["-MOD LIST-"].update(LoadOrder)
		except IndexError:
			pass
	elif event == "Save":
		with open("Data\Mods\load_order.ini","w") as load_order_file:
			load_order_file.write("\n".join(LoadOrder))
		try:
			if values["-RECOMPILE-"]: os.remove("Data\Mods\mustcompile.ini")

		except FileNotFoundError:
			pass
		sg.Popup('Saved!', keep_on_top=True)
	elif event == "-SEL ENABLED-":
		if values["-SEL ENABLED-"]: 
			LoadOrder.append(values["-MOD LIST-"][0])
			
		else: 
			#print(values["-MOD LIST-"][0])
			LoadOrder.remove(values["-MOD LIST-"][0])
		disabledMods = getDisabledMods()
		updateGui()
	elif event == "-MOD LIST-":	 # A mod was chosen from the listbox
		#try:
		updateGui()
		#except:
		#	pass

window.close()