#we basically just hijack the vanilla graphics loading code to obey our path redirects
#its done in the same order that mods are loaded in, therefore it should work even if several mods want to redirect the same file.

module RPG #overwrite the load_bitmap function to redirect it to the correct file
	module Cache
		def self.load_bitmap(filename, hue = 0)
			path = filename
			#modloader
			$ModList.each{|mod|
				path = mod.path_redirects[path] if mod.path_redirects.keys.include?(path)
			  }
			#/modloader
			
			cached = true
			ret = fromCache(path)
			if !ret
			  if filename == ""
				ret = BitmapWrapper.new(32, 32)
			  else
				ret = BitmapWrapper.new(path)
			  end
			  @cache[path] = ret
			  cached = false
			end
			if hue == 0
			  ret.addRef if cached
			  return ret
			end
			key = [path, hue]
			ret2 = fromCache(key)
			if ret2
			  ret2.addRef
			else
			  ret2 = ret.copy
			  ret2.hue_change(hue)
			  @cache[key] = ret2
			end
			return ret2
		  end
	end
end

def pbResolveBitmap(x)
	return nil if !x
	noext=x.gsub(/\.(bmp|png|gif|jpg|jpeg)$/,"")
	$ModList.each{|mod|
		noext = mod.path_redirects[noext] if mod.path_redirects.keys.include?(noext)
	  }
	filename=nil
	RTP.eachPathFor(noext) {|path|
	   filename=pbTryString(path+".png") if !filename
	   filename=pbTryString(path+".gif") if !filename
	}
	return filename
end