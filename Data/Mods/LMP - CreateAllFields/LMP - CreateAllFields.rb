
################################################################################
# Superheated Terrain
################################################################################

class PokeBattle_Move_600 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if !@battle.canChangeFE?(PBFields::SUPERHEATEDF)
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    @battle.setField(PBFields::SUPERHEATEDF,true)
    @battle.field.duration=5
    @battle.field.duration=8 if (attacker.item == PBItems::AMPLIFIELDROCK)
    @battle.pbDisplay(_INTL("The terrain became superheated!"))
    return 0
  end
end

################################################################################
# Holy Terrain
################################################################################

class PokeBattle_Move_601 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if !@battle.canChangeFE?(PBFields::HOLYF)
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    @battle.setField(PBFields::HOLYF,true)
    @battle.field.duration=5
    @battle.field.duration=8 if (attacker.item == PBItems::AMPLIFIELDROCK)
    @battle.pbDisplay(_INTL("Benedictus Sanctus Spiritus..."))
    return 0
  end
end

################################################################################
# Performance
################################################################################

class PokeBattle_Move_602 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if !@battle.canChangeFE?(PBFields::BIGTOPA)
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    @battle.setField(PBFields::BIGTOPA,true)
    @battle.field.duration=5
    @battle.field.duration=8 if (attacker.item == PBItems::AMPLIFIELDROCK)
    @battle.pbDisplay(_INTL("Now presenting...!"))
    return 0
  end
end

################################################################################
# Checkmate
################################################################################

class PokeBattle_Move_603 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if !@battle.canChangeFE?(PBFields::CHESSB)
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    @battle.setField(PBFields::CHESSB,true)
    @battle.field.duration=5
    @battle.field.duration=8 if (attacker.item == PBItems::AMPLIFIELDROCK)
    @battle.pbDisplay(_INTL("Opening variation set."))
    return 0
  end
end

################################################################################
# Corrupt
################################################################################

class PokeBattle_Move_604 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if !@battle.canChangeFE?(PBFields::CORROSIVEF)
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    @battle.setField(PBFields::CORROSIVEF,true)
    @battle.field.duration=5
    @battle.field.duration=8 if (attacker.item == PBItems::AMPLIFIELDROCK)
    @battle.pbDisplay(_INTL("The field is corrupted!"))
    return 0
  end
end

################################################################################
# Corrosive Mist
################################################################################

class PokeBattle_Move_605 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if !@battle.canChangeFE?(PBFields::CORROSIVEMISTF)
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    @battle.setField(PBFields::CORROSIVEMISTF,true)
    @battle.field.duration=5
    @battle.field.duration=8 if (attacker.item == PBItems::AMPLIFIELDROCK)
    @battle.pbDisplay(_INTL("Corrosive mist settles on the field!"))
    return 0
  end
end

################################################################################
# Desert Terrain
################################################################################

class PokeBattle_Move_606 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if !@battle.canChangeFE?(PBFields::DESERTF)
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    @battle.setField(PBFields::DESERTF,true)
    @battle.field.duration=5
    @battle.field.duration=8 if (attacker.item == PBItems::AMPLIFIELDROCK)
    @battle.pbDisplay(_INTL("The field is rife with sand."))
    return 0
  end
end

################################################################################
# Icy Terrain
################################################################################

class PokeBattle_Move_607 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if !@battle.canChangeFE?(PBFields::ICYF)
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    @battle.setField(PBFields::ICYF,true)
    @battle.field.duration=5
    @battle.field.duration=8 if (attacker.item == PBItems::AMPLIFIELDROCK)
    @battle.pbDisplay(_INTL("The field is covered in ice."))
    return 0
  end
end

################################################################################
# Rocky Terrain
################################################################################

class PokeBattle_Move_608 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if !@battle.canChangeFE?(PBFields::ROCKYF)
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    @battle.setField(PBFields::ROCKYF,true)
    @battle.field.duration=5
    @battle.field.duration=8 if (attacker.item == PBItems::AMPLIFIELDROCK)
    @battle.pbDisplay(_INTL("The field is littered with rocks."))
    return 0
  end
end

################################################################################
# Forest Terrain
################################################################################

class PokeBattle_Move_609 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if !@battle.canChangeFE?(PBFields::FORESTF)
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    @battle.setField(PBFields::FORESTF,true)
    @battle.field.duration=5
    @battle.field.duration=8 if (attacker.item == PBItems::AMPLIFIELDROCK)
    @battle.pbDisplay(_INTL("The field is abound with trees."))
    return 0
  end
end

################################################################################
# Factory Terrain
################################################################################

class PokeBattle_Move_610 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if !@battle.canChangeFE?(PBFields::FACTORYF)
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    @battle.setField(PBFields::FACTORYF,true)
    @battle.field.duration=5
    @battle.field.duration=8 if (attacker.item == PBItems::AMPLIFIELDROCK)
    @battle.pbDisplay(_INTL("Machines whir in the background."))
    return 0
  end
end

################################################################################
# Lay Waste
################################################################################

class PokeBattle_Move_611 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if !@battle.canChangeFE?(PBFields::WASTELAND)
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    @battle.setField(PBFields::WASTELAND,true)
    @battle.field.duration=5
    @battle.field.duration=8 if (attacker.item == PBItems::AMPLIFIELDROCK)
    @battle.pbDisplay(_INTL("The waste is watching..."))
    return 0
  end
end

################################################################################
# Ashen Terrain
################################################################################

class PokeBattle_Move_612 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if !@battle.canChangeFE?(PBFields::ASHENB)
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    @battle.setField(PBFields::ASHENB,true)
    @battle.field.duration=5
    @battle.field.duration=8 if (attacker.item == PBItems::AMPLIFIELDROCK)
    @battle.pbDisplay(_INTL("Ash and sand line the field."))
    return 0
  end
end

################################################################################
# Flood
################################################################################

class PokeBattle_Move_613 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if !@battle.canChangeFE?(PBFields::WATERS)
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    @battle.setField(PBFields::WATERS,true)
    @battle.field.duration=5
    @battle.field.duration=8 if (attacker.item == PBItems::AMPLIFIELDROCK)
    @battle.pbDisplay(_INTL("Water floods the field!"))
    return 0
  end
end

################################################################################
# Mine
################################################################################

class PokeBattle_Move_614 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if !@battle.canChangeFE?(PBFields::CAVE)
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    @battle.setField(PBFields::CAVE,true)
    @battle.field.duration=5
    @battle.field.duration=8 if (attacker.item == PBItems::AMPLIFIELDROCK)
    @battle.pbDisplay(_INTL("The cave echoes dully..."))
    return 0
  end
end

################################################################################
# Murky Water
################################################################################

class PokeBattle_Move_615 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if !@battle.canChangeFE?(PBFields::MURKWATERS)
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    @battle.setField(PBFields::MURKWATERS,true)
    @battle.field.duration=5
    @battle.field.duration=8 if (attacker.item == PBItems::AMPLIFIELDROCK)
    @battle.pbDisplay(_INTL("Tainted water flooded the field!"))
    return 0
  end
end

################################################################################
# Summit
################################################################################

class PokeBattle_Move_616 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if !@battle.canChangeFE?(PBFields::MOUNTAIN)
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    @battle.setField(PBFields::MOUNTAIN,true)
    @battle.field.duration=5
    @battle.field.duration=8 if (attacker.item == PBItems::AMPLIFIELDROCK)
    @battle.pbDisplay(_INTL("Adieu to disappointment and spleen,"))
    return 0
  end
end

################################################################################
# Mirror Maze
################################################################################

class PokeBattle_Move_617 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if !@battle.canChangeFE?(PBFields::MIRRORA)
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    @battle.setField(PBFields::MIRRORA,true)
    @battle.field.duration=5
    @battle.field.duration=8 if (attacker.item == PBItems::AMPLIFIELDROCK)
    @battle.pbDisplay(_INTL("Mirror, mirror, on the field"))
    return 0
  end
end

################################################################################
# Fairy Tale
################################################################################

class PokeBattle_Move_618 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if !@battle.canChangeFE?(PBFields::FAIRYTALEF)
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    @battle.setField(PBFields::FAIRYTALEF,true)
    @battle.field.duration=5
    @battle.field.duration=8 if (attacker.item == PBItems::AMPLIFIELDROCK)
    @battle.pbDisplay(_INTL("Once upon a time..."))
    return 0
  end
end

################################################################################
# Dragon's Lair
################################################################################

class PokeBattle_Move_619 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if !@battle.canChangeFE?(PBFields::DRAGONSD)
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    @battle.setField(PBFields::DRAGONSD,true)
    @battle.field.duration=5
    @battle.field.duration=8 if (attacker.item == PBItems::AMPLIFIELDROCK)
    @battle.pbDisplay(_INTL("If you wish to slay a dragon..."))
    return 0
  end
end
