def pbGetPreviousForm(species)
  if !species == 1
	  if !$cache.pkmn_evo[species-1].empty? #quick check for most common case
		return species-1 if $cache.pkmn_evo[species-1][0][0] == species
	  end
  end
  for mon in 1...$cache.pkmn_evo.length # Yeah we're checking every pokemon, and you know what? You can't stop me.
    next if $cache.pkmn_evo[mon].empty?
    for method in 0...$cache.pkmn_evo[mon].length
      return mon if $cache.pkmn_evo[mon][method][0] == species
    end
  end
  return species
end