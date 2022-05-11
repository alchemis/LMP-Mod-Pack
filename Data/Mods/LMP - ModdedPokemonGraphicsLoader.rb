################################################################################
# Loads Modded Pokemon Graphics, takes a string containing the mod path as an argument
################################################################################
	
	
	
	def pbPokemonBitmap(species, shiny=false, back=false, gender=nil)   # Used by the Pokédex
	  if $dexForms == nil
		$dexForms = Array.new(807) {|i| 0}
	  end
	  
	  mod = ""
	  if hasModGraphics?(species)
		mod = "Data/Mods/" + $ListOfModPokemonByParent[species][:parent] + "/"
		
		species = $ListOfModPokemonByParent[species][:id]
	  end
	  
	  gender = $Trainer.formlastseen[species][0] if gender == nil && species != 0
	  if $dexForms[species-1] == 0
		gendermod = gender == 1 ? "f" : ""
	  end
	  bitmapFileName=sprintf(mod + "Graphics/Battlers/%03d%s",species,gendermod)
	  bitmapFileName=sprintf(mod + "Graphics/Battlers/%03d",species) if !pbResolveBitmap(bitmapFileName)
	  return nil if !pbResolveBitmap(bitmapFileName)
	  monbitmap = RPG::Cache.load_bitmap(bitmapFileName)
	  bitmap=Bitmap.new(192,192)
	  x = shiny ? 192 : 0
	  y = $dexForms[species-1] ? $dexForms[species-1]*384 : 0
	  y += back ? 192 : 0
	  y = 0 if monbitmap.height <= y
		rectangle = Rect.new(x,y,192,192)
	  bitmap.blt(0,0,monbitmap,rectangle)
	  return bitmap
	end

	def pbLoadPokemonBitmap(pokemon, back=false)
	  return pbLoadPokemonBitmapSpecies(pokemon,nil,back) if pokemon == "substitute"
	  return pbLoadPokemonBitmapSpecies(pokemon,pokemon.species,back)
	end

	ShitList = [PBSpecies::EXEGGUTOR,PBSpecies::KYUREM,PBSpecies::TANGROWTH,PBSpecies::STEELIX,PBSpecies::AVALUGG,PBSpecies::CLAWITZER,PBSpecies::SWALOT]
	# This is a lie now; leaving it in case we care later: Note: Returns an AnimatedBitmap, not a Bitmap
	def pbLoadPokemonBitmapSpecies(pokemon, species, back=false)
	  #load dummy bitmap
	  #ret=AnimatedBitmap.new(pbResolveBitmap("Graphics/pixel"))
	  if pokemon=="substitute"
		if !back
		  bitmapFileName=sprintf("Graphics/Battlers/substitute")
		else
		  bitmapFileName=sprintf("Graphics/Battlers/substitute_b")
		end    
		bitmapFileName=pbResolveBitmap(bitmapFileName)
		ret=Bitmap.new(bitmapFileName)
		return ret
	  end

	  mod = ""
	  global_species = species
	  if hasModGraphics?(species)
		mod = "Data/Mods/" + $ListOfModPokemonByParent[species][:parent]
		
		if $ListOfModPokemonByParent[species][:overwrite]
			mod += "/overwrites/"
		else
			mod += "/newpokemon/"
		end
		species = $ListOfModPokemonByParent[species][:id]
	  end

	  if pokemon.form !=0 && ShitList.include?(species)
		if !(species == PBSpecies::STEELIX && pokemon.form == 1) #mega steelix is excused.
				formnumber = "_"+pokemon.form.to_s
		  shinytag = pokemon.isShiny? ? "s" : ""
		  backtag = back ? "b" : ""
		  if pbResolveBitmap(sprintf(mod+"Graphics/Battlers/%03d%s%s%s",species,shinytag,backtag,formnumber))
			return RPG::Cache.load_bitmap(sprintf(mod+"Graphics/Battlers/%03d%s%s%s",species,shinytag,backtag,formnumber))
		  end
		end
	  end
	  x = pokemon.isShiny? ? 192 : 0
	  x = 0 if pokemon.isPulse?
	  y = pokemon.form*384
	  y = 8*384 if (global_species == PBSpecies::SILVALLY && pokemon.form == 19) #Vulpes abusing her dev priviledges
	  y = pokemon.form*192 if pokemon.isEgg?
	  y += back ? 192 : 0
	  if pokemon.form == 0
		gendermod = pokemon.gender == 1 ? "f" : ""
	  end
	  height = 192
	  if pokemon.isEgg?
		#eggs are 64*64 instead of 192*192
		x/=3
		y/=3
		height/=3
		bitmapFileName=sprintf(mod+"Graphics/Battlers/%03d%sEgg",species,gendermod) if !pbResolveBitmap(bitmapFileName)
		bitmapFileName=sprintf(mod+"Graphics/Battlers/%03dEgg",species) if !pbResolveBitmap(bitmapFileName)
		bitmapFileName=sprintf("Graphics/Battlers/Egg") if !pbResolveBitmap(bitmapFileName)
		bitmapFileName=pbResolveBitmap(bitmapFileName)
	  else
		bitmapFileName=pbCheckPokemonBitmapFiles(global_species,pokemon.isFemale?)
		# Alter bitmap if supported
	  end
	  spritesheet = RPG::Cache.load_bitmap(bitmapFileName)
	  bitmap=Bitmap.new(height,height)
	  if spritesheet.height <= y && pokemon.isFemale? && !pokemon.isEgg?
		bitmapFileName=pbCheckPokemonBitmapFiles(global_species)
		spritesheet = RPG::Cache.load_bitmap(bitmapFileName)
		bitmap=Bitmap.new(height,height)
	  end
	  if spritesheet.height <= y
		y = 0
		y += back ? 192 : 0
	  end
		rectangle = Rect.new(x,y,height,height)
	  bitmap.blt(0,0,spritesheet,rectangle)
	  if pokemon.species == PBSpecies::SPINDA && !pokemon.isEgg?
		#bitmap.each {|bitmap|
		pbSpindaSpots(pokemon,bitmap)
		#}
	  end
	  return bitmap
	end

	def pbCheckPokemonBitmapFiles(species,girl=false)
	  mod = ""
	  if hasModGraphics?(species)
		mod = "Data/Mods/" + $ListOfModPokemonByParent[species][:parent] + "/"
		species = $ListOfModPokemonByParent[species][:id]
	  end
	  gendermod = girl == true ? "f" : ""
	  species = species[0] if species.kind_of?(Array)
	  bitmapFileName=sprintf(mod+"Graphics/Battlers/%03d%s",species,gendermod)
	  ret=pbResolveBitmap(bitmapFileName)
	  return ret if ret
	  bitmapFileName=sprintf(mod+"Graphics/Battlers/%03d",species)
	  ret=pbResolveBitmap(bitmapFileName)
	  return ret if ret
	  return pbResolveBitmap(sprintf("Graphics/Battlers/000")) 
	end

	def pbLoadPokemonIcon(pokemon)
	  return pbPokemonIconBitmap(pokemon)
	end

	def pbPokemonIconBitmap(pokemon,egg=false)   # pbpokemonbitmap, but for icons
	  if !pokemon
		return
	  end
	  species = pokemon.species
	  #puts "loading icon for pokemon " + species.to_s
	  mod = ""
	  if hasModGraphics?(species)
		mod = "Data/Mods/" + $ListOfModPokemonByParent[species][:parent] + "/"
		species = $ListOfModPokemonByParent[species][:id]
		#puts ("loading icon from #{mod} with internal mod id #{species}")
	  end
	  shiny = pokemon.isShiny?
	  girl = pokemon.isFemale? ? "f" : ""
	  form = pokemon.form
	  egg = egg ? "egg" : ""
	  filename=sprintf(mod+"Graphics/Icons/icon%03d%s%s",species,girl,egg) if form == 0
	  filename=sprintf(mod+"Graphics/Icons/icon%03d%s",species,egg) if !pbResolveBitmap(filename)
	  filename=sprintf("Graphics/Icons/iconEgg") if !pbResolveBitmap(filename)
	  filename=sprintf("Graphics/Icons/icon000") if !pbResolveBitmap(filename)
	  iconbitmap = RPG::Cache.load_bitmap(filename)
	  bitmap=Bitmap.new(128,64)
	  x = shiny ? 128 : 0
	  y = form*64
	  y = 0 if iconbitmap.height <= y
		rectangle = Rect.new(x,y,128,64)
	  bitmap.blt(0,0,iconbitmap,rectangle)
	  return bitmap
	end

	def pbIconBitmap(species,form:0,shiny:false,girl:false,egg:false)   # pbpokemonbitmap, but for icons
	  mod = ""
	  if hasModGraphics?(species)
		mod = "Data/Mods/" + $ListOfModPokemonByParent[species][:parent] + "/"
		species = $ListOfModPokemonByParent[species][:id]
	  end
	  egg = egg ? "Egg" : ""
	  filename=sprintf(mod+"Graphics/Icons/icon%s%03d%s",girl,species,egg) if form == 0
	  filename=sprintf(mod+"Graphics/Icons/icon%03d%s",species,egg) if !pbResolveBitmap(filename)
	  filename=sprintf(mod+"Graphics/Icons/iconEgg") if !pbResolveBitmap(filename)
	  filename=sprintf(mod+"Graphics/Icons/icon000") if !pbResolveBitmap(filename)
	  iconbitmap = RPG::Cache.load_bitmap(filename)
	  bitmap=Bitmap.new(128,64)
	  x = shiny ? 128 : 0
	  y = form*64
	  y = 0 if iconbitmap.height <= y
		rectangle = Rect.new(x,y,128,64)
	  return bitmap
	end

	def pbPokemonIconFile(pokemon)
	  bitmapFileName=pbResolveBitmap(sprintf("Graphics/Icons/icon000"))
	  bitmapFileName=pbCheckPokemonIconFiles([pokemon.species, (pokemon.isFemale?), pokemon.isShiny?, (pokemon.form rescue 0), (pokemon.isShadow? rescue false)], pokemon.isEgg?)
	  return bitmapFileName
	end

	def pbCheckPokemonIconFiles(params,egg=false)
	  species=params[0]
	  mod = ""
	  if hasModGraphics?(species)
		mod = "Data/Mods/" + $ListOfModPokemonByParent[species][:parent] + "/"
		species = $ListOfModPokemonByParent[species][:id]
	  end
	  if egg
		formnumber = params[3].to_s rescue 0
		formmodifier = formnumber != 0 && formnumber != "0" ? "_"+formnumber.to_s : ""
		shiny = params[2] ? "s" : ""
		gendermod = params[1] == true ? "f" : ""
		bitmapFileName=sprintf(mod+"Graphics/Icons/icon%03d%s%s%segg",species,gendermod,shiny,formmodifier) rescue nil
		if !pbResolveBitmap(bitmapFileName)
		  bitmapFileName=sprintf(mod+"Graphics/Icons/icon%segg",getConstantName(PBSpecies,species)) rescue nil
		  if !pbResolveBitmap(bitmapFileName) 
			bitmapFileName=sprintf(mod+"Graphics/Icons/icon%03d%segg",species,formmodifier)
			if !pbResolveBitmap(bitmapFileName)
			  bitmapFileName=sprintf(mod+"Graphics/Icons/icon%03degg",species) 
			  if !pbResolveBitmap(bitmapFileName)
				bitmapFileName=sprintf("Graphics/Icons/iconEgg")
			  end
			end
		  end
		end
		return pbResolveBitmap(bitmapFileName)
	  else
		factors=[]
		factors.push([4,params[4],false]) if params[4] && params[4]!=false     # shadow
		factors.push([1,params[1],false]) if params[1] && params[1]!=false     # gender
		factors.push([2,params[2],false]) if params[2] && params[2]!=false     # shiny
		factors.push([3,params[3].to_s,""]) if params[3] && params[3].to_s!="" &&
															params[3].to_s!="0" # form
		tshadow=false
		tgender=false
		tshiny=false
		tform=""
		for i in 0...2**factors.length
		  for j in 0...factors.length
			case factors[j][0]
			  when 1   # gender
				tgender=((i/(2**j))%2==0) ? factors[j][1] : factors[j][2]
			  when 2   # shiny
				tshiny=((i/(2**j))%2==0) ? factors[j][1] : factors[j][2]
			  when 3   # form
				tform=((i/(2**j))%2==0) ? factors[j][1] : factors[j][2]
			  when 4   # shadow
				tshadow=((i/(2**j))%2==0) ? factors[j][1] : factors[j][2]
			end
		  end
		  bitmapFileName=sprintf(mod+"Graphics/Icons/icon%s%s%s%s%s",
			 getConstantName(PBSpecies,species),
			 tgender ? "f" : "",
			 tshiny ? "s" : "",
			 (tform!="" ? "_"+tform : ""),
			 tshadow ? "_shadow" : "") rescue nil
		  ret=pbResolveBitmap(bitmapFileName)
		  return ret if ret
		  bitmapFileName=sprintf("Graphics/Icons/icon%03d%s%s%s%s", species, tgender ? "f" : "", tshiny ? "s" : "", (tform!="" ? "_"+tform : ""), tshadow ? "_shadow" : "")
		  ret=pbResolveBitmap(bitmapFileName)
		  return ret if ret
		end
	  end
	  return pbResolveBitmap(sprintf("Graphics/Icons/icon000"))
	end

	def pbPokemonFootprintFile(species)   # Used by the Pokédex
	  return nil if !species
	  mod = ""
	  if hasModGraphics?(species)
		mod = "Data/Mods/" + $ListOfModPokemonByParent[species][:parent] + "/"
		species = $ListOfModPokemonByParent[species][:id]
	  end
	  bitmapFileName=sprintf(mod+"Graphics/Icons/Footprints/footprint%s",getConstantName(PBSpecies,species)) rescue nil
	  if !pbResolveBitmap(bitmapFileName)
		bitmapFileName=sprintf("Graphics/Icons/Footprints/footprint%03d",species)
	  end
	  return pbResolveBitmap(bitmapFileName)
	end
