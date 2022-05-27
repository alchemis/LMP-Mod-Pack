$MegaStones = {
    PBSpecies::CHARIZARD  => [:CHARIZARDITEX, :CHARIZARDITEY],
    PBSpecies::MEWTWO     => [:MEWTWONITEX,   :MEWTWONITEY],
    PBSpecies::VENUSAUR   => [:VENUSAURITE],    PBSpecies::BLASTOISE  => [:BLASTOISINITE],
    PBSpecies::ABOMASNOW  => [:ABOMASITE],      PBSpecies::ABSOL      => [:ABSOLITE],
    PBSpecies::AERODACTYL => [:AERODACTYLITE],  PBSpecies::AGGRON     => [:AGGRONITE],
    PBSpecies::ALAKAZAM   => [:ALAKAZITE],      PBSpecies::AMPHAROS   => [:AMPHAROSITE],
    PBSpecies::BANETTE    => [:BANETTITE],      PBSpecies::BLAZIKEN   => [:BLAZIKENITE],
    PBSpecies::GARCHOMP   => [:GARCHOMPITE],    PBSpecies::GARDEVOIR  => [:GARDEVOIRITE],
    PBSpecies::GENGAR     => [:GENGARITE],      PBSpecies::GYARADOS   => [:GYARADOSITE],
    PBSpecies::HERACROSS  => [:HERACRONITE],    PBSpecies::HOUNDOOM   => [:HOUNDOOMINITE],
    PBSpecies::KANGASKHAN => [:KANGASKHANITE],  PBSpecies::LUCARIO    => [:LUCARIONITE],
    PBSpecies::MANECTRIC  => [:MANECTITE],      PBSpecies::MAWILE     => [:MAWILITE],
    PBSpecies::MEDICHAM   => [:MEDICHAMITE],    PBSpecies::PINSIR     => [:PINSIRITE],  
    PBSpecies::SCIZOR     => [:SCIZORITE],      PBSpecies::TYRANITAR  => [:TYRANITARITE],
    PBSpecies::BEEDRILL   => [:BEEDRILLITE],    PBSpecies::PIDGEOT    => [:PIDGEOTITE],
    PBSpecies::SLOWBRO    => [:SLOWBRONITE],    PBSpecies::STEELIX    => [:STEELIXITE],
    PBSpecies::SCEPTILE   => [:SCEPTILITE],     PBSpecies::SWAMPERT   => [:SWAMPERTITE],
    PBSpecies::SHARPEDO   => [:SHARPEDONITE],   PBSpecies::SABLEYE    => [:SABLENITE],
    PBSpecies::CAMERUPT   => [:CAMERUPTITE],    PBSpecies::ALTARIA    => [:ALTARIANITE],
    PBSpecies::GLALIE     => [:GLALITITE],      PBSpecies::SALAMENCE  => [:SALAMENCITE],
    PBSpecies::METAGROSS  => [:METAGROSSITE],   PBSpecies::LOPUNNY    => [:LOPUNNITE],
    PBSpecies::GALLADE    => [:GALLADITE],      PBSpecies::AUDINO     => [:AUDINITE],
    PBSpecies::DIANCIE    => [:DIANCITE],       PBSpecies::TANGROWTH  => [:PULSEHOLD],
    PBSpecies::LATIAS     => [:LATIASITE],      PBSpecies::LATIOS     => [:LATIOSITE],
  }


def PBStuff.reloadMegastones
        redef_without_warning(:POKEMONTOMEGASTONE, hashArrayToConstant(PBItems,$MegaStones))
        self::POKEMONTOMEGASTONE.default = []
end

def PBStuff.redef_without_warning(const, value)
        self.send(:remove_const, const) if self.const_defined?(const)
        self.const_set(const, value)
end
