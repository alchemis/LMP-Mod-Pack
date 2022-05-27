

drizzle2 = $ModAbilities["DRIZZLE2"]

def drizzle2.onSwitch(battler, battle, onactive)
    if onactive && battle.weather!=PBWeather::RAINDANCE
        if battle.state.effects[PBEffects::HeavyRain]
          battle.pbDisplay(_INTL("There's no relief from this heavy rain!"))
        elsif battle.state.effects[PBEffects::HarshSunlight]
          battle.pbDisplay(_INTL("The extremely harsh sunlight was not lessened at all!"))
        elsif battle.weather==PBWeather::STRONGWINDS && (battle.battlers[0].ability == PBAbilities::DELTASTREAM || battle.battlers[1].ability == PBAbilities::DELTASTREAM ||
          battle.battlers[2].ability == PBAbilities::DELTASTREAM || battle.battlers[3].ability == PBAbilities::DELTASTREAM)
          battle.pbDisplay(_INTL("The mysterious air current blows on regardless!"))
        elsif battle.FE == PBFields::NEWW
          battle.pbDisplay(_INTL("The weather disappeared into space!"))
        elsif battle.FE == PBFields::UNDERWATER
          battle.pbDisplay(_INTL("You're too deep to notice the weather!"))
        else
          if battle.weather==PBWeather::SUNNYDAY
            rainbowhold=5
            rainbowhold=8 if (battler.item == PBItems::DAMPROCK && battler.itemWorks?)
          end
          battle.weather=PBWeather::RAINDANCE
          battle.weatherduration=5
          battle.weatherduration=8 if (battler.item == PBItems::DAMPROCK && battler.itemWorks?)
          battle.weatherduration=-1 if $game_switches[:Gen_5_Weather]==true
          battle.pbCommonAnimation("Rain",nil,nil)
          battle.pbDisplay(_INTL("{1}'s Drizzle made it rain!",battler.pbThis))
        end
    end
end

not_speed_boost = $ModAbilities["NOTSPEEDBOOST"]

def not_speed_boost.endOfTurn(battle,battler)
    if battler.turncount>0
        if !battler.pbTooHigh?(PBStats::SPEED)
          battler.pbIncreaseStatBasic(PBStats::SPEED,1)
          battle.pbCommonAnimation("StatUp",battler,nil)
          battle.pbDisplay(_INTL("{1}'s {2} raised its Speed!",battler.pbThis, PBAbilities.getName(battler.ability)))
        end
    end
end