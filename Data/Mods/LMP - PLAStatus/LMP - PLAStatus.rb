def pbPokemonString(pkmn)
  if pkmn.is_a?(PokeBattle_Battler) && !pkmn.pokemon
    return ""
  end
  status=""
  if pkmn.hp<=0
    status=" [FNT]"
  else
    case pkmn.status
      when PBStatuses::SLEEP
        status=" [DRW]"
      when PBStatuses::FROZEN
        status=" [FRB]"
      when PBStatuses::BURN
        status=" [BRN]"
      when PBStatuses::PARALYSIS
        status=" [PAR]"
      when PBStatuses::POISON
        status=" [PSN]"
    end
  end
  return "#{pkmn.name} (Lv. #{pkmn.level})#{status} HP: #{pkmn.hp}/#{pkmn.totalhp}"
end

class PokeBattle_Battler
    def pbTryUseMove(choice,thismove,flags={passedtrying: false, instructed: false})
        return true if flags[:passedtrying]
        # TODO: Return true if attack has been Mirror Coated once already
        return false if !pbObedienceCheck?(choice)
        return false if self.forcedSwitchEarlier
         # Stance Change moved from here to end of method to match Gen VII mechanics.
        # TODO: If being Sky Dropped, return false
        # TODO: Gravity prevents airborne-based moves here
        if @effects[PBEffects::Taunt]>0 && thismove.basedamage==0
          @battle.pbDisplay(_INTL("{1} can't use {2} after the taunt!", pbThis,thismove.name))
          return false
        end
        if @effects[PBEffects::HealBlock]>0 && thismove.isHealingMove?
          @battle.pbDisplay(_INTL("{1} can't use {2} after the Heal Block!", pbThis,thismove.name))
          return false
        end
        if thismove.isSoundBased? && self.effects[PBEffects::ThroatChop]>0
          @battle.pbDisplay(_INTL("{1} can't use sound-based moves because of it's throat damage!",pbThis))
          return false
        end
        if @effects[PBEffects::Torment] && !flags[:instructed] && thismove.id==@lastMoveUsed &&
           thismove.id!=@battle.struggle.id
          @battle.pbDisplay(_INTL("{1} can't use the same move in a row due to the torment!",
             pbThis))
          return false
        end
        if pbOpposing1.effects[PBEffects::Imprison] && !@simplemove
          if thismove.id==pbOpposing1.moves[0].id || thismove.id==pbOpposing1.moves[1].id || thismove.id==pbOpposing1.moves[2].id || thismove.id==pbOpposing1.moves[3].id
            @battle.pbDisplay(_INTL("{1} can't use the sealed {2}!",
               pbThis,thismove.name))
            PBDebug.log("[#{pbOpposing1.pbThis} has: #{pbOpposing1.moves[0].id}, #{pbOpposing1.moves[1].id},#{pbOpposing1.moves[2].id} #{pbOpposing1.moves[3].id}]") if $INTERNAL
            return false
          end
        end
        if pbOpposing2.effects[PBEffects::Imprison] && !@simplemove
          if thismove.id==pbOpposing2.moves[0].id || thismove.id==pbOpposing2.moves[1].id || thismove.id==pbOpposing2.moves[2].id || thismove.id==pbOpposing2.moves[3].id
            @battle.pbDisplay(_INTL("{1} can't use the sealed {2}!", pbThis,thismove.name))
            PBDebug.log("[#{pbOpposing2.pbThis} has: #{pbOpposing2.moves[0].id}, #{pbOpposing2.moves[1].id},#{pbOpposing2.moves[2].id} #{pbOpposing2.moves[3].id}]") if $INTERNAL
            return false
          end
        end
        if @effects[PBEffects::Disable]>0 && thismove.id==@effects[PBEffects::DisableMove]
          @battle.pbDisplayPaused(_INTL("{1}'s {2} is disabled!",pbThis,thismove.name))
          return false
        end
        if self.ability == PBAbilities::TRUANT && @effects[PBEffects::Truant]
          @battle.pbDisplay(_INTL("{1} is loafing around!",pbThis))
          return false
        end
        if choice[1]==-2 # Battle Palace
          @battle.pbDisplay(_INTL("{1} appears incapable of using its power!",pbThis))
          return false
        end
        if @effects[PBEffects::HyperBeam]>0
          @battle.pbDisplay(_INTL("{1} must recharge!",pbThis))
          return false
        end
        # if self.status==PBStatuses::SLEEP && !@simplemove
        #   self.statusCount-=1
        #   self.statusCount-=1 if self.ability == PBAbilities::EARLYBIRD
        #   if self.statusCount<=0
        #     self.pbCureStatus
        #   else
        #     self.pbContinueStatus
        #     if !thismove.pbCanUseWhileAsleep? # Snore/Sleep Talk
        #       return false
        #     end
        #   end
        # end
        #MODDED: SLEEP WORKS LIKE PARALYSIS
        if self.status==PBStatuses::SLEEP && !@simplemove && !thismove.zmove
            if @battle.pbRandom(3)==0
              pbContinueStatus
              return false if !thismove.pbCanUseWhileAsleep?
            end
          end
        # if self.status==PBStatuses::FROZEN
        #   if thismove.canThawUser?
        #     self.pbCureStatus(false)
        #     @battle.pbDisplay(_INTL("{1} was defrosted by {2}!",pbThis,thismove.name))
        #     pbCheckForm
        #   elsif @battle.pbRandom(10)<2
        #     self.pbCureStatus
        #     pbCheckForm
        #   elsif !thismove.canThawUser?
        #     self.pbContinueStatus
        #     return false
        #   end
        # end
    
        if @effects[PBEffects::Flinch]
          @effects[PBEffects::Flinch]=false
          if @battle.FE == PBFields::ROCKYF
            if !(self.ability == PBAbilities::STEADFAST) && !(self.ability == PBAbilities::STURDY) && !(self.ability == PBAbilities::INNERFOCUS) && (self.stages[PBStats::DEFENSE] < 1)
              @battle.pbDisplay(_INTL("{1} was knocked into a rock!",pbThis))
              damage=[1,(self.totalhp/4.0).floor].max
              if damage>0
                @battle.scene.pbDamageAnimation(self,0)
                self.pbReduceHP(damage)
              end
              if self.hp<=0
                self.pbFaint
                return false
              end
            end
          end
          if self.ability == PBAbilities::INNERFOCUS
            @battle.pbDisplay(_INTL("{1} won't flinch because of its {2}!", self.pbThis,PBAbilities.getName(self.ability)))
          elsif self.stages[PBStats::DEFENSE] >= 1 && @battle.FE == PBFields::ROCKYF
            @battle.pbDisplay(_INTL("{1} won't flinch because of its bolstered Defenses!", self.pbThis,PBAbilities.getName(self.ability)))
          else
            @battle.pbDisplay(_INTL("{1} flinched and couldn't move!",self.pbThis))
            if self.ability == PBAbilities::STEADFAST
              if pbCanIncreaseStatStage?(PBStats::SPEED)
                pbIncreaseStat(PBStats::SPEED,1,statmessage: false)
                @battle.pbDisplay(_INTL("{1}'s {2} raised its speed!", self.pbThis,PBAbilities.getName(self.ability)))
              end
            end
            return false
          end
        end
    
        if @effects[PBEffects::Confusion]>0 && !@simplemove
          @effects[PBEffects::Confusion]-=1
          if @effects[PBEffects::Confusion]<=0
            pbCureConfusion
          else
            pbContinueConfusion
            if @battle.pbRandom(3)==0
              @battle.pbDisplay(_INTL("It hurt itself from its confusion!"))
              pbConfusionDamage
              return false
            end
          end
        end
    
        if @effects[PBEffects::Attract]>=0 && !@simplemove && !thismove.zmove
          pbAnnounceAttract(@battle.battlers[@effects[PBEffects::Attract]])
          if @battle.pbRandom(2)==0
            pbContinueAttract
            return false
          end
        end
        if self.status==PBStatuses::PARALYSIS && !@simplemove && !thismove.zmove
          if @battle.pbRandom(4)==0
            pbContinueStatus
            return false
          end
        end
        # UPDATE 2/13/2014
        # implementing Protean
        protype=thismove.type
        if (thismove.id == PBMoves::HIDDENPOWER)
          protype = pbHiddenPower(self.pokemon)
        end
        if (self.ability == PBAbilities::PROTEAN || self.ability == PBAbilities::LIBERO) && thismove.id != PBMoves::STRUGGLE
          prot1 = self.type1
          prot2 = self.type2
          if !self.pbHasType?(protype) || (defined?(prot2) && prot1 != prot2)
            self.type1=protype
            self.type2=protype
            typename=PBTypes.getName(protype)
            @battle.pbDisplay(_INTL("{1} had its type changed to {3}!",pbThis,PBAbilities.getName(self.ability),typename))
          end
        end # end of update
        if (self.ability == PBAbilities::STANCECHANGE)
          pbCheckForm(thismove)
        end
        flags[:passedtrying]=true
        return true
    end
    def pbFreeze
        self.status=PBStatuses::FROZEN
        self.statusCount=0
        @battle.pbCommonAnimation("Frozen",self,nil)
    end
    def pbProcessTurn(choice)
        # Can't use a move if fainted
        return if self.isFainted?
        # Wild roaming Pokémon always flee if possible
        if !@battle.opponent && @battle.pbIsOpposing?(self.index) && @battle.rules["alwaysflee"] && @battle.pbCanRun?(self.index) &&
             $PokemonTemp.roamerIndex && $game_variables[RoamingSpecies[$PokemonTemp.roamerIndex][:variable]]<=@battle.turncount
          pbBeginTurn(choice)
          pbSEPlay("escape",100)
          @battle.pbDisplay(_INTL("{1} fled!",self.pbThis))
          @battle.decision=3
          pbEndTurn(choice)
          return
        end
        # If this battler's action for this round wasn't "use a move"
        if choice[0]!=1
          # Clean up effects that end at battler's turn
          pbBeginTurn(choice)
          pbEndTurn(choice)
          return
        end
        # Turn is skipped if Pursuit was used during switch
        if @effects[PBEffects::Pursuit]
          @effects[PBEffects::Pursuit]=false
          pbCancelMoves
          pbEndTurn(choice)
          @battle.pbJudgeSwitch
          return
        end
        # Use the move
        if choice[2].zmove && !@effects[PBEffects::Flinch] && (choice[2].pbCanUseWhileAsleep? || @statusCount==1 || (@statusCount==2 && self.ability == PBAbilities::EARLYBIRD))
        #in previous OR block #@status!=PBStatuses::SLEEP || 
        #   if self.status==PBStatuses::SLEEP
        #     self.statusCount-=1
        #     self.statusCount-=1 if self.ability == PBAbilities::EARLYBIRD
        #     if self.statusCount<=0
        #       self.pbCureStatus
        #     end
        #   end
        #   if self.status==PBStatuses::FROZEN
        #     if @battle.pbRandom(10)<2
        #       self.pbCureStatus
        #       pbCheckForm
        #     else #failed while frozen
        #       self.pbContinueStatus
        #       choice[2].zmove=false
        #       @battle.previousMove = @battle.lastMoveUsed
        #       @previousMove = @lastMoveUsed
        #       pbBeginTurn(choice)
        #       pbCancelMoves
        #       @battle.pbGainEXP
        #       pbEndTurn(choice)
        #       @battle.pbJudgeSwitch
        #       return
        #     end
        #   end
          #choice[2].zmove=false
          @battle.lastMoveUsed = -1
          @lastMoveUsed = -1
          @battle.previousMove = @battle.lastMoveUsed
          @previousMove = @lastMoveUsed
          @battle.pbUseZMove(self.index,choice[2],self.item)
          choice[2].zmove = false
        else
          choice[2].zmove=false if choice[2].zmove # For flinches
          @battle.previousMove = @battle.lastMoveUsed
          @previousMove = @lastMoveUsed
          PBDebug.logonerr{
             pbUseMove(choice, {specialusage: choice[2]==@battle.struggle})
          }
          if !@battle.isOnline? #perry aimemory
            @battle.ai.addMoveToMemory(self,choice[2])
          end
        end
    #   @battle.pbDisplayPaused("After: [#{@lastMoveUsedSketch},#{@lastMoveUsed}]")
    end
    def pbContinueStatus(showAnim=true)
        case self.status
          when PBStatuses::SLEEP
            @battle.pbCommonAnimation("Sleep",self,nil)
            @battle.pbDisplay(_INTL("{1} is dozing off! It can't move!",pbThis))
          when PBStatuses::POISON
            @battle.pbCommonAnimation("Poison",self,nil)
            @battle.pbDisplay(_INTL("{1} is hurt by poison!",pbThis))
          when PBStatuses::BURN
            @battle.pbCommonAnimation("Burn",self,nil)
            @battle.pbDisplay(_INTL("{1} is hurt by its burn!",pbThis))
          when PBStatuses::PARALYSIS
            @battle.pbCommonAnimation("Paralysis",self,nil)
            @battle.pbDisplay(_INTL("{1} is paralyzed! It can't move!",pbThis)) 
          when PBStatuses::FROZEN
            @battle.pbCommonAnimation("Frozen",self,nil)
            @battle.pbDisplay(_INTL("{1} is hurt by its frostbite!",pbThis))
        end
    end
    def pbProcessMoveAgainstTarget(thismove,user,target,numhits,flags={totaldamage: 0},nocheck=false,alltargets=nil,showanimation=true)
        realnumhits=0
        flags[:totaldamage] = 0 if !flags[:totaldamage]
        totaldamage=flags[:totaldamage]
        destinybond=false
        wimpcheck=false
        berserkcheck=false
        if target
          aboveHalfHp = target.hp>(target.totalhp/2.0).floor
        end
    
        for i in 0...numhits
        #   if user.status==PBStatuses::SLEEP && !thismove.pbCanUseWhileAsleep? && !@simplemove
        #     realnumhits = i
        #     break
        #   end
          if target
            innardsOutHp = target.hp
          end
          if !target
           tantrumCheck = thismove.pbEffect(user,target,i,alltargets,showanimation)
           if tantrumCheck == -1
             user.effects[PBEffects::Tantrum]=true
           else
             user.effects[PBEffects::Tantrum]=false
           end
            return
          end
          # Check success (accuracy/evasion calculation)
          if !nocheck && !pbSuccessCheck(thismove,user,target,flags,i==0 || thismove.function==0xBF) # Triple Kick
           if thismove.function==0xC9 || thismove.function==0xCA || thismove.function==0xCB ||
              thismove.function==0xCC || thismove.function==0xCD || thismove.function==0xCE #Sprites for two turn moves
              @battle.scene.pbUnVanishSprite(user)
            end
            if thismove.function==0xBF && realnumhits>0   # Triple Kick
              break   # Considered a success if Triple Kick hits at least once
            elsif thismove.function==0x10B   # Hi Jump Kick, Jump Kick
              #TODO: Not shown if message is "It doesn't affect XXX..."
              @battle.pbDisplay(_INTL("{1} kept going and crashed!",user.pbThis))
              damage=[1,(user.totalhp/2.0).floor].max
              if (user.ability == PBAbilities::MAGICGUARD)
                damage=0
              end
              if damage>0
                @battle.scene.pbDamageAnimation(user,0)
                user.pbReduceHP(damage)
              end
              user.pbFaint if user.isFainted?
              # Rocky Field Crash
            elsif @battle.FE == PBFields::ROCKYF  && (thismove.flags&0x01)!=0 &&
             !(user.ability == PBAbilities::ROCKHEAD) && (!(target.effects[PBEffects::SpikyShield] || target.effects[PBEffects::Protect] || target.effects[PBEffects::KingsShield] ||
              target.effects[PBEffects::BanefulBunker] || target.effects[PBEffects::Obstruct]))
              @battle.pbDisplay(_INTL("{1} hit a rock instead!",user.pbThis))
              damage=[1,(user.totalhp/8.0).floor].max
              if damage>0
                @battle.scene.pbDamageAnimation(user,0)
                user.pbReduceHP(damage)
              end
              user.pbFaint if user.isFainted?
            elsif @battle.FE == PBFields::MIRRORA && (thismove.flags&0x01)!=0
              @battle.pbDisplay(_INTL("{1} hit a mirror instead!",user.pbThis))
              @battle.pbDisplay(_INTL("The mirror shattered!",user.pbThis))
              damage=[1,(user.totalhp/4.0).floor].max
              if damage>0
                @battle.scene.pbDamageAnimation(user,0)
                user.pbReduceHP(damage)
              end
              user.pbFaint if user.isFainted?
              user.pbReduceStat(PBStats::EVASION,1) if user.stages[PBStats::EVASION] > 0
            end
            if user.hasWorkingItem(:BLUNDERPOLICY) && user.missAcc
              if user.pbCanIncreaseStatStage?(PBStats::SPEED)
                user.pbIncreaseStatBasic(PBStats::SPEED,1)
                @battle.pbCommonAnimation("StatUp",user)
                @battle.pbDisplay(_INTL("The Blunder Policy raised #{user.pbThis}'s Speed!"))
                user.pbDisposeItem(false)
              end
            end
            user.effects[PBEffects::Tantrum]=true
            user.effects[PBEffects::Outrage]=0 if thismove.function==0xD2 # Outrage
            user.effects[PBEffects::Rollout]=0 if thismove.function==0xD3 # Rollout
            user.effects[PBEffects::FuryCutter]=0 if thismove.function==0x91 # Fury Cutter
            user.effects[PBEffects::EchoedVoice]+=1 if thismove.function==0x92 # Echoed Voice
            user.effects[PBEffects::EchoedVoice]=0 if thismove.function!=0x92 # Not Echoed Voice
            user.effects[PBEffects::Stockpile]=0 if thismove.function==0x113 # Spit Up
            return 0
          end
          if thismove.function==0x91 # Fury Cutter
            user.effects[PBEffects::FuryCutter]+=1 if user.effects[PBEffects::FuryCutter]<3
          else
            user.effects[PBEffects::FuryCutter]=0
          end
          if thismove.function==0x92 # Echoed Voice
            user.effects[PBEffects::EchoedVoice]+=1 if user.effects[PBEffects::EchoedVoice]<5
          else
            user.effects[PBEffects::EchoedVoice]=0
          end
          # This hit will happen; count it
          realnumhits+=1
          # Damage calculation and/or main effect
          revanish=false
          if target.vanished && !((thismove.function==0xC9 || thismove.function==0xCA || thismove.function==0xCB ||
              thismove.function==0xCC || thismove.function==0xCD) && !user.vanished)
            revanish=true
            revanish=false if thismove.function==0xCE
            revanish=false if thismove.function==0x11C
            revanish=false if (thismove.function==0x10D && !user.pbHasType?(:GHOST)) # Curse
            @battle.scene.pbUnVanishSprite(target) unless ((thismove.function==0x10D && !user.pbHasType?(:GHOST)) || thismove.function==0xCE) # Curse
          end
          # Special Move Effects are applied here
          damage = thismove.pbEffect(user,target,i,alltargets,showanimation)
          user.effects[PBEffects::Tantrum]= (damage == -1)
          totaldamage += damage if damage && damage > 0
          if user.isFainted?
            user.pbFaint # no return
          end
          if revanish && !(target.isFainted?)
            @battle.pbCommonAnimation("Fade out",target,nil)
            @battle.scene.pbVanishSprite(target)
          end
          if numhits>1 && target.damagestate.calcdamage<=0
            unless thismove.id == PBMoves::ROCKBLAST && @battle.FE == PBFields::CRYSTALC
              return
            end
          end
          @battle.pbJudgeCheckpoint(user,thismove)
    
          # Additional effect
          if target.damagestate.calcdamage>0 && ((!target.hasWorkingAbility(:SHIELDDUST) || target.moldbroken) || thismove.hasFlags?("m")) && !user.hasWorkingAbility(:SHEERFORCE)
            addleffect=thismove.addlEffect
            addleffect*=2 if user.hasWorkingAbility(:SERENEGRACE) || @battle.FE == PBFields::RAINBOWF
            addleffect=100 if $DEBUG && Input.press?(Input::CTRL) && !@battle.isOnline?
            addleffect=100 if thismove.id == PBMoves::MIRRORSHOT && @battle.FE == PBFields::MIRRORA
            if @battle.pbRandom(100)<addleffect
              thismove.pbAdditionalEffect(user,target)
            end
            if @battle.pbRandom(100)<addleffect
              thismove.pbSecondAdditionalEffect(user,target)
            end
    
            # Gulp Missile
            if (self.species == PBSpecies::CRAMORANT) && self.ability == PBAbilities::GULPMISSILE && !self.isFainted? && (thismove.id == 538 || thismove.id == 541) # Surf or Dive
              if self.form==0
                if self.hp*2.0 > self.totalhp
                  self.form = 1 # Gulping Form
                else
                  self.form = 2 # Gorging Form
                end
              end
              transformed = true
              pbUpdate(false)
              @battle.scene.pbChangePokemon(self,@pokemon)
              if self.form==1
                @battle.pbDisplay(_INTL("{1} transformed into Gulping Forme!",pbThis))
              elsif self.form==2
                @battle.pbDisplay(_INTL("{1} transformed into Gorging Forme!",pbThis))
              end
            end
          end
    
          # Corrosion random status
          if user.ability == PBAbilities::CORROSION && @battle.FE == PBFields::WASTELAND && damage > 0
            if @battle.pbRandom(10)==0
              case @battle.pbRandom(4)
                when 0 then target.pbBurn(user)       if target.pbCanBurn?(false)
                when 1 then target.pbPoison(user)     if target.pbCanPoison?(false)
                when 2 then target.pbParalyze(user)   if target.pbCanParalyze?(false)
                when 3 then target.pbFreeze           if target.pbCanFreeze?(false)
              end
            end
          end
    
          # Ability effects
          pbEffectsOnDealingDamage(thismove,user,target,damage,innardsOutHp)
    
          # Berserk
          if !target.isFainted? && aboveHalfHp && target.hp<=(target.totalhp/2.0).floor && !berserkcheck
            if target.hasWorkingAbility(:BERSERK)
              if !pbTooHigh?(PBStats::SPATK)
                target.pbIncreaseStatBasic(PBStats::SPATK,1)
                @battle.pbCommonAnimation("StatUp",target,nil)
                @battle.pbDisplay(_INTL("{1}'s Berserk boosted its Special Attack!",
                target.pbThis))
                berserkcheck=true
              end
            end
          end
          # Emergency Exit / Wimp Out
          if !target.isFainted? && aboveHalfHp && (target.hp + target.pbBerryRecoverAmount)<=(target.totalhp/2.0).floor
            if (target.abilityWorks? && (target.ability == PBAbilities::EMERGENCYEXIT || target.ability == PBAbilities::WIMPOUT)) && 
              ((@battle.pbCanChooseNonActive?(target.index) && !@battle.pbAllFainted?(@battle.pbParty(target.index))) || @battle.pbIsWild?)
              if !wimpcheck
                @battle.pbDisplay(_INTL("{1} tactically retreated!",target.pbThis)) if target.ability == PBAbilities::EMERGENCYEXIT
                @battle.pbDisplay(_INTL("{1} wimped out!",target.pbThis)) if target.ability == PBAbilities::WIMPOUT
                wimpcheck=true
              end
              @battle.pbClearChoices(target.index)
              if @battle.pbIsWild? && !(@battle.cantescape || $game_switches[:Never_Escape] == true)
                @battle.decision=3 # Set decision to escaped
              else
                target.userSwitch = true
                if user.userSwitch
                  @battle.scene.pbUnVanishSprite(user)
                  user.userSwitch=false
                end
              end
            end
          end
          # Grudge
          if !user.isFainted? && target.isFainted?
            if target.effects[PBEffects::Grudge] && target.pbIsOpposing?(user.index)
              pbSetPP(thismove,thismove.pp=0)
              @battle.pbDisplay(_INTL("{1}'s {2} lost all its PP due to the grudge!",
                 user.pbThis,thismove.name))
            end
          end
          # Throat Spray
          if user.hasWorkingItem(:THROATSPRAY) && thismove.isSoundBased? && user.hp>0
            if user.pbCanIncreaseStatStage?(PBStats::SPATK)
              user.pbIncreaseStatBasic(PBStats::SPATK,1)
              @battle.pbCommonAnimation("StatUp",user,nil)
              @battle.pbDisplay(_INTL("The Throat Spray raised #{user.pbThis}'s Sp.Atk!"))
              user.pbDisposeItem(false)
            end
          end
          # Eject Pack
          if target.hasWorkingItem(:EJECTPACK) && target.statLowered
            if !target.isFainted? && @battle.pbCanChooseNonActive?(target.index) && !@battle.pbAllFainted?(@battle.pbParty(target.index))
              @battle.pbDisplay(_INTL("#{target.pbThis}'s Eject Pack activates!"))
              target.pbDisposeItem(false,false)
              @battle.pbClearChoices(target.index)
              target.userSwitch = true
            end
          end
          if target.isFainted?
              ###YUMIL - 1 - NPC REACTION MOD - START  
             if @battle.recorded == true
               $battleDataArray.last().pokemonFaintedAnEnemy(@battle.battlers,user,target,thismove)
             end
             ### YUMIL - 1 - NPC REACTION MOD - END 
            destinybond=destinybond || target.effects[PBEffects::DestinyBond]
          end
          ###YUMIL - 2 - NPC REACTION MOD - START 
          #user.pbFaint if user.isFainted? # no return
          if user.isFainted?
            user.pbFaint
            if @battle.recorded == true
              $battleDataArray.last().pokemonFaintedAnEnemy(@battle.battlers,target,user,thismove)
            end
          end
            ### YUMIL - 2 - NPC REACTION MOD - END 
          break if user.isFainted?
          break if target.isFainted?
          # Make the target flinch
          if target.damagestate.calcdamage>0 && !target.damagestate.substitute
            if (!(target.ability == PBAbilities::SHIELDDUST) || target.moldbroken) || thismove.hasFlags?("m")
              if (user.hasWorkingItem(:KINGSROCK) || user.hasWorkingItem(:RAZORFANG)) &&
               thismove.canKingsRock? # && target.status!=PBStatuses::SLEEP && target.status!=PBStatuses::FROZEN #Gen 2 only thing #perry
                if @battle.pbRandom(10)==0
                  target.effects[PBEffects::Flinch]=true
                end
              elsif user.hasWorkingAbility(:STENCH) &&
               thismove.function!=0x09 && # Thunder Fang
               thismove.function!=0x0B && # Fire Fang
               thismove.function!=0x0E && # Ice Fang
               thismove.function!=0x0F && # flinch-inducing moves
               thismove.function!=0x10 && # Stomp
               thismove.function!=0x11 && # Snore
               thismove.function!=0x12 && # Fake Out
               thismove.function!=0x78 && # Twister
               thismove.function!=0xC7 #&& # Sky Attack
                if (@battle.pbRandom(10)==0 || ((@battle.FE == PBFields::WASTELAND || @battle.FE == PBFields::MURKWATERS) && @battle.pbRandom(10) < 2))
                  target.effects[PBEffects::Flinch]=true
                end
              end
            end
          end
          if target.damagestate.calcdamage>0 && !target.isFainted?
            # Defrost
            if (thismove.pbType(user) == PBTypes::FIRE || thismove.function==0x0A) && target.status==PBStatuses::FROZEN && !(user.hasWorkingAbility(:PARENTALBOND) && i==0)
              target.pbCureStatus
            end
            # Rage
            if target.effects[PBEffects::Rage] && target.pbIsOpposing?(user.index)
              # TODO: Apparently triggers if opposing Pokémon uses Future Sight after a Future Sight attack
              if target.pbCanIncreaseStatStage?(PBStats::ATTACK)
                target.pbIncreaseStatBasic(PBStats::ATTACK,1)
                @battle.pbCommonAnimation("StatUp",target,nil)
                @battle.pbDisplay(_INTL("{1}'s rage is building!",target.pbThis))
              end
            end
          end
          user.pbFaint if user.isFainted? # no return
          break if user.isFainted?
          break if target.isFainted?
          # Berry check (maybe just called by ability effect, since only necessary Berries are checked)
          for j in 0...4
            @battle.battlers[j].pbBerryCureCheck
          end
          if target.damagestate.calcdamage<=0
            unless thismove.id == PBMoves::ROCKBLAST && @battle.FE == PBFields::CRYSTALC #rock blast on crystal cavern
              break
            end
          end
        end
        flags[:totaldamage]+=totaldamage if totaldamage>0
        # Battle Arena only - attack is successful
        @battle.successStates[user.index].useState=2
        @battle.successStates[user.index].typemod=target.damagestate.typemod
        # Type effectiveness
        if numhits>1
          if target.damagestate.typemod>4
            @battle.pbDisplay(_INTL("It's super effective!"))
          elsif target.damagestate.typemod>=1 && target.damagestate.typemod<4
            @battle.pbDisplay(_INTL("It's not very effective..."))
          end
          if realnumhits==1
            @battle.pbDisplay(_INTL("Hit {1} time!",realnumhits))
          else
            @battle.pbDisplay(_INTL("Hit {1} times!",realnumhits))
          end
        end
        # Faint if 0 HP
        target.pbFaint if target.isFainted?
        user.pbFaint if user.isFainted? # no return
        if target.isFainted?
          if user.hasWorkingAbility(:MOXIE) && user.hp>0 && target.hp<=0
            if !user.pbTooHigh?(PBStats::ATTACK)
              @battle.pbCommonAnimation("StatUp",self,nil)
              user.pbIncreaseStatBasic(PBStats::ATTACK,1)
              @battle.pbDisplay(_INTL("{1}'s Moxie raised its Attack!",user.pbThis))
            end
          end
        end
        # TODO: If Poison Point, etc. triggered above, user's Synchronize somehow triggers
        #       here even if condition is removed before now [true except for Triple Kick]
        # Destiny Bond
        if !user.isFainted? && target.isFainted?
          if destinybond && target.pbIsOpposing?(user.index)
            @battle.pbDisplay(_INTL("{1} took its attacker down with it!",target.pbThis))
            user.pbReduceHP(user.hp)
            user.pbFaint # no return
            @battle.pbJudgeCheckpoint(user)
          end
        end
        # Color Change
        movetype=thismove.pbType(user)
        if target.hasWorkingAbility(:COLORCHANGE) && totaldamage>0 && !PBTypes.isPseudoType?(movetype) && !target.pbHasType?(movetype)
          target.type1=movetype
          target.type2=movetype
          @battle.pbDisplay(_INTL("{1}'s {2} made it the {3} type!",target.pbThis,
             PBAbilities.getName(target.ability),PBTypes.getName(movetype)))
        end
        # Eject Button
        if target.hasWorkingItem(:EJECTBUTTON) && !target.damagestate.substitute && target.damagestate.calcdamage>0
          if !target.isFainted? && @battle.pbCanChooseNonActive?(target.index) && !@battle.pbAllFainted?(@battle.pbParty(target.index))
            @battle.pbDisplay(_INTL("#{target.pbThis}'s Eject Button activates!"))
            target.pbDisposeItem(false,false)
           # @battle.pbDisplay(_INTL("{1} went back to {2}!",target.pbThis,@battle.pbGetOwner(target.index).name))
            @battle.pbClearChoices(target.index)
            target.userSwitch = true
          end
        end
        # Berry check
        for j in 0...4
          @battle.battlers[j].pbBerryCureCheck
        end
        return damage
      end
end



class PokeBattle_Move
    def pbCalcDamage(attacker,opponent,options=0, hitnum: 0)
        opponent.damagestate.critical=false
        opponent.damagestate.typemod=0
        opponent.damagestate.calcdamage=0
        opponent.damagestate.hplost=0
        return 0 if @basedamage==0
        if (options&NOCRITICAL)==0
          critchance = pbCritRate?(attacker,opponent)
          if critchance >= 0
            ratios=[24,8,2,1]
            opponent.damagestate.critical= @battle.pbRandom(ratios[critchance])==0
          end
        end
        stagemul=[2,2,2,2,2,2,2,3,4,5,6,7,8]
        stagediv=[8,7,6,5,4,3,2,2,2,2,2,2,2]
        if (options&NOTYPE)==0
          type=pbType(attacker)
        else
          type=-1 # Will be treated as physical
        end
        ##### Calcuate base power of move #####
        basedmg=@basedamage # From PBS file
        basedmg=pbBaseDamage(basedmg,attacker,opponent) # Some function codes alter base power
        damagemult=0x1000
        #classic prep stuff
        attitemworks = attacker.itemWorks?(true)
        oppitemworks = opponent.itemWorks?(true)
        if attacker.ability == PBAbilities::TECHNICIAN
          if basedmg<=60
            damagemult=(damagemult*1.5).round
          elsif @battle.FE == PBFields::FACTORYF && basedmg<=80
            damagemult=(damagemult*1.5).round
          end
        elsif attacker.ability == PBAbilities::STRONGJAW
          damagemult=(damagemult*1.5).round if (PBStuff::BITEMOVE).include?(@id)
        elsif attacker.ability == PBAbilities::TOUGHCLAWS && (@flags&0x01)!=0 # Makes direct contact
          damagemult=(damagemult*1.3).round
        elsif attacker.ability == PBAbilities::IRONFIST && isPunchingMove?
          damagemult=(damagemult*1.2).round
        elsif attacker.ability == PBAbilities::RECKLESS
          if @function==0xFA ||  # Take Down, etc.
            @function==0xFB ||  # Double-Edge, etc.
            @function==0xFC ||  # Head Smash
            @function==0xFD ||  # Volt Tackle
            @function==0xFE ||  # Flare Blitz
            @function==0x10B || # Jump Kick, Hi Jump Kick
            @function==0x130    # Shadow End
            damagemult=(damagemult*1.2).round
          end
        elsif attacker.ability == PBAbilities::FLAREBOOST && (attacker.status==PBStatuses::BURN || @battle.FE == PBFields::BURNINGF) && pbIsSpecial?(type)
          damagemult=(damagemult*1.5).round
        elsif attacker.ability == PBAbilities::TOXICBOOST && (attacker.status==PBStatuses::POISON || @battle.FE == PBFields::CORROSIVEF || @battle.FE == PBFields::CORROSIVEMISTF || @battle.FE == PBFields::WASTELAND || @battle.FE == PBFields::MURKWATERS) && pbIsPhysical?(type)
          damagemult=(damagemult*1.5).round
        elsif attacker.ability == PBAbilities::PUNKROCK && isSoundBased?
          damagemult=(damagemult*1.3).round
        elsif attacker.ability == PBAbilities::RIVALRY && attacker.gender!=2 && opponent.gender!=2
          if attacker.gender==opponent.gender
            damagemult=(damagemult*1.25).round
          else
            damagemult=(damagemult*0.75).round
          end
        elsif (attacker.ability == PBAbilities::MEGALAUNCHER)
          if @id == PBMoves::AURASPHERE || @id == PBMoves::DRAGONPULSE || @id == PBMoves::DARKPULSE || @id == PBMoves::WATERPULSE || @id == PBMoves::ORIGINPULSE
            damagemult=(damagemult*1.5).round
          end
        elsif attacker.ability == PBAbilities::SANDFORCE && (@battle.pbWeather==PBWeather::SANDSTORM || @battle.FE == PBFields::DESERTF|| @battle.FE == PBFields::ASHENB) && (type == PBTypes::ROCK || type == PBTypes::GROUND || type == PBTypes::STEEL)
          damagemult=(damagemult*1.3).round
        elsif attacker.ability == PBAbilities::ANALYTIC && (@battle.battlers.find_all {|battler| battler && battler.hp > 0 && !battler.hasMovedThisRound? }).length == 0
          damagemult = (damagemult*1.3).round
        elsif attacker.ability == PBAbilities::SHEERFORCE && @addlEffect>0
          damagemult=(damagemult*1.3).round
        elsif @type == PBTypes::NORMAL
          if attacker.ability == PBAbilities::AERILATE
            if @battle.FE == PBFields::MOUNTAIN || @battle.FE == PBFields::SNOWYM # Snowy Mountain && Mountain
              damagemult=(damagemult*1.5).round
            else
              damagemult=(damagemult*1.2).round
            end
          elsif attacker.ability == PBAbilities::GALVANIZE
            if @battle.FE == PBFields::ELECTRICT || @battle.FE == PBFields::FACTORYF # Electric or Factory Fields
              damagemult=(damagemult*1.5).round
            elsif @battle.FE == PBFields::SHORTCIRCUITF # Short-Circuit Field
              damagemult=(damagemult*2).round
            else
              damagemult=(damagemult*1.2).round
            end
          elsif attacker.ability == PBAbilities::PIXILATE
            if @battle.FE == PBFields::MISTYT # Misty Field
              damagemult=(damagemult*1.5).round
            else
              damagemult=(damagemult*1.2).round
            end
          elsif attacker.ability == PBAbilities::DUSKILATE
            damagemult=(damagemult*1.2).round
          elsif attacker.ability == PBAbilities::REFRIGERATE
            if @battle.FE == PBFields::ICYF || @battle.FE == PBFields::SNOWYM # Icy Fields
              damagemult=(damagemult*1.5).round
            else
              damagemult=(damagemult*1.2).round
            end
          end
        elsif attacker.ability == PBAbilities::NORMALIZE
          damagemult=(damagemult*1.2).round
        end
        if opponent.ability == PBAbilities::HEATPROOF && !(opponent.moldbroken) && type == PBTypes::FIRE
          damagemult=(damagemult*0.5).round
        elsif opponent.ability == PBAbilities::DRYSKIN && !(opponent.moldbroken) && type == PBTypes::FIRE
          damagemult=(damagemult*1.25).round
        end
        if attitemworks
          case type
            when PBTypes::NORMAL
              if attacker.item == PBItems::SILKSCARF
                damagemult=(damagemult*1.2).round
              elsif attacker.item == PBItems::NORMALGEM
                damagemult=(damagemult*1.3).round
                attacker.takegem=true
              end
            when PBTypes::FIGHTING
              if attacker.item == PBItems::BLACKBELT || attacker.item == PBItems::FISTPLATE
                damagemult=(damagemult*1.2).round
              elsif attacker.item == PBItems::FIGHTINGGEM
                damagemult=(damagemult*1.3).round
                attacker.takegem=true
              end
            when PBTypes::FLYING
              if attacker.item == PBItems::SHARPBEAK || attacker.item == PBItems::SKYPLATE
                damagemult=(damagemult*1.2).round
              elsif attacker.item == PBItems::FLYINGGEM
                damagemult=(damagemult*1.3).round
                attacker.takegem=true
              end
            when PBTypes::POISON
              if attacker.item == PBItems::POISONBARB || attacker.item == PBItems::TOXICPLATE
                damagemult=(damagemult*1.2).round
              elsif attacker.item == PBItems::POISONGEM
                damagemult=(damagemult*1.3).round
                attacker.takegem=true
              end
            when PBTypes::GROUND
              if attacker.item == PBItems::SOFTSAND || attacker.item == PBItems::EARTHPLATE
                damagemult=(damagemult*1.2).round
              elsif attacker.item == PBItems::GROUNDGEM
                damagemult=(damagemult*1.3).round
                attacker.takegem=true
              end
            when PBTypes::ROCK
              if attacker.item == PBItems::HARDSTONE || attacker.item == PBItems::STONEPLATE || attacker.item == PBItems::ROCKINCENSE
                damagemult=(damagemult*1.2).round
              elsif attacker.item == PBItems::ROCKGEM
                damagemult=(damagemult*1.3).round
                attacker.takegem=true
              end
            when PBTypes::BUG
              if attacker.item == PBItems::SILVERPOWDER || attacker.item == PBItems::INSECTPLATE
                damagemult=(damagemult*1.2).round
              elsif attacker.item == PBItems::BUGGEM
                damagemult=(damagemult*1.3).round
                attacker.takegem=true
              end
            when PBTypes::GHOST
              if attacker.item == PBItems::SPELLTAG || attacker.item == PBItems::SPOOKYPLATE
                damagemult=(damagemult*1.2).round
              elsif attacker.item == PBItems::GHOSTGEM
                damagemult=(damagemult*1.3).round
                attacker.takegem=true
              end
            when PBTypes::STEEL
              if attacker.item == PBItems::METALCOAT || attacker.item == PBItems::IRONPLATE
                damagemult=(damagemult*1.2).round
              elsif attacker.item == PBItems::STEELGEM
                damagemult=(damagemult*1.3).round
                attacker.takegem=true
              end
            when 9 #?????
            when PBTypes::FIRE
              if attacker.item == PBItems::CHARCOAL || attacker.item == PBItems::FLAMEPLATE
                damagemult=(damagemult*1.2).round
              elsif attacker.item == PBItems::FIREGEM
                damagemult=(damagemult*1.3).round
                attacker.takegem=true
              end
            when PBTypes::WATER
              if attacker.item == PBItems::MYSTICWATER || attacker.item == PBItems::SPLASHPLATE || attacker.item == PBItems::SEAINCENSE || attacker.item == PBItems::WAVEINCENSE
                damagemult=(damagemult*1.2).round
              elsif attacker.item == PBItems::WATERGEM
                damagemult=(damagemult*1.3).round
                attacker.takegem=true
              end
            when PBTypes::GRASS
              if attacker.item == PBItems::MIRACLESEED || attacker.item == PBItems::MEADOWPLATE || attacker.item == PBItems::ROSEINCENSE
                damagemult=(damagemult*1.2).round
              elsif attacker.item == PBItems::GRASSGEM
                damagemult=(damagemult*1.3).round
                attacker.takegem=true
              end
            when PBTypes::ELECTRIC
              if attacker.item == PBItems::MAGNET || attacker.item == PBItems::ZAPPLATE
                damagemult=(damagemult*1.2).round
              elsif attacker.item == PBItems::ELECTRICGEM
                damagemult=(damagemult*1.3).round
                attacker.takegem=true
              end
            when PBTypes::PSYCHIC
              if attacker.item == PBItems::TWISTEDSPOON || attacker.item == PBItems::MINDPLATE || attacker.item == PBItems::ODDINCENSE
                damagemult=(damagemult*1.2).round
              elsif attacker.item == PBItems::PSYCHICGEM
                damagemult=(damagemult*1.3).round
                attacker.takegem=true
              end
            when PBTypes::ICE
              if attacker.item == PBItems::NEVERMELTICE || attacker.item == PBItems::ICICLEPLATE
                damagemult=(damagemult*1.2).round
              elsif attacker.item == PBItems::ICEGEM
                damagemult=(damagemult*1.3).round
                attacker.takegem=true
              end
            when PBTypes::DRAGON
              if attacker.item == PBItems::DRAGONFANG || attacker.item == PBItems::DRACOPLATE
                damagemult=(damagemult*1.2).round
              elsif attacker.item == PBItems::DRAGONGEM
                damagemult=(damagemult*1.3).round
                attacker.takegem=true
              end
            when PBTypes::DARK
              if attacker.item == PBItems::BLACKGLASSES || attacker.item == PBItems::DREADPLATE
                damagemult=(damagemult*1.2).round
              elsif attacker.item == PBItems::DARKGEM
                damagemult=(damagemult*1.3).round
                attacker.takegem=true
              end
            when PBTypes::FAIRY
              if attacker.item == PBItems::PIXIEPLATE
                damagemult=(damagemult*1.2).round
              elsif attacker.item == PBItems::FAIRYGEM
                damagemult=(damagemult*1.3).round
                attacker.takegem=true
              end
          end
          @battle.pbDisplay(_INTL("The {1} strengthened {2}'s power!",PBItems.getName(attacker.item),self.name)) if attacker.takegem==true
          # Muscle Band
          if (attacker.item == PBItems::MUSCLEBAND) && pbIsPhysical?(type)
            damagemult=(damagemult*1.1).round
          # Wise Glasses
          elsif (attacker.item == PBItems::WISEGLASSES) && pbIsSpecial?(type)
            damagemult=(damagemult*1.1).round
          # Legendary Orbs
          elsif attacker.item == PBItems::LUSTROUSORB
            if (attacker.pokemon.species == PBSpecies::PALKIA) && (type == PBTypes::DRAGON || type == PBTypes::WATER)
              damagemult=(damagemult*1.2).round
            end
          elsif attacker.item == PBItems::ADAMANTORB
            if (attacker.pokemon.species == PBSpecies::DIALGA) && (type == PBTypes::DRAGON || type == PBTypes::STEEL)
              damagemult=(damagemult*1.2).round
            end
          elsif attacker.item == PBItems::GRISEOUSORB
            if (attacker.pokemon.species == PBSpecies::GIRATINA) && (type == PBTypes::DRAGON || type == PBTypes::GHOST)
              damagemult=(damagemult*1.2).round
            end
          elsif attacker.item == PBItems::SOULDEW
            if (attacker.pokemon.species == PBSpecies::LATIAS) || (attacker.pokemon.species == PBSpecies::LATIOS) &&
              (type == PBTypes::DRAGON || type == PBTypes::PSYCHIC)
              damagemult=(damagemult*1.2).round
            end
          end
        end
        damagemult=pbBaseDamageMultiplier(damagemult,attacker,opponent)
        if attacker.effects[PBEffects::Charge]>0 && type == PBTypes::ELECTRIC
          damagemult=(damagemult*2.0).round
        end
        if attacker.effects[PBEffects::HelpingHand] && (options&SELFCONFUSE)==0
          damagemult=(damagemult*1.5).round
        end
        # Water/Mud Sport
        if type == PBTypes::FIRE
          if @battle.state.effects[PBEffects::WaterSport]>0
            damagemult=(damagemult*0.33).round
          end
        elsif type == PBTypes::ELECTRIC
          if @battle.state.effects[PBEffects::MudSport]>0
            damagemult=(damagemult*0.33).round
          end
        # Dark Aura/Aurabreak
        elsif type == PBTypes::DARK
          for i in @battle.battlers
            if i.ability == PBAbilities::DARKAURA
              breakaura=0
              for j in @battle.battlers
                if j.ability == PBAbilities::AURABREAK
                  breakaura+=1
                end
              end
              if breakaura!=0
                damagemult=(damagemult*2.0/3).round
              else
                damagemult=(damagemult*1.33).round
              end
            end
          end
        # Fairy Aura/Aurabreak
        elsif type == PBTypes::FAIRY
          for i in @battle.battlers
            if i.ability == PBAbilities::FAIRYAURA
              breakaura=0
              for j in @battle.battlers
                if j.ability == PBAbilities::AURABREAK
                  breakaura+=1
                end
              end
              if breakaura!=0
                damagemult=(damagemult*2.0/3).round
              else
                damagemult=(damagemult*1.3).round
              end
            end
          end
        end

        # Knock Off
        if @id == PBMoves::KNOCKOFF && opponent.item !=0 && !@battle.pbIsUnlosableItem(opponent,opponent.item)
          damagemult=(damagemult*1.5).round
        end
        # Minimize for z-move
        if @id == PBMoves::MALICIOUSMOONSAULT
          if opponent.effects[PBEffects::Minimize]
            damagemult=(damagemult*2.0).round
          end
        end
        #Specific Field Effects
        if @battle.FE != 0
          fieldmult = moveFieldBoost
          if fieldmult != 1
            damagemult=(damagemult*fieldmult).round
            fieldmessage =moveFieldMessage
            if fieldmessage && !@fieldmessageshown
              if @id == PBMoves::LIGHTTHATBURNSTHESKY #some moves have a {1} in them and we gotta deal.
                @battle.pbDisplay(_INTL(fieldmessage,attacker.pbThis))
              elsif (@id == PBMoves::SMACKDOWN || @id == PBMoves::THOUSANDARROWS ||
                @id == PBMoves::VITALTHROW || @id == PBMoves::CIRCLETHROW ||
                @id == PBMoves::STORMTHROW || @id == PBMoves::DOOMDUMMY || 
                @id == PBMoves::BLACKHOLEECLIPSE || @id == PBMoves::TECTONICRAGE || @id == PBMoves::CONTINENTALCRUSH)
                @battle.pbDisplay(_INTL(fieldmessage,opponent.pbThis))
              else
                @battle.pbDisplay(_INTL(fieldmessage))
              end
              @fieldmessageshown = true
            end
          end
        end
        case @battle.FE
          when 5 # Chess Board
            if (PBFields::CHESSMOVES).include?(@id)
              if (opponent.ability == PBAbilities::ADAPTABILITY) || (opponent.ability == PBAbilities::ANTICIPATION) || (opponent.ability == PBAbilities::SYNCHRONIZE) || (opponent.ability == PBAbilities::TELEPATHY)
                damagemult=(damagemult*0.5).round
              end
              if (opponent.ability == PBAbilities::OBLIVIOUS) || (opponent.ability == PBAbilities::KLUTZ) || (opponent.ability == PBAbilities::UNAWARE) || (opponent.ability == PBAbilities::SIMPLE) || opponent.effects[PBEffects::Confusion]>0
                damagemult=(damagemult*2).round
              end
              @battle.pbDisplay("The chess piece slammed forward!") if !@fieldmessageshown
              @fieldmessageshown = true
            end
            # Queen piece boost
            if attacker.pokemon.piece==:QUEEN || attacker.ability == PBAbilities::QUEENLYMAJESTY
              damagemult=(damagemult*1.5).round
              if attacker.pokemon.piece==:QUEEN
                @battle.pbDisplay("The Queen is dominating the board!")  && !@fieldmessageshown
                @fieldmessageshown = true
              end
            end
    
            #Knight piece boost
            if attacker.pokemon.piece==:KNIGHT && opponent.pokemon.piece==:QUEEN
              damagemult=(damagemult*3.0).round
              @battle.pbDisplay("An unblockable attack on the Queen!") if !@fieldmessageshown
              @fieldmessageshown = true
            end
          when 6 # Big Top
            if ((type == PBTypes::FIGHTING && pbIsPhysical?(type)) || (PBFields::STRIKERMOVES).include?(@id)) # Continental Crush
              striker = 1+@battle.pbRandom(14)
              @battle.pbDisplay("WHAMMO!") if !@fieldmessageshown
              @fieldmessageshown = true
              if attacker.ability == PBAbilities::HUGEPOWER || attacker.ability == PBAbilities::GUTS || attacker.ability == PBAbilities::PUREPOWER || attacker.ability == PBAbilities::SHEERFORCE
                if striker >=9
                  striker = 15
                else
                  striker = 14
                end
              end
              strikermod = attacker.stages[PBStats::ATTACK]
              striker = striker + strikermod
              if striker >= 15
                @battle.pbDisplay("...OVER 9000!!!")
                damagemult=(damagemult*3).round
              elsif striker >=13
                @battle.pbDisplay("...POWERFUL!")
                damagemult=(damagemult*2).round
              elsif striker >=9
                @battle.pbDisplay("...NICE!")
                damagemult=(damagemult*1.5).round
              elsif striker >=3
                @battle.pbDisplay("...OK!")
              else
                @battle.pbDisplay("...WEAK!")
                damagemult=(damagemult*0.5).round
              end
            end
            if (@flags&0x400)!= 0
              damagemult=(damagemult*1.5).round
              @battle.pbDisplay("Loud and clear!") if !@fieldmessageshown
              @fieldmessageshown = true
            end
          when 13 # Icy Field
            if (@priority >= 1 && @basedamage > 0 && (@flags&0x01)!=0 && attacker.ability != PBAbilities::LONGREACH) || (@id == PBMoves::FEINT || @id == PBMoves::ROLLOUT || @id == PBMoves::DEFENSECURL || @id == PBMoves::STEAMROLLER || @id == PBMoves::LUNGE)
              if !attacker.isAirborne?
                if attacker.pbCanIncreaseStatStage?(PBStats::SPEED)
                  attacker.pbIncreaseStatBasic(PBStats::SPEED,1)
                  @battle.pbCommonAnimation("StatUp",attacker,nil)
                  @battle.pbDisplay(_INTL("{1} gained momentum on the ice!",attacker.pbThis)) if !@fieldmessageshown
                  @fieldmessageshown = true
                end
              end
            end
          when 18 # Shortcircuit Field
            if type == PBTypes::ELECTRIC
              messageroll = ["Bzzt.", "Bzzapp!" , "Bzt...", "Bzap!", "BZZZAPP!"][@battle.field.roll]
              damageroll = @battle.field.getRoll()
    
              @battle.pbDisplay(messageroll) if !@fieldmessageshown
              damagemult=(damagemult*damageroll).round
    
              @fieldmessageshown = true
            end
          when 23 # Cave
            if (@flags&0x400)!= 0
              damagemult=(damagemult*1.5).round
              @battle.pbDisplay(_INTL("ECHO-Echo-echo!",opponent.pbThis)) if !@fieldmessageshown
              @fieldmessageshown = true
            end
          when 27 # Mountain
            if (PBFields::WINDMOVES).include?(@id) && @battle.pbWeather==PBWeather::STRONGWINDS
              damagemult=(damagemult*1.5).round
              @battle.pbDisplay(_INTL("The wind strengthened the attack!",opponent.pbThis)) if !@fieldmessageshown
              @fieldmessageshown = true
            end
          when 28 # Snowy Mountain
            if (PBFields::WINDMOVES).include?(@id) && @battle.pbWeather==PBWeather::STRONGWINDS
              damagemult=(damagemult*1.5).round
              @battle.pbDisplay(_INTL("The wind strengthened the attack!",opponent.pbThis)) if !@fieldmessageshown
              @fieldmessageshown = true
            end
          when 30 # Mirror
            if (PBFields::MIRRORMOVES).include?(@id) && opponent.stages[PBStats::EVASION]>0
              damagemult=(damagemult*2).round
              @battle.pbDisplay(_INTL("The beam was focused from the reflection!",opponent.pbThis)) if !@fieldmessageshown
              @fieldmessageshown = true
            end
            @battle.field.counter = 0
          when 33 # Flower Garden
            if (@id == PBMoves::CUT) && @battle.field.counter > 0
              damagemult=(damagemult*1.5).round
              @battle.pbDisplay(_INTL("{1} was cut down to size!",opponent.pbThis)) if !@fieldmessageshown
              @fieldmessageshown = true
            end
            if (@id == PBMoves::PETALBLIZZARD || @id == PBMoves::PETALDANCE || @id == PBMoves::FLEURCANNON) && @battle.field.counter == 2
              damagemult=(damagemult*1.2).round
              @battle.pbDisplay(_INTL("The fresh scent of flowers boosted the attack!",opponent.pbThis)) if !@fieldmessageshown
              @fieldmessageshown = true
            end
            if (@id == PBMoves::PETALBLIZZARD || @id == PBMoves::PETALDANCE || @id == PBMoves::FLEURCANNON) && @battle.field.counter > 2
              damagemult=(damagemult*1.5).round
              @battle.pbDisplay(_INTL("The vibrant aroma scent of flowers boosted the attack!",opponent.pbThis)) if !@fieldmessageshown
              @fieldmessageshown = true
            end
        end
        #End S.Field Effects
        basedmg=(basedmg*damagemult*1.0/0x1000).round
        ##### Calculate attacker's attack stat #####
        atk=attacker.attack
        atkstage=attacker.stages[PBStats::ATTACK]+6
        if @function==0x121 # Foul Play
          atk=opponent.attack
          atkstage=opponent.stages[PBStats::ATTACK]+6
        elsif @function==0x184 # Body Press
          atk=attacker.defense
          atkstage=attacker.stages[PBStats::DEFENSE]+6
        end
        if type>=0 && pbIsSpecial?(type)
          atk=attacker.spatk
          atkstage=attacker.stages[PBStats::SPATK]+6
          if @function==0x121 # Foul Play
            atk=opponent.spatk
            atkstage=opponent.stages[PBStats::SPATK]+6
          end
          if @battle.FE == PBFields::GLITCHF
                    atk = attacker.getSpecialStat(opponent.ability == PBAbilities::UNAWARE)
                    atkstage = 6 #getspecialstat handles unaware
                end
        end
        if opponent.ability != PBAbilities::UNAWARE || opponent.moldbroken
          atkstage=6 if opponent.damagestate.critical && atkstage<6
          atk=(atk*1.0*stagemul[atkstage]/stagediv[atkstage]).floor
        end
        if attacker.ability == PBAbilities::UNAWARE &&(options&SELFCONFUSE)!=0
           atkstage=attacker.stages[PBStats::ATTACK]+6
           atk=(atk*1.0*stagemul[atkstage]/stagediv[atkstage]).floor
        end
        if attacker.ability == PBAbilities::HUSTLE && pbIsPhysical?(type)
          atk=(atk*1.5).round
        end
        atkmult=0x1000
        if attacker.pbPartner.ability == PBAbilities::POWERSPOT
          atkmult=(atkmult*1.3).round
        end
    
        if @battle.FE == PBFields::BURNINGF && (attacker.ability == PBAbilities::BLAZE && type == PBTypes::FIRE)
          atkmult=(atkmult*1.5).round
        elsif @battle.FE == PBFields::FORESTF && (attacker.ability == PBAbilities::OVERGROW && type == PBTypes::GRASS)
          atkmult=(atkmult*1.5).round
        elsif @battle.FE == PBFields::FORESTF && (attacker.ability == PBAbilities::SWARM && type == PBTypes::BUG)
          atkmult=(atkmult*1.5).round
        elsif (@battle.FE == PBFields::WATERS || @battle.FE == PBFields::UNDERWATER) && (attacker.ability == PBAbilities::TORRENT && type == PBTypes::WATER)
          atkmult=(atkmult*1.5).round
        elsif @battle.FE == PBFields::FLOWERGARDENF && (attacker.ability == PBAbilities::SWARM && type == PBTypes::BUG)
          atkmult=(atkmult*1.5).round if @battle.field.counter == 0 || @battle.field.counter == 1
          atkmult=(atkmult*1.8).round if @battle.field.counter == 2 || @battle.field.counter == 3
          atkmult=(atkmult*2).round if @battle.field.counter == 4
        elsif @battle.FE == PBFields::FLOWERGARDENF && (attacker.ability == PBAbilities::OVERGROW && type == PBTypes::GRASS)
          case @battle.field.counter
            when 1 then atkmult=(atkmult*1.5).round if attacker.hp<=(attacker.totalhp*0.67).floor
            when 2 then atkmult=(atkmult*1.6).round
            when 3 then atkmult=(atkmult*1.8).round
            when 4 then atkmult=(atkmult*2).round
          end
        elsif attacker.hp<=(attacker.totalhp/3.0).floor
          if (attacker.ability == PBAbilities::OVERGROW && type == PBTypes::GRASS) ||
          (attacker.ability == PBAbilities::BLAZE && type == PBTypes::FIRE) ||
          (attacker.ability == PBAbilities::TORRENT && type == PBTypes::WATER) ||
          (attacker.ability == PBAbilities::SWARM && type == PBTypes::BUG)
            atkmult=(atkmult*1.5).round
          end
        end
        case attacker.ability
        when PBAbilities::GUTS
          atkmult=(atkmult*1.5).round if attacker.status!=0 && pbIsPhysical?(type)
        when PBAbilities::PLUS, PBAbilities::MINUS
          if pbIsSpecial?(type) && @battle.FE != 24
            partner=attacker.pbPartner
            if partner.ability == PBAbilities::PLUS || partner.ability == PBAbilities::MINUS
              atkmult=(atkmult*1.5).round
            elsif @battle.FE == PBFields::SHORTCIRCUITF
              atkmult=(atkmult*1.5).round
            end
          end
        when PBAbilities::DEFEATIST
          atkmult=(atkmult*0.5).round if attacker.hp<=(attacker.totalhp/2.0).floor
        when PBAbilities::HUGEPOWER
          atkmult=(atkmult*2.0).round if pbIsPhysical?(type)
        when PBAbilities::PUREPOWER
          if @battle.FE == PBFields::PSYCHICT
            atkmult=(atkmult*2.0).round if pbIsSpecial?(type)
          else
            atkmult=(atkmult*2.0).round if pbIsPhysical?(type)
          end
        when PBAbilities::SOLARPOWER 
          if (@battle.pbWeather==PBWeather::SUNNYDAY && !(attitemworks && attacker.item == PBItems::UTILITYUMBRELLA)) && pbIsSpecial?(type) && @battle.FE != 24
            atkmult=(atkmult*1.5).round
          end
        when PBAbilities::SLOWSTART
          atkmult=(atkmult*0.5).round if attacker.turncount<5 && pbIsPhysical?(type)
        when PBAbilities::GORILLATACTICS 
          atkmult=(atkmult*1.5).round if pbIsPhysical?(type)
        end
        if ((@battle.pbWeather==PBWeather::SUNNYDAY && !(attitemworks && attacker.item == PBItems::UTILITYUMBRELLA)) || @battle.FE == PBFields::FLOWERGARDENF) && pbIsPhysical?(type)
          if attacker.ability == PBAbilities::FLOWERGIFT || attacker.pbPartner.ability == PBAbilities::FLOWERGIFT
            atkmult=(atkmult*1.5).round
          end
        end
    
        if attacker.pbPartner.hasWorkingAbility(:BATTERY) && pbIsSpecial?(type) && @battle.FE != 24
          atkmult=(atkmult*1.3).round
        end
        if (attacker.pbPartner.ability == PBAbilities::STEELYSPIRIT || attacker.ability == PBAbilities::STEELYSPIRIT) && type == PBTypes::STEEL
          atkmult=(atkmult*1.5).round
        end
        
        atkmult=(atkmult*1.5).round if attacker.effects[PBEffects::FlashFire] && type == PBTypes::FIRE
    
        if attitemworks
          if attacker.item == PBItems::THICKCLUB 
            atkmult=(atkmult*2.0).round if attacker.pokemon.species == PBSpecies::CUBONE || attacker.pokemon.species == PBSpecies::MAROWAK && pbIsPhysical?(type)
          elsif attacker.item == PBItems::DEEPSEATOOTH 
            atkmult=(atkmult*2.0).round if attacker.pokemon.species == PBSpecies::CLAMPERL && pbIsSpecial?(type) && @battle.FE !=24
          elsif attacker.item == PBItems::LIGHTBALL
            atkmult=(atkmult*2.0).round if attacker.pokemon.species == PBSpecies::PIKACHU && @battle.FE !=24
          elsif attacker.item == PBItems::CHOICEBAND
            atkmult=(atkmult*1.5).round if pbIsPhysical?(type)
          elsif attacker.item == PBItems::CHOICESPECS 
            atkmult=(atkmult*1.5).round if pbIsSpecial?(type) && @battle.FE !=24
          end
        end
        if @battle.FE !=0
          if @battle.FE == PBFields::STARLIGHTA || @battle.FE == PBFields::NEWW
            if attacker.ability == PBAbilities::VICTORYSTAR
              atkmult=(atkmult*1.5).round
            end
            partner=attacker.pbPartner
            if partner && partner.ability == PBAbilities::VICTORYSTAR
              atkmult=(atkmult*1.5).round
            end
          end
          if @battle.FE == PBFields::UNDERWATER 
            atkmult=(atkmult*0.5).round if pbIsPhysical?(type) && type != PBTypes::WATER && attacker.ability != PBAbilities::STEELWORKER
          end
          if attacker.ability == PBAbilities::QUEENLYMAJESTY
            atkmult=(atkmult*1.5).round if @battle.FE == PBFields::FAIRYTALEF
          elsif attacker.ability == PBAbilities::LONGREACH
            atkmult=(atkmult*1.5).round if @battle.FE == PBFields::MOUNTAIN || @battle.FE == PBFields::SNOWYM
          elsif attacker.ability == PBAbilities::CORROSION
            atkmult=(atkmult*1.5).round if (@battle.FE == PBFields::CORROSIVEF || @battle.FE == PBFields::CORROSIVEMISTF)
          end
        end
    
        if opponent.ability == PBAbilities::THICKFAT && (type == PBTypes::ICE || type == PBTypes::FIRE) && !(opponent.moldbroken)
          atkmult=(atkmult*0.5).round
        end
        atk=(atk*atkmult*1.0/0x1000).round
    
        ##### Calculate opponent's defense stat #####
        defense=opponent.defense
        defstage=opponent.stages[PBStats::DEFENSE]+6
        # TODO: Wonder Room should apply around here
        
        applysandstorm=false
        if type>=0 && pbHitsSpecialStat?(type)
          defense=opponent.spdef
          defstage=opponent.stages[PBStats::SPDEF]+6
          applysandstorm=true
          if @battle.FE == PBFields::GLITCHF
            defense = opponent.getSpecialStat(attacker.ability == PBAbilities::UNAWARE)
            defstage = 6 # getspecialstat handles unaware
            applysandstorm=false # getSpecialStat handles sandstorm
          end
        end
        if attacker.ability != PBAbilities::UNAWARE
          defstage=6 if @function==0xA9 # Chip Away (ignore stat stages)
          defstage=6 if opponent.damagestate.critical && defstage>6
          defense=(defense*1.0*stagemul[defstage]/stagediv[defstage]).floor
        end
        if @battle.pbWeather==PBWeather::SANDSTORM &&
           opponent.pbHasType?(:ROCK) && applysandstorm
          defense=(defense*1.5).round
        end
        defmult=0x1000
    
        # Field Effect defense boost
        defmult*=fieldDefenseBoost(type,opponent)
    
        #Abilities defense boost
        if opponent.ability == PBAbilities::ICESCALES && pbIsSpecial?(type)
          defmult=(defmult*2).round
        end
        if @battle.FE == PBFields::GLITCHF && @function==0xE0
          defmult=(defmult*0.5).round
        end
        if opponent.ability == PBAbilities::MARVELSCALE && pbIsPhysical?(type) &&
          (opponent.status>0 || @battle.FE == PBFields::MISTYT || @battle.FE == PBFields::RAINBOWF ||
          @battle.FE == PBFields::FAIRYTALEF || @battle.FE == PBFields::DRAGONSD || @battle.FE == PBFields::STARLIGHTA) && !(opponent.moldbroken)
          defmult=(defmult*1.5).round
        end
        if opponent.ability == PBAbilities::GRASSPELT && pbIsPhysical?(type) &&
        (@battle.FE == PBFields::GRASSYT || @battle.FE == PBFields::FORESTF) # Grassy Field
          defmult=(defmult*1.5).round
        end
        if opponent.ability == PBAbilities::FLUFFY && !(opponent.moldbroken)
          if isContactMove? && attacker.ability != PBAbilities::LONGREACH
            defmult=(defmult*2).round
          end
          if type == PBTypes::FIRE
            defmult=(defmult*0.5).round
          end
        end
        if opponent.ability == PBAbilities::FURCOAT && pbIsPhysical?(type) && !(opponent.moldbroken)
          defmult=(defmult*2).round
        end
        if opponent.ability == PBAbilities::PUNKROCK && isSoundBased?
          defmult=(defmult*2).round
        end
        if ((@battle.pbWeather==PBWeather::SUNNYDAY && !opponent.hasWorkingItem(:UTILITYUMBRELLA)) || @battle.FE == PBFields::FLOWERGARDENF) &&
          !(opponent.moldbroken) && pbIsSpecial?(type)
          if opponent.ability == PBAbilities::FLOWERGIFT && opponent.species == PBSpecies::CHERRIM
            defmult=(defmult*1.5).round
          end
          if opponent.pbPartner.ability == PBAbilities::FLOWERGIFT  && opponent.pbPartner.species == PBSpecies::CHERRIM
            defmult=(defmult*1.5).round
          end
        end
    
        #Item defense boost
        if opponent.hasWorkingItem(:EVIOLITE) && @battle.FE != PBFields::GLITCHF
          evos=pbGetEvolvedFormData(opponent.pokemon.species)
          if evos && evos.length>0
            defmult=(defmult*1.5).round
          end
        end
        #if opponent.item == PBItems::EEVIUMZ2 && opponent.pokemon.species == PBSpecies::EEVEE && @battle.FE != PBFields::GLITCHF
        #  defmult=(defmult*1.5).round
        #end
        if opponent.item == PBItems::PIKANIUMZ2 && opponent.pokemon.species == PBSpecies::PIKACHU && @battle.FE != PBFields::GLITCHF
          defmult=(defmult*1.5).round
        end
        if opponent.item == PBItems::LIGHTBALL && opponent.pokemon.species == PBSpecies::PIKACHU && @battle.FE != PBFields::GLITCHF
          defmult=(defmult*1.5).round
        end
        if opponent.hasWorkingItem(:ASSAULTVEST) && pbIsSpecial?(type) && @battle.FE != PBFields::GLITCHF
          defmult=(defmult*1.5).round
        end
        if opponent.hasWorkingItem(:DEEPSEASCALE) && @battle.FE != PBFields::GLITCHF &&
           (opponent.pokemon.species == PBSpecies::CLAMPERL) && pbIsSpecial?(type)
          defmult=(defmult*2.0).round
        end
        if opponent.hasWorkingItem(:METALPOWDER) && (opponent.pokemon.species == PBSpecies::DITTO) &&
           !opponent.effects[PBEffects::Transform] && pbIsPhysical?(type)
          defmult=(defmult*2.0).round
        end
    
        # Total defense stat
        defense=(defense*defmult*1.0/0x1000).round
    
        ##### Main damage calculation #####
        damage=(((2.0*attacker.level/5+2).floor*basedmg*atk/defense).floor/50.0).floor+2
        # Multi-targeting attacks
        if pbTargetsAll?(attacker) || attacker.midwayThroughMove
          if attacker.pokemon.piece == :KNIGHT && battle.FE == PBFields::CHESSB && @target==PBTargets::AllOpposing
            @battle.pbDisplay(_INTL("The knight forked the opponents!")) if !attacker.midwayThroughMove
            damage=(damage*1.25).round
          else
            damage=(damage*0.75).round
          end
          attacker.midwayThroughMove = true
        end
        # Field Effects
        fieldBoost = typeFieldBoost(type,attacker,opponent)
        if fieldBoost != 1
          damage=(damage*fieldBoost).floor
          fieldmessage = typeFieldMessage(type)
          @battle.pbDisplay(_INTL(fieldmessage)) if fieldmessage && !@fieldmessageshown_type
          @fieldmessageshown_type = true
        end
        case @battle.FE
          when PBFields::MOUNTAIN
            if type == PBTypes::FLYING && !pbIsPhysical?(type) && @battle.pbWeather==PBWeather::STRONGWINDS
              damage=(damage*1.5).floor
            end
          when PBFields::SNOWYM
            if type == PBTypes::FLYING && !pbIsPhysical?(type) && @battle.pbWeather==PBWeather::STRONGWINDS
              damage=(damage*1.5).floor
            end
          when PBFields::FLOWERGARDENF
            if type == PBTypes::GRASS
              case @battle.field.counter
                when 1
                  damage=(damage*1.1).floor
                  @battle.pbDisplay(_INTL("The garden's power boosted the attack!",opponent.pbThis)) if !@fieldmessageshown_type
                  @fieldmessageshown_type = true
                when 2
                  damage=(damage*1.3).floor
                  @battle.pbDisplay(_INTL("The budding flowers boosted the attack!",opponent.pbThis)) if !@fieldmessageshown_type
                  @fieldmessageshown_type = true
                when 3
                  damage=(damage*1.5).floor
                  @battle.pbDisplay(_INTL("The blooming flowers boosted the attack!",opponent.pbThis)) if !@fieldmessageshown_type
                  @fieldmessageshown_type = true
                when 4
                  damage=(damage*2).floor
                  @battle.pbDisplay(_INTL("The thriving flowers boosted the attack!",opponent.pbThis)) if !@fieldmessageshown_type
                  @fieldmessageshown_type = true
              end
            end
            if @battle.field.counter > 1
              if type == PBTypes::FIRE
                damage=(damage*1.5).floor
                @battle.pbDisplay(_INTL("The nearby flowers caught flame!",opponent.pbThis)) if !@fieldmessageshown_type
                @fieldmessageshown_type = true
              end
            end
            if @battle.field.counter > 3
              if type == PBTypes::BUG
                damage=(damage*2).floor
                @battle.pbDisplay(_INTL("The attack infested the flowers!",opponent.pbThis)) if !@fieldmessageshown_type
                @fieldmessageshown_type = true
              end
            elsif @battle.field.counter > 1
              if type == PBTypes::BUG
                damage=(damage*1.5).floor
                @battle.pbDisplay(_INTL("The attack infested the garden!",opponent.pbThis)) if !@fieldmessageshown_type
                @fieldmessageshown_type = true
              end
            end
        end
        case @battle.pbWeather
          when PBWeather::SUNNYDAY
            if @battle.state.effects[PBEffects::HarshSunlight] && type == PBTypes::WATER
              @battle.pbDisplay(_INTL("The Water-type attack evaporated in the harsh sunlight!"))
              @battle.scene.pbUnVanishSprite(attacker) if @function==0xCB #Dive
              return 0
            end
          when PBWeather::RAINDANCE
            if @battle.state.effects[PBEffects::HeavyRain] && type == PBTypes::FIRE
              @battle.pbDisplay(_INTL("The Fire-type attack fizzled out in the heavy rain!"))
              return 0
            end
        end
    
        # FIELD TRANSFORMATIONS
        fieldmove = @battle.field.moveData(@id)
        if fieldmove && fieldmove[:fieldchange]
          change_conditions = @battle.field.fieldChangeData
          handled = change_conditions[fieldmove[:fieldchange]] ? eval(change_conditions[fieldmove[:fieldchange]]) : true
          if handled  #don't continue if conditions to change are not met
            damage=(damage*1.3).floor if damage >= 0
            #@battle.pbDisplay(_INTL(changeFieldMessage)) if changeFieldMessage
          end
        end
        case @battle.FE
          when PBFields::FACTORYF
            if (@id == PBMoves::DISCHARGE)
              @battle.setField(PBFields::SHORTCIRCUITF)
              @battle.pbDisplay(_INTL("The field shorted out!"))
              damage=(damage*1.3).floor if damage >= 0
            end
          when PBFields::SHORTCIRCUITF
            if (@id == PBMoves::DISCHARGE)
              @battle.setField(PBFields::FACTORYF)
              @battle.pbDisplay(_INTL("SYSTEM ONLINE."))
              damage=(damage*1.3).floor if damage >= 0
            end
        end
    
        # Weather
        case @battle.pbWeather
          when PBWeather::SUNNYDAY
            if type == PBTypes::FIRE
              damage=(damage*1.5).round
            elsif type == PBTypes::WATER
              damage=(damage*0.5).round
            end
          when PBWeather::RAINDANCE
            if type == PBTypes::FIRE
              damage=(damage*0.5).round
            elsif type == PBTypes::WATER
              damage=(damage*1.5).round
            end
        end
        
        # Critical hits
        if opponent.damagestate.critical
          damage=(damage*1.5).round
          if attacker.ability == PBAbilities::SNIPER
            damage=(damage*1.5).round
          end
        end
        if attacker.ability == PBAbilities::WATERBUBBLE && type == PBTypes::WATER
          damage=(damage*=2).round
        end
    
        # Random variance
        if (options&NOWEIGHTING)==0 
          if !$game_switches[:No_Damage_Rolls] || @battle.isOnline?
            random=85+@battle.pbRandom(16)
            damage=(damage*random/100.0).floor
          elsif $game_switches[:No_Damage_Rolls] && !@battle.isOnline?
            damage=(damage*0.93).round
          end
        end
        ##Modded, increase damage if target is asleep.
        if opponent.status==PBStatuses::SLEEP
          damage=(damage*1.33).round
        end
        # STAB
        if (attacker.pbHasType?(type) || (attacker.ability == PBAbilities::STEELWORKER && type == PBTypes::STEEL)) && (options&IGNOREPKMNTYPES)==0
          if attacker.ability == PBAbilities::ADAPTABILITY
            damage=(damage*2).round
          elsif (attacker.ability == PBAbilities::STEELWORKER && type == PBTypes::STEEL) && @battle.FE == PBFields::FACTORYF # Factory Field
            damage=(damage*2).round
          else
            damage=(damage*1.5).round
          end
        end
    
        # Type effectiveness
        if (options&IGNOREPKMNTYPES)==0
          typemod=pbTypeModMessages(type,attacker,opponent)
          damage=(damage*typemod/4.0).round
          opponent.damagestate.typemod=typemod
          if typemod==0
            opponent.damagestate.calcdamage=0
            opponent.damagestate.critical=false
            return 0
          end
        else
          opponent.damagestate.typemod=4
        end
        if opponent.ability == PBAbilities::WATERBUBBLE && type == PBTypes::FIRE
          damage=(damage*=0.5).round
        end
        # Burn
        if attacker.status==PBStatuses::BURN && pbIsPhysical?(type) &&
           attacker.ability != PBAbilities::GUTS&& @id != PBMoves::FACADE
          damage=(damage*0.5).round
        end
        # MODDED - FROSTBITE
        if attacker.status==PBStatuses::FROZEN && !pbIsPhysical?(type) &&
            attacker.ability != PBAbilities::GUTS&& @id != PBMoves::FACADE
           damage=(damage*0.5).round
         end
        # Make sure damage is at least 1
        damage=1 if damage<1
        
        # Final damage modifiers
        finaldamagemult=0x1000
        if !opponent.damagestate.critical && (options&NOREFLECT)==0 &&
           attacker.ability != PBAbilities::INFILTRATOR
          # Reflect
          if opponent.pbOwnSide.effects[PBEffects::Reflect]>0 && pbIsPhysical?(type) && opponent.pbOwnSide.effects[PBEffects::AuroraVeil]==0
            # TODO: should apply even if partner faints during an attack]
            if !opponent.pbPartner.isFainted? || attacker.midwayThroughMove
              finaldamagemult=(finaldamagemult*0.66).round
            else
              finaldamagemult=(finaldamagemult*0.5).round
            end
          end
          # Light Screen
          if opponent.pbOwnSide.effects[PBEffects::LightScreen]>0 && pbIsSpecial?(type) && opponent.pbOwnSide.effects[PBEffects::AuroraVeil]==0
            # TODO: should apply even if partner faints during an attack]
            if !opponent.pbPartner.isFainted?
              finaldamagemult=(finaldamagemult*0.66).round
            else
              finaldamagemult=(finaldamagemult*0.5).round
            end
          end
          # Aurora Veil
          if opponent.pbOwnSide.effects[PBEffects::AuroraVeil]>0
            # TODO: should apply even if partner faints during an attack]
            if !opponent.pbPartner.isFainted?
              finaldamagemult=(finaldamagemult*0.66).round
            else
              finaldamagemult=(finaldamagemult*0.5).round
            end
          end
        end
        if ((opponent.ability == PBAbilities::MULTISCALE && !(opponent.moldbroken)) || opponent.ability == PBAbilities::SHADOWSHIELD) && opponent.hp==opponent.totalhp
          finaldamagemult=(finaldamagemult*0.5).round
        end
        if attacker.ability == PBAbilities::TINTEDLENS && opponent.damagestate.typemod<4
          finaldamagemult=(finaldamagemult*2.0).round
        end
        if opponent.pbPartner.ability == PBAbilities::FRIENDGUARD && !(opponent.moldbroken)
          finaldamagemult=(finaldamagemult*0.75).round
        end
        if @battle.FE == PBFields::FLOWERGARDENF && @battle.field.counter >1
          if (opponent.pbPartner.ability == PBAbilities::FLOWERVEIL && opponent.pbHasType?(:GRASS)) ||
           (opponent.ability == PBAbilities::FLOWERVEIL && !(opponent.moldbroken))
            finaldamagemult=(finaldamagemult*0.5).round
            @battle.pbDisplay(_INTL("The Flower Veil softened the attack!"))
          end
          if opponent.pbHasType?(:GRASS)
            case @battle.field.counter
              when 2 then finaldamagemult=(finaldamagemult*0.75).round
              when 3 then finaldamagemult=(finaldamagemult*0.67).round
              when 4 then finaldamagemult=(finaldamagemult*0.5).round
            end
          end
        end
        if (((opponent.ability == PBAbilities::SOLIDROCK || opponent.ability == PBAbilities::FILTER) && !opponent.moldbroken) ||
           opponent.ability == PBAbilities::PRISMARMOR) && opponent.damagestate.typemod>4
          finaldamagemult=(finaldamagemult*0.75).round
        end
        if opponent.ability == PBAbilities::SHADOWSHIELD && [PBFields::STARLIGHTA, PBFields::NEWW, PBFields::DARKCRYSTALC].include?(@battle.FE)
          finaldamagemult=(finaldamagemult*0.75).round if opponent.damagestate.typemod>4
        end
        if attacker.ability == PBAbilities::STAKEOUT && @battle.switchedOut[opponent.index]
          finaldamagemult=(finaldamagemult*2.0).round
        end
        if (attitemworks && attacker.item == PBItems::METRONOME) && attacker.movesUsed[-2] == attacker.movesUsed[-1]
          if attacker.effects[PBEffects::Metronome]>4
            finaldamagemult=(finaldamagemult*2.0).round
          else
            met=1.0+attacker.effects[PBEffects::Metronome]*0.2
            finaldamagemult=(finaldamagemult*met).round
          end
        end
        if (attitemworks && attacker.item == PBItems::EXPERTBELT) && opponent.damagestate.typemod > 4
          finaldamagemult=(finaldamagemult*1.2).round
        end
        if (attacker.ability == PBAbilities::NEUROFORCE) && opponent.damagestate.typemod > 4
          finaldamagemult=(finaldamagemult*1.25).round
        end
        
        if (attitemworks && attacker.item == PBItems::LIFEORB)
          finaldamagemult=(finaldamagemult*1.3).round
        end
        if opponent.damagestate.typemod>4 && (options&IGNOREPKMNTYPES)==0 && opponent.itemWorks?
          hasberry = false
          case type
            when PBTypes::FIGHTING   then hasberry = opponent.item == PBItems::CHOPLEBERRY
            when PBTypes::FLYING     then hasberry = opponent.item == PBItems::COBABERRY
            when PBTypes::POISON     then hasberry = opponent.item == PBItems::KEBIABERRY
            when PBTypes::GROUND     then hasberry = opponent.item == PBItems::SHUCABERRY
            when PBTypes::ROCK       then hasberry = opponent.item == PBItems::CHARTIBERRY
            when PBTypes::BUG        then hasberry = opponent.item == PBItems::TANGABERRY
            when PBTypes::GHOST      then hasberry = opponent.item == PBItems::KASIBBERRY
            when PBTypes::STEEL      then hasberry = opponent.item == PBItems::BABIRIBERRY
            when PBTypes::FIRE       then hasberry = opponent.item == PBItems::OCCABERRY
            when PBTypes::WATER      then hasberry = opponent.item == PBItems::PASSHOBERRY
            when PBTypes::GRASS      then hasberry = opponent.item == PBItems::RINDOBERRY
            when PBTypes::ELECTRIC   then hasberry = opponent.item == PBItems::WACANBERRY
            when PBTypes::PSYCHIC    then hasberry = opponent.item == PBItems::PAYAPABERRY
            when PBTypes::ICE        then hasberry = opponent.item == PBItems::YACHEBERRY
            when PBTypes::DRAGON     then hasberry = opponent.item == PBItems::HABANBERRY
            when PBTypes::DARK       then hasberry = opponent.item == PBItems::COLBURBERRY
            when PBTypes::FAIRY      then hasberry = opponent.item == PBItems::ROSELIBERRY
          end
          if hasberry
            if opponent.ability == PBAbilities::RIPEN
              finaldamagemult=(finaldamagemult*0.25).round
            else
              finaldamagemult=(finaldamagemult*0.5).round
            end
            opponent.pbDisposeItem(true)
            if !@battle.pbIsOpposing?(attacker.index)
              @battle.pbDisplay(_INTL("{2}'s {1} weakened the damage from the attack!",PBItems.getName(opponent.pokemon.itemRecycle),opponent.pbThis))
            else
              @battle.pbDisplay(_INTL("The {1} weakened the damage to {2}!",PBItems.getName(opponent.pokemon.itemRecycle),opponent.pbThis))
            end
          end
        end
        if opponent.hasWorkingItem(:CHILANBERRY) && type == PBTypes::NORMAL && (options&IGNOREPKMNTYPES)==0
          if opponent.ability == PBAbilities::RIPEN
            finaldamagemult=(finaldamagemult*0.25).round
          else
            finaldamagemult=(finaldamagemult*0.5).round
          end
          opponent.pbDisposeItem(true)
          if !@battle.pbIsOpposing?(attacker.index)
            @battle.pbDisplay(_INTL("{2}'s {1} weakened the damage from the attack!",PBItems.getName(opponent.pokemon.itemRecycle),opponent.pbThis))
          else
            @battle.pbDisplay(_INTL("The {1} weakened the damage to {2}!",PBItems.getName(opponent.pokemon.itemRecycle),opponent.pbThis))
          end
        end
        finaldamagemult=pbModifyDamage(finaldamagemult,attacker,opponent)
        damage=(damage*finaldamagemult*1.0/0x1000).round
        opponent.damagestate.calcdamage=damage
        #puts "damage dealt: #{damage}, finaldamagemult: #{finaldamagemult}, "
        return damage
      end
end




class PokeBattle_Battle
  def pbDisplay(msg)
    msg = msg.gsub(/frozen solid/, 'frostbitten')
    msg = msg.gsub(/fell asleep/, 'became drowsy')
    msg = msg.gsub(/went to sleep/, 'became drowsy')
    #puts "printing battle msg"
    #puts msg.inspect
    @scene.pbDisplayMessage(msg)
  end

    def pbEndOfRoundPhase
        for i in 0...4
          if @battlers[i].effects[PBEffects::ShellTrap] && !pbChoseMoveFunctionCode?(i,0x16B)
            pbDisplay(_INTL("{1}'s Shell Trap didn't work.",@battlers[i].name))
          end
        end
        for i in 0...4
          @battlers[i].forcedSwitchEarlier                  =false
          next if @battlers[i].hp <= 0
          @battlers[i].damagestate.reset
          @battlers[i].midwayThroughMove                    =false
          @battlers[i].forcedSwitchEarlier                  =false
          @battlers[i].effects[PBEffects::Protect]          =false
          @battlers[i].effects[PBEffects::Obstruct]         =false
          @battlers[i].effects[PBEffects::KingsShield]      =false
          @battlers[i].effects[PBEffects::ProtectNegation]  =false
          @battlers[i].effects[PBEffects::Endure]           =false
          @battlers[i].effects[PBEffects::HyperBeam]-=1     if @battlers[i].effects[PBEffects::HyperBeam]>0
          @battlers[i].effects[PBEffects::SpikyShield]      =false
          @battlers[i].effects[PBEffects::BanefulBunker]    =false
          @battlers[i].effects[PBEffects::BeakBlast]        =false
          @battlers[i].effects[PBEffects::ClangedScales]    =false
          @battlers[i].effects[PBEffects::ShellTrap]        =false
          if @field.effect==PBFields::BURNINGF && @battlers[i].effects[PBEffects::BurnUp] # Burning Field
            @battlers[i].type1= @battlers[i].pokemon.type1
            @battlers[i].type2= @battlers[i].pokemon.type2
            @battlers[i].effects[PBEffects::BurnUp]         =false
          end
          @battlers[i].effects[PBEffects::Powder]           =false
          @battlers[i].effects[PBEffects::MeFirst]          =false
          if @battlers[i].effects[PBEffects::ThroatChop]>0
            @battlers[i].effects[PBEffects::ThroatChop]-=1
          end
          @battlers[i].itemUsed                    =false
        end
        @state.effects[PBEffects::IonDeluge]       =false
        for i in 0...2
          sides[i].effects[PBEffects::QuickGuard]=false
          sides[i].effects[PBEffects::CraftyShield]=false
          sides[i].effects[PBEffects::WideGuard]=false
          sides[i].effects[PBEffects::MatBlock]=false
        end
        @usepriority=false  # recalculate priority
        priority=pbPriority
        if @trickroom > 0
          @trickroom=@trickroom-1
          if @trickroom == 0
            pbDisplay("The twisted dimensions returned to normal!")
          end
        end
        if @state.effects[PBEffects::WonderRoom] > 0
          @state.effects[PBEffects::WonderRoom] -= 1
          if @state.effects[PBEffects::WonderRoom] == 0
            for i in @battlers
              if i.wonderroom
               i.pbSwapDefenses
              end
            end
            pbDisplay("Wonder Room wore off, and the Defense and Sp. Def stats returned to normal!")
          end
        end
        priority=pbPriority
        # Field Effects
        endmessage=false
        for i in priority
          next if i.isFainted?
          case @field.effect
            when PBFields::GRASSYT # Grassy Field
              next if i.hp<=0
              if !i.isAirborne? && i.effects[PBEffects::HealBlock]==0 && i.totalhp != i.hp
                pbDisplay(_INTL("The grassy terrain healed the Pokemon on the field.",i.pbThis)) if endmessage == false
                endmessage=true
                hpgain=(i.totalhp/16.0).floor
                hpgain=(hpgain*1.3).floor if (i.item == PBItems::BIGROOT)
                hpgain=i.pbRecoverHP(hpgain,true)
              end
            when PBFields::BURNINGF # Burning Field
              next if i.hp<=0
              if !i.isAirborne?
                if (i.ability == PBAbilities::FLASHFIRE)
                  if !i.effects[PBEffects::FlashFire]
                    i.effects[PBEffects::FlashFire]=true
                    pbDisplay(_INTL("{1}'s {2} raised its Fire power!", i.pbThis,PBAbilities.getName(i.ability)))
                  end
                end
                if i.burningFieldPassiveDamage?
                  eff=PBTypes.getCombinedEffectiveness(PBTypes::FIRE,i.type1,i.type2)
                  if eff>0
                    @scene.pbDamageAnimation(i,0)
                    if (i.ability == PBAbilities::LEAFGUARD) || (i.ability == PBAbilities::ICEBODY) || (i.ability == PBAbilities::FLUFFY) || (i.ability == PBAbilities::GRASSPELT)
                      eff = eff*2
                    end
                    pbDisplay(_INTL("The Pokemon were burned by the field!",i.pbThis)) if endmessage == false
                    endmessage=true
                    i.pbReduceHP([(i.totalhp*eff/32).floor,1].max)
                    if i.hp<=0
                      return if !i.pbFaint
                    end
                  end
                end
              end
            when PBFields::CORROSIVEF # Corrosive Field
              next if i.hp<=0
              if i.ability == PBAbilities::GRASSPELT
                @scene.pbDamageAnimation(i,0)
                i.pbReduceHP((i.totalhp/8.0).floor)
                pbDisplay(_INTL("{1}'s Pelt was corroded!",i.pbThis))
                if i.hp<=0
                  return if !i.pbFaint
                end
              end
              if i.ability == PBAbilities::POISONHEAL && !i.isAirborne? && i.effects[PBEffects::HealBlock]==0 && i.hp<i.totalhp
                pbCommonAnimation("Poison",i,nil)
                i.pbRecoverHP((i.totalhp/8.0).floor,true)
                pbDisplay(_INTL("{1} was healed by poison!",i.pbThis))
              end
            when PBFields::CORROSIVEMISTF # Corrosive Mist Field
              if i.pbCanPoison?(false)
                pbDisplay(_INTL("The Pokemon were poisoned by the corrosive mist!",i.pbThis))   if endmessage == false
                endmessage=true
                i.pbPoison(i)
              end
              if i.ability == PBAbilities::POISONHEAL && i.effects[PBEffects::HealBlock]==0 && i.hp<i.totalhp
                pbCommonAnimation("Poison",i,nil)
                i.pbRecoverHP((i.totalhp/8.0).floor,true)
                pbDisplay(_INTL("{1} was healed by poison!",i.pbThis))
              end
            when PBFields::FORESTF # Forest Field
              next if i.hp<=0
              if i.ability == PBAbilities::SAPSIPPER && i.effects[PBEffects::HealBlock]==0
                hpgain=(i.totalhp/16.0).floor
                hpgain=i.pbRecoverHP(hpgain,true)
                pbDisplay(_INTL("{1} drank tree sap to recover!",i.pbThis)) if hpgain>0
              end
            when PBFields::SHORTCIRCUITF # Shortcircuit Field
              next if i.hp<=0
              if i.ability == PBAbilities::VOLTABSORB && i.effects[PBEffects::HealBlock]==0
                hpgain=(i.totalhp/16.0).floor
                hpgain=i.pbRecoverHP(hpgain,true)
                pbDisplay(_INTL("{1} absorbed stray electricity!",i.pbThis)) if hpgain>0
              end
            when PBFields::WASTELAND # Wasteland
              if i.ability == PBAbilities::POISONHEAL && !i.isAirborne? && i.effects[PBEffects::HealBlock]==0 && i.hp<i.totalhp
                pbCommonAnimation("Poison",i,nil)
                i.pbRecoverHP((i.totalhp/8.0).floor,true)
                pbDisplay(_INTL("{1} was healed by poison!",i.pbThis))
              end
            when PBFields::WATERS # Water Surface
              next if i.hp<=0
              if (i.ability == PBAbilities::WATERABSORB || i.ability == PBAbilities::DRYSKIN) && i.effects[PBEffects::HealBlock]==0 && !i.isAirborne?
                hpgain=(i.totalhp/16.0).floor
                hpgain=i.pbRecoverHP(hpgain,true)
                pbDisplay(_INTL("{1} absorbed some of the water!",i.pbThis)) if hpgain>0
              end
            when PBFields::UNDERWATER
              next if i.hp<=0
              if (i.ability == PBAbilities::WATERABSORB || i.ability == PBAbilities::DRYSKIN) && i.effects[PBEffects::HealBlock]==0
                hpgain=(i.totalhp/16.0).floor
                hpgain=i.pbRecoverHP(hpgain,true)
                pbDisplay(_INTL("{1} absorbed some of the water!",i.pbThis)) if hpgain>0
              end
              if i.underwaterFieldPassiveDamamge?
                eff=PBTypes.getCombinedEffectiveness(PBTypes::WATER,i.type1,i.type2)
                if eff>4
                  @scene.pbDamageAnimation(i,0)
                  if i.ability == PBAbilities::FLAMEBODY || i.ability == PBAbilities::MAGMAARMOR
                    eff = eff*2
                  end
                  i.pbReduceHP([(i.totalhp*eff/32).floor,1].max)
                  pbDisplay(_INTL("{1} struggled in the water!",i.pbThis))
                  if i.hp<=0
                    return if !i.pbFaint
                  end
                end
              end
            when PBFields::MURKWATERS # Murkwater Surface
              if i.murkyWaterSurfacePassiveDamage?
                eff=PBTypes.getCombinedEffectiveness(PBTypes::POISON,i.type1,i.type2)
                if i.ability == PBAbilities::FLAMEBODY || i.ability == PBAbilities::MAGMAARMOR || i.ability == PBAbilities::DRYSKIN || i.ability == PBAbilities::WATERABSORB
                  eff = eff*2
                end
                if $cache.pkmn_move[i.effects[PBEffects::TwoTurnAttack]][PBMoveData::FUNCTION]==0xCB # Dive
                  @scene.pbDamageAnimation(i,0)
                  i.pbReduceHP([(i.totalhp*eff/8).floor,1].max)
                  pbDisplay(_INTL("{1} suffocated underneath the toxic water!",i.pbThis))
                elsif !i.isAirborne?
                  @scene.pbDamageAnimation(i,0)
                  i.pbReduceHP([(i.totalhp*eff/32).floor,1].max)
                  pbDisplay(_INTL("{1} was hurt by the toxic water!",i.pbThis))
                end
              end
              if i.isFainted?
                return if !i.pbFaint
              end
              if i.pbHasType?(:POISON) && (i.ability == PBAbilities::DRYSKIN || i.ability == PBAbilities::WATERABSORB) || i.ability == PBAbilities::POISONHEAL  && !i.isAirborne? && i.effects[PBEffects::HealBlock]==0 && i.hp<i.totalhp
                pbCommonAnimation("Poison",i,nil)
                i.pbRecoverHP((i.totalhp/8.0).floor,true)
                pbDisplay(_INTL("{1} was healed by the poisoned water!",i.pbThis))
              end
          end
        end
        # End Field stuff
        # Weather
        # Unsure what this is really doing, cass thinks it's probably nothing. But just in case ?? ~a
        #if @field.effect != PBFields::UNDERWATER
        #  @field.counter = 0 if @weather != PBWeather::HAIL && @field.effect == PBFields::MOUNTAIN
        #end
        case @weather
          when PBWeather::SUNNYDAY
            @weatherduration=@weatherduration-1 if @weatherduration>0
            if @weatherduration==0
              pbDisplay(_INTL("The sunlight faded."))
              pbDisplay(_INTL("The starry sky shone through!")) if @field.effect == PBFields::STARLIGHTA
              @weather=0
            else
              pbCommonAnimation("Sunny")
              if @field.effect == PBFields::DARKCRYSTALC #Dark Crystal Cavern
                setField(PBFields::CRYSTALC,true)
                @field.duration = @weatherduration + 1
                @field.duration_condition = proc {|battle| battle.weather == PBWeather::SUNNYDAY}
                @field.permanent_condition = proc {|battle| battle.FE != PBFields::CRYSTALC}
                pbDisplay(_INTL("The sun lit up the crystal cavern!"))
              end
              if pbWeather == PBWeather::SUNNYDAY
                for i in priority
                  next if i.isFainted?
                  if i.ability == PBAbilities::SOLARPOWER
                    pbDisplay(_INTL("{1} was hurt by the sunlight!",i.pbThis))
                    @scene.pbDamageAnimation(i,0)
                    i.pbReduceHP((i.totalhp/8.0).floor)
                    if i.isFainted?
                      return if !i.pbFaint
                    end
                  end
                end
              end
            end
          when PBWeather::RAINDANCE
            @weatherduration=@weatherduration-1 if @weatherduration>0
            if @weatherduration==0
              pbDisplay(_INTL("The rain stopped."))
              pbDisplay(_INTL("The starry sky shone through!")) if @field.effect == PBFields::STARLIGHTA
              @weather=0
            else
              pbCommonAnimation("Rain")
              if @field.effect == PBFields::BURNINGF
                breakField
                pbDisplay(_INTL("The rain snuffed out the flame!"));
              end
            end
          when PBWeather::SANDSTORM
            @weatherduration=@weatherduration-1 if @weatherduration>0
            if @weatherduration==0
              pbDisplay(_INTL("The sandstorm subsided."))
              pbDisplay(_INTL("The starry sky shone through!")) if @field.effect == PBFields::STARLIGHTA
              @weather=0
            else
              pbCommonAnimation("Sandstorm")
              if @field.effect == PBFields::BURNINGF
                breakField
                pbDisplay(_INTL("The sand snuffed out the flame!"));
              end
              if @field.effect == PBFields::RAINBOWF
                breakField if @field.duration == 0
                endTempField if @field.duration > 0
                pbDisplay(_INTL("The weather blocked out the rainbow!"));
              end
              if pbWeather==PBWeather::SANDSTORM
                endmessage=false
                for i in priority
                  next if i.isFainted?
                  if !i.pbHasType?(:GROUND) && !i.pbHasType?(:ROCK) && !i.pbHasType?(:STEEL) && !(i.ability == PBAbilities::SANDVEIL  || i.ability == PBAbilities::SANDRUSH ||
                    i.ability == PBAbilities::SANDFORCE || i.ability == PBAbilities::MAGICGUARD || i.ability == PBAbilities::OVERCOAT) &&
                  !(i.item == PBItems::SAFETYGOGGLES) && ![0xCA,0xCB].include?($cache.pkmn_move[i.effects[PBEffects::TwoTurnAttack]][PBMoveData::FUNCTION]) # Dig, Dive
                    pbDisplay(_INTL("The Pokemon were buffeted by the sandstorm!",i.pbThis)) if endmessage==false
                    endmessage=true
                    @scene.pbDamageAnimation(i,0)
                    i.pbReduceHP((i.totalhp/16.0).floor)
                    if i.isFainted?
                      return if !i.pbFaint
                    end
                  end
                end
              end
            end
          when PBWeather::HAIL
            @weatherduration=@weatherduration-1 if @weatherduration>0
            if @weatherduration==0
              pbDisplay(_INTL("The hail stopped."))
              pbDisplay(_INTL("The starry sky shone through!")) if @field.effect == PBFields::STARLIGHTA
              @weather=0
            elsif @field.effect == PBFields::SUPERHEATEDF
              pbDisplay(_INTL("The hail melted away."))
              @weather=0
            else
              pbCommonAnimation("Hail")
              if @field.effect == PBFields::RAINBOWF
                breakField if @field.duration == 0
                endTempField if @field.duration > 0
                pbDisplay(_INTL("The weather blocked out the rainbow!"));
              end
              if pbWeather==PBWeather::HAIL
                endmessage=false
                for i in priority
                  next if i.isFainted?
                  if !i.pbHasType?(:ICE) && i.ability != PBAbilities::ICEBODY && i.ability != PBAbilities::SNOWCLOAK && i.ability != PBAbilities::MAGICGUARD &&
                    !(i.item == PBItems::SAFETYGOGGLES) && i.ability != PBAbilities::OVERCOAT && ![0xCA,0xCB].include?($cache.pkmn_move[i.effects[PBEffects::TwoTurnAttack]][PBMoveData::FUNCTION]) # Dig, Dive
                    pbDisplay(_INTL("The Pokemon were buffeted by the hail!",i.pbThis)) if endmessage==false
                    endmessage=true
                    @scene.pbDamageAnimation(i,0)
                    i.pbReduceHP((i.totalhp/16.0).floor)
                    if i.isFainted?
                      return if !i.pbFaint
                    end
                  end
                end
                if @field.effect  == PBFields::MOUNTAIN
                  @field.counter+=1
                  if @field.counter == 3
                    setField(PBFields::SNOWYM)
                    pbDisplay(_INTL("The mountain was covered in snow!"))
                  end
                end
              end
            end
          when PBWeather::STRONGWINDS
            pbCommonAnimation("Wind")
        end
        # Shadow Sky weather
        if isConst?(@weather,PBWeather,:SHADOWSKY) #leaving this call alone
          @weatherduration=@weatherduration-1 if @weatherduration>0
          if @weatherduration==0
            pbDisplay(_INTL("The shadow sky faded."))
            @weather=0
          else
            pbCommonAnimation("ShadowSky")
            if isConst?(pbWeather,PBWeather,:SHADOWSKY)
              for i in priority
                next if i.isFainted?
                if !i.isShadow?
                  pbDisplay(_INTL("{1} was hurt by the shadow sky!",i.pbThis))
                  @scene.pbDamageAnimation(i,0)
                  i.pbReduceHP((i.totalhp/16.0).floor)
                  if i.isFainted?
                    return if !i.pbFaint
                  end
                end
              end
            end
          end
        end
        # Future Sight/Doom Desire
        for i in battlers   # not priority
          next if i.effects[PBEffects::FutureSight]<=0
          i.effects[PBEffects::FutureSight]-=1
          next if i.isFainted? || i.effects[PBEffects::FutureSight]!=0
          moveuser=nil
          #check if battler on the field
          move, moveuser, disabled_items = i.pbFutureSightUserPlusMove
          type = move.type
          pbDisplay(_INTL("{1} took the {2} attack!",i.pbThis,move.name))
          typemod = move.pbTypeModifier(type,moveuser,i)
          twoturninvul = PBStuff::TWOTURNMOVE.include?(i.effects[PBEffects::TwoTurnAttack])
          if (i.isFainted? || move.pbAccuracyCheck(moveuser,i) && !(i.ability == PBAbilities::WONDERGUARD && typemod<=4)) && !twoturninvul
            i.damagestate.reset
            damage = nil
            if i.effects[PBEffects::FutureSightMove] == PBMoves::FUTURESIGHT && !(i.pbHasType?(:DARK))
              moveuser.hp != 0 ? pbAnimation(PBMoves::FUTUREDUMMY,moveuser,i) : pbAnimation(PBMoves::FUTUREDUMMY,i,i)
            elsif i.effects[PBEffects::FutureSightMove] == PBMoves::DOOMDESIRE
              moveuser.hp != 0 ? pbAnimation(PBMoves::DOOMDUMMY,moveuser,i) : pbAnimation(PBMoves::DOOMDUMMY,i,i)
            end
            move.pbReduceHPDamage(damage,moveuser,i)
            move.pbEffectMessages(moveuser,i)
          elsif i.ability == PBAbilities::WONDERGUARD && typemod<=4 && !twoturninvul
            pbDisplay(_INTL("{1} avoided damage with Wonder Guard!",i.pbThis))
          else
            pbDisplay(_INTL("But it failed!"))
          end
          i.effects[PBEffects::FutureSight]=0
          i.effects[PBEffects::FutureSightMove]=0
          i.effects[PBEffects::FutureSightUser]=-1
          if !disabled_items.empty?
            moveuser.item = disabled_items[:item]
            moveuser.ability = disabled_items[:ability]
          end
          if i.isFainted?
            return if !i.pbFaint
            next
          end
        end
        for i in priority
          next if i.isFainted?
          # Rain Dish
          if i.ability == PBAbilities::RAINDISH && (pbWeather==PBWeather::RAINDANCE && !i.hasWorkingItem(:UTILITYUMBRELLA)) && i.effects[PBEffects::HealBlock]==0
            hpgain=i.pbRecoverHP((i.totalhp/16.0).floor,true)
            pbDisplay(_INTL("{1}'s Rain Dish restored its HP a little!",i.pbThis)) if hpgain>0
          end
    
          # Dry Skin
          if (i.ability == PBAbilities::DRYSKIN)
            if (pbWeather==PBWeather::RAINDANCE && !i.hasWorkingItem(:UTILITYUMBRELLA)) && i.effects[PBEffects::HealBlock]==0
              hpgain=i.pbRecoverHP((i.totalhp/8.0).floor,true)
              pbDisplay(_INTL("{1}'s Dry Skin was healed by the rain!",i.pbThis)) if hpgain>0
            elsif (pbWeather==PBWeather::SUNNYDAY && !i.hasWorkingItem(:UTILITYUMBRELLA))
              @scene.pbDamageAnimation(i,0)
              hploss=i.pbReduceHP((i.totalhp/8.0).floor)
              pbDisplay(_INTL("{1}'s Dry Skin was hurt by the sunlight!",i.pbThis)) if hploss>0
            elsif @field.effect == PBFields::CORROSIVEMISTF && !i.pbHasType?(:STEEL)
              if !i.pbHasType?(:POISON)
                @scene.pbDamageAnimation(i,0)
                hploss=i.pbReduceHP((i.totalhp/8.0).floor)
                pbDisplay(_INTL("{1}'s Dry Skin absorbed the poison!",i.pbThis)) if hploss>0
              elsif i.effects[PBEffects::HealBlock]==0
                hpgain=i.pbRecoverHP((i.totalhp/8.0).floor,true)
                pbDisplay(_INTL("{1}'s Dry Skin was healed by the poison!",i.pbThis)) if hpgain>0
              end
            elsif @field.effect == PBFields::DESERTF
              @scene.pbDamageAnimation(i,0)
              hploss=i.pbReduceHP((i.totalhp/8.0).floor)
              pbDisplay(_INTL("{1}'s Dry Skin was hurt by the desert air!",i.pbThis)) if hploss>0
            elsif @field.effect == PBFields::MISTYT
              hpgain=0
              if i.effects[PBEffects::HealBlock]==0
                hpgain=(i.totalhp/16.0).floor
                hpgain=i.pbRecoverHP(hpgain,true)
              end
              pbDisplay(_INTL("{1}'s Dry Skin was healed by the mist!",i.pbThis)) if hpgain>0
            elsif @field.effect == PBFields::SWAMPF  # Swamp Field
              hpgain=0
              if i.effects[PBEffects::HealBlock]==0
                hpgain=(i.totalhp/16.0).floor
                hpgain=i.pbRecoverHP(hpgain,true)
              end
              pbDisplay(_INTL("{1}'s Dry Skin was healed by the murk!",i.pbThis)) if hpgain>0
            end
          end
          # Ice Body
          if i.ability == PBAbilities::ICEBODY && (pbWeather==PBWeather::HAIL || @field.effect == PBFields::ICYF || @field.effect == PBFields::SNOWYM) && i.effects[PBEffects::HealBlock]==0
            hpgain=i.pbRecoverHP((i.totalhp/16.0).floor,true)
            pbDisplay(_INTL("{1}'s Ice Body restored its HP a little!",i.pbThis)) if hpgain>0
          end
          if i.isFainted?
            return if !i.pbFaint
            next
          end
        end
        # Wish
        for i in priority
          if i.effects[PBEffects::Wish]>0
            i.effects[PBEffects::Wish]-=1
            if i.effects[PBEffects::Wish]==0
              next if i.isFainted?
              hpgain=i.pbRecoverHP(i.effects[PBEffects::WishAmount],true)
              if hpgain>0
                wishmaker=pbThisEx(i.index,i.effects[PBEffects::WishMaker])
                pbDisplay(_INTL("{1}'s wish came true!",wishmaker))
              end
            end
          end
        end
        # Fire Pledge + Grass Pledge combination damage - should go here
        for i in priority
          next if i.isFainted?
          # Shed Skin
          if i.ability == PBAbilities::SHEDSKIN
            if (pbRandom(10)<3 || @field.effect == PBFields::DRAGONSD) && i.status>0
              pbDisplay(_INTL("{1}'s Shed Skin cured its {2} problem!",i.pbThis,STATUSTEXTS[i.status]))
              i.status=0
              i.statusCount=0
              if @field.effect == PBFields::DRAGONSD
                pbDisplay(_INTL("{1}'s scaled sheen glimmers brightly!",i.pbThis))
                if i.effects[PBEffects::HealBlock]==0
                  hpgain=(i.totalhp/4.0).floor
                  hpgain=i.pbRecoverHP(hpgain,true)
                end
                animDDShedSkin = true 
                if !i.pbTooHigh?(PBStats::SPEED)
                  i.pbIncreaseStatBasic(PBStats::SPEED,1)
                  pbCommonAnimation("StatUp",i,nil)
                  animDDShedSkin = false
                end
                if !i.pbTooHigh?(PBStats::SPATK)
                  i.pbIncreaseStatBasic(PBStats::SPATK,1)
                  pbCommonAnimation("StatUp",i,nil) if animDDShedSkin == true
                end
                animDDShedSkin = true 
                if !i.pbTooLow?(PBStats::DEFENSE)
                  i.pbReduceStat(PBStats::DEFENSE,1)
                  pbCommonAnimation("StatDown",i,nil)
                  animDDShedSkin = false
                end
                if !i.pbTooLow?(PBStats::SPDEF)
                  i.pbReduceStat(PBStats::SPDEF,1)
                  pbCommonAnimation("StatDown",i,nil) if animDDShedSkin == true
                end
              end
            end
          end
          # Hydration
          if i.ability == PBAbilities::HYDRATION && ((pbWeather==PBWeather::RAINDANCE && !i.hasWorkingItem(:UTILITYUMBRELLA)) || @field.effect == PBFields::WATERS || @field.effect == PBFields::UNDERWATER)
            if i.status>0
              pbDisplay(_INTL("{1}'s Hydration cured its {2} problem!",i.pbThis,STATUSTEXTS[i.status]))
              i.status=0
              i.statusCount=0
            end
          end
          if i.ability == PBAbilities::WATERVEIL && (@field.effect == PBFields::WATERS || @field.effect == PBFields::UNDERWATER)
            if i.status>0
              pbDisplay(_INTL("{1}'s Water Veil cured its status problem!",i.pbThis))
              i.status=0
              i.statusCount=0
            end
          end
          # Healer
          if i.ability == PBAbilities::HEALER
            partner=i.pbPartner
            if partner
              if pbRandom(10)<3 && partner.status>0
                pbDisplay(_INTL("{1}'s Healer cured its partner's {2} problem!",i.pbThis,STATUSTEXTS[partner.status]))
                partner.status=0
                partner.statusCount=0
              end
            end
          end
        end
        # Held berries/Leftovers/Black Sludge
        for i in priority
          next if i.isFainted?
          i.pbBerryCureCheck(true)
          if i.isFainted?
            return if !i.pbFaint
            next
          end
        end
        # Aqua Ring
        for i in priority
          next if i.hp<=0
          if i.effects[PBEffects::AquaRing]
            if @field.effect == PBFields::CORROSIVEMISTF && !i.pbHasType?(:STEEL) && !i.pbHasType?(:POISON)
              @scene.pbDamageAnimation(i,0)
              i.pbReduceHP((i.totalhp/16.0).floor)
              pbDisplay(_INTL("{1}'s Aqua Ring absorbed poison!",i.pbThis))
              if i.hp<=0
                return if !i.pbFaint
              end
            elsif i.effects[PBEffects::HealBlock]==0
              hpgain=(i.totalhp/16.0).floor
              hpgain=(hpgain*1.3).floor if (i.item == PBItems::BIGROOT)
              hpgain=(hpgain*2).floor if [PBFields::MISTYT,PBFields::SWAMPF,PBFields::WATERS,PBFields::UNDERWATER].include?(@field.effect)
              hpgain=i.pbRecoverHP(hpgain,true)
              pbDisplay(_INTL("{1}'s Aqua Ring restored its HP a little!",i.pbThis)) if hpgain>0
            end
          end
        end
        # Ingrain
        for i in priority
          next if i.hp<=0
          if i.effects[PBEffects::Ingrain]
            if (@field.effect == PBFields::SWAMPF || @field.effect == PBFields::CORROSIVEF) && (!i.pbHasType?(:STEEL) && !i.pbHasType?(:POISON))
              @scene.pbDamageAnimation(i,0)
              i.pbReduceHP((i.totalhp/16.0).floor)
              pbDisplay(_INTL("{1} absorbed foul nutrients with its roots!",i.pbThis))
              if i.hp<=0
                return if !i.pbFaint
              end
            else
              if (@field.effect == PBFields::FLOWERGARDENF && @field.counter >2)
                hpgain=(i.totalhp/4.0).floor
              elsif (@field.effect == PBFields::FORESTF || (@field.effect == PBFields::FLOWERGARDENF && @field.counter >0))
                hpgain=(i.totalhp/8.0).floor
              elsif i.effects[PBEffects::HealBlock]==0
                hpgain=(i.totalhp/16.0).floor
              end
              if i.effects[PBEffects::HealBlock]==0
                hpgain=(hpgain*1.3).floor if (i.item == PBItems::BIGROOT)
                hpgain=i.pbRecoverHP(hpgain,true)
                pbDisplay(_INTL("{1} absorbed nutrients with its roots!",i.pbThis)) if hpgain>0
              end
            end
          end
        end
        # Leech Seed
        for i in priority
          if !i.abilityWorks?(true) && i.ability == PBAbilities::LIQUIDOOZE && i.effects[PBEffects::LeechSeed]>=0
            recipient=@battlers[i.effects[PBEffects::LeechSeed]]
            if recipient && !recipient.isFainted?
              hploss=(i.totalhp/8.0).floor
              hploss= hploss * 2 if @field.effect == PBFields::WASTELAND 
              pbCommonAnimation("LeechSeed",recipient,i)
              i.pbReduceHP(hploss,true)
              hploss= hploss / 2 if @field.effect == PBFields::WASTELAND
              hploss= hploss * 2 if @field.effect == PBFields::MURKWATERS
              recipient.pbReduceHP(hploss,true)
              pbDisplay(_INTL("{1} sucked up the liquid ooze!",recipient.pbThis))
              if i.isFainted?
                return if !i.pbFaint
              end
              if recipient.isFainted?
                return if !recipient.pbFaint
              end
              next
            end
          end
          next if i.isFainted?
          if i.effects[PBEffects::LeechSeed]>=0
            recipient=@battlers[i.effects[PBEffects::LeechSeed]]
            if recipient && !recipient.isFainted?  &&
              i.ability != PBAbilities::MAGICGUARD # if recipient exists
              pbCommonAnimation("LeechSeed",recipient,i)
              hploss=i.pbReduceHP((i.totalhp/8.0).floor,true)
              hploss= hploss * 2 if @field.effect == PBFields::WASTELAND
              if recipient.effects[PBEffects::HealBlock]==0
                hploss=(hploss*1.3).floor if recipient.hasWorkingItem(:BIGROOT)
                recipient.pbRecoverHP(hploss,true)
                pbDisplay(_INTL("{1}'s health was sapped by Leech Seed!",i.pbThis))
              end
              if i.isFainted?
                return if !i.pbFaint
              end
              if recipient.isFainted?
                return if !recipient.pbFaint
              end
            end
          end
        end
    
        for i in priority
          next if i.isFainted?
          # Poison/Bad poison
          if i.status==PBStatuses::POISON && i.ability != PBAbilities::MAGICGUARD
            if i.ability == PBAbilities::POISONHEAL
              if i.effects[PBEffects::HealBlock]==0
                if i.hp<i.totalhp
                  pbCommonAnimation("Poison",i,nil)
                  i.pbRecoverHP((i.totalhp/8.0).floor,true)
                  pbDisplay(_INTL("{1} is healed by poison!",i.pbThis))
                end
                if i.statusCount>0
                  i.effects[PBEffects::Toxic]+=1
                  i.effects[PBEffects::Toxic]=[15,i.effects[PBEffects::Toxic]].min
                end
              end
            else
              i.pbContinueStatus
              if i.statusCount==0
                i.pbReduceHP((i.totalhp/8.0).floor)
              else
                i.effects[PBEffects::Toxic]+=1
                i.effects[PBEffects::Toxic]=[15,i.effects[PBEffects::Toxic]].min
                i.pbReduceHP((i.totalhp/16.0).floor*i.effects[PBEffects::Toxic])
              end
            end
          end
          # Burn
          if i.status==PBStatuses::BURN && i.ability != PBAbilities::MAGICGUARD
            i.pbContinueStatus
            if i.ability == PBAbilities::HEATPROOF || @field.effect == PBFields::ICYF
              i.pbReduceHP((i.totalhp/32.0).floor)
            else
              i.pbReduceHP((i.totalhp/16.0).floor)
            end
          end
          if i.status==PBStatuses::FROZEN && i.ability != PBAbilities::MAGICGUARD
            i.pbContinueStatus
            i.pbReduceHP((i.totalhp/16.0).floor)
          end
          # Nightmare
          if i.effects[PBEffects::Nightmare] && i.ability != PBAbilities::MAGICGUARD && @field.effect != PBFields::RAINBOWF
            if i.status==PBStatuses::SLEEP
              pbCommonAnimation("Nightmare",i,nil)
              pbDisplay(_INTL("{1} is locked in a nightmare!",i.pbThis))
              i.pbReduceHP((i.totalhp/4.0).floor,true)
            else
              i.effects[PBEffects::Nightmare]=false
            end
          end
          if i.isFainted?
            return if !i.pbFaint
            next
          end
        end
         # Curse
        for i in priority
          next if i.isFainted?
          next if !i.effects[PBEffects::Curse]
          if @field.effect == PBFields::HOLYF 
            i.effects[PBEffects::Curse] = false
            pbDisplay(_INTL("{1}'s curse was lifted!",i.pbThis))
          end
          if i.ability != PBAbilities::MAGICGUARD
            pbCommonAnimation("Curse",i,nil)
            pbDisplay(_INTL("{1} is afflicted by the curse!",i.pbThis))
            i.pbReduceHP((i.totalhp/4.0).floor,true)
          end
          if i.isFainted?
            return if !i.pbFaint
            next
          end
        end
        # Multi-turn attacks (Bind/Clamp/Fire Spin/Magma Storm/Sand Tomb/Whirlpool/Wrap)
        for i in priority
          next if i.isFainted?
          i.pbBerryCureCheck
          if i.effects[PBEffects::MultiTurn]>0
            i.effects[PBEffects::MultiTurn]-=1
            movename=PBMoves.getName(i.effects[PBEffects::MultiTurnAttack])
            if i.effects[PBEffects::MultiTurn]==0
              pbDisplay(_INTL("{1} was freed from {2}!",i.pbThis,movename))
              $bindingband=0
            elsif !(i.ability == PBAbilities::MAGICGUARD)
              pbDisplay(_INTL("{1} is hurt by {2}!",i.pbThis,movename))
              if (i.effects[PBEffects::MultiTurnAttack] == PBMoves::BIND)
                pbCommonAnimation("Bind",i,nil)
              elsif (i.effects[PBEffects::MultiTurnAttack] == PBMoves::CLAMP)
                pbCommonAnimation("Clamp",i,nil)
              elsif (i.effects[PBEffects::MultiTurnAttack] == PBMoves::FIRESPIN)
                pbCommonAnimation("FireSpin",i,nil)
              elsif (i.effects[PBEffects::MultiTurnAttack] == PBMoves::MAGMASTORM)
                pbCommonAnimation("Magma Storm",i,nil)
              elsif (i.effects[PBEffects::MultiTurnAttack] == PBMoves::SANDTOMB)
                pbCommonAnimation("SandTomb",i,nil)
              elsif (i.effects[PBEffects::MultiTurnAttack] == PBMoves::WRAP)
                pbCommonAnimation("Wrap",i,nil)
              elsif (i.effects[PBEffects::MultiTurnAttack] == PBMoves::INFESTATION)
                pbCommonAnimation("Infestation",i,nil)
              elsif (i.effects[PBEffects::MultiTurnAttack] == PBMoves::WHIRLPOOL)
                pbCommonAnimation("Whirlpool",i,nil)
              else
                pbCommonAnimation("Wrap",i,nil)
              end
              @scene.pbDamageAnimation(i,0)
              if $bindingband==1
                i.pbReduceHP((i.totalhp/6.0).floor)
              elsif (i.effects[PBEffects::MultiTurnAttack] == PBMoves::MAGMASTORM) && @field.effect == PBFields::DRAGONSD
                i.pbReduceHP((i.totalhp/6.0).floor)
              elsif (i.effects[PBEffects::MultiTurnAttack] == PBMoves::SANDTOMB) && @field.effect == PBFields::DESERTF
                i.pbReduceHP((i.totalhp/6.0).floor)
              elsif (i.effects[PBEffects::MultiTurnAttack] == PBMoves::WHIRLPOOL) && (@field.effect == PBFields::WATERS || @field.effect == PBFields::UNDERWATER)
                i.pbReduceHP((i.totalhp/6.0).floor)
              elsif (i.effects[PBEffects::MultiTurnAttack] == PBMoves::INFESTATION) && @field.effect == PBFields::FORESTF
                i.pbReduceHP((i.totalhp/6.0).floor)
              elsif (i.effects[PBEffects::MultiTurnAttack] == PBMoves::FIRESPIN) && @field.effect == PBFields::BURNINGF
                i.pbReduceHP((i.totalhp/6.0).floor)
              elsif (i.effects[PBEffects::MultiTurnAttack] == PBMoves::INFESTATION) && @field.effect == PBFields::FLOWERGARDENF && @field.counter > 1
                case @field.counter
                  when 2 then i.pbReduceHP((i.totalhp/6.0).floor)
                  when 3 then i.pbReduceHP((i.totalhp/4.0).floor)
                  when 4 then i.pbReduceHP((i.totalhp/3.0).floor)
                end
              else
                i.pbReduceHP((i.totalhp/8.0).floor)
              end
              if (i.effects[PBEffects::MultiTurnAttack] == PBMoves::SANDTOMB) && @field.effect == PBFields::ASHENB
                i.pbReduceStat(PBStats::ACCURACY,1,abilitymessage:true)
              end
            end
          end
          if i.hp<=0
            return if !i.pbFaint
            next
          end
        end
        # Taunt
        for i in priority
          next if i.isFainted?
          next if i.effects[PBEffects::Taunt] == 0
          i.effects[PBEffects::Taunt]-=1
          if i.effects[PBEffects::Taunt]==0
            pbDisplay(_INTL("{1} recovered from the taunting!",i.pbThis))
          end
        end
        # Encore
        for i in priority
          next if i.isFainted?
          next if i.effects[PBEffects::Encore] == 0
          if i.moves[i.effects[PBEffects::EncoreIndex]].id!=i.effects[PBEffects::EncoreMove]
            i.effects[PBEffects::Encore]=0
            i.effects[PBEffects::EncoreIndex]=0
            i.effects[PBEffects::EncoreMove]=0
          else
            i.effects[PBEffects::Encore]-=1
            if i.effects[PBEffects::Encore]==0 || i.moves[i.effects[PBEffects::EncoreIndex]].pp==0
              i.effects[PBEffects::Encore]=0
              pbDisplay(_INTL("{1}'s encore ended!",i.pbThis))
            end
          end
        end
        # Disable/Cursed Body
        for i in priority
          next if i.isFainted?
          next if i.effects[PBEffects::Disable]==0
          i.effects[PBEffects::Disable]-=1
          if i.effects[PBEffects::Disable]==0
            i.effects[PBEffects::DisableMove]=0
            pbDisplay(_INTL("{1} is disabled no more!",i.pbThis))
          end
        end
        # Magnet Rise
        for i in priority
          next if i.isFainted?
          if i.effects[PBEffects::MagnetRise]>0
            i.effects[PBEffects::MagnetRise]-=1
            if i.effects[PBEffects::MagnetRise]==0
              pbDisplay(_INTL("{1} stopped levitating.",i.pbThis))
            end
          end
        end
        # Telekinesis
        for i in priority
          next if i.isFainted?
          if i.effects[PBEffects::Telekinesis]>0
            i.effects[PBEffects::Telekinesis]-=1
            if i.effects[PBEffects::Telekinesis]==0
              pbDisplay(_INTL("{1} stopped levitating.",i.pbThis))
            end
          end
        end
        # Heal Block
        for i in priority
          next if i.isFainted?
          if i.effects[PBEffects::HealBlock]>0
            i.effects[PBEffects::HealBlock]-=1
            if i.effects[PBEffects::HealBlock]==0
              pbDisplay(_INTL("The heal block on {1} ended.",i.pbThis))
            end
          end
        end
        # Embargo
        for i in priority
          next if i.isFainted?
          if i.effects[PBEffects::Embargo]>0
            i.effects[PBEffects::Embargo]-=1
            if i.effects[PBEffects::Embargo]==0
              pbDisplay(_INTL("The embargo on {1} was lifted.",i.pbThis(true)))
            end
          end
        end
        # Yawn
        for i in priority
          next if i.isFainted?
          if i.effects[PBEffects::Yawn]>0
            i.effects[PBEffects::Yawn]-=1
            if i.effects[PBEffects::Yawn]==0 && i.pbCanSleepYawn?
              i.pbSleep
              pbDisplay(_INTL("{1} fell asleep!",i.pbThis))
              i.pbBerryCureCheck
            end
          end
        end
        # Perish Song
        perishSongUsers=[]
        for i in priority
          next if i.isFainted?
          if i.effects[PBEffects::PerishSong]>0
            i.effects[PBEffects::PerishSong]-=1
            pbDisplay(_INTL("{1}'s Perish count fell to {2}!",i.pbThis,i.effects[PBEffects::PerishSong]))
            if i.effects[PBEffects::PerishSong]==0
              perishSongUsers.push(i.effects[PBEffects::PerishSongUser])
              i.pbReduceHP(i.hp,true)
            end
          end
          if i.isFainted?
            return if !i.pbFaint
          end
        end
        if perishSongUsers.length>0
          # If all remaining Pokemon fainted by a Perish Song triggered by a single side
          if (perishSongUsers.find_all{|item| pbIsOpposing?(item) }.length==perishSongUsers.length) ||
             (perishSongUsers.find_all{|item| !pbIsOpposing?(item) }.length==perishSongUsers.length)
            pbJudgeCheckpoint(@battlers[perishSongUsers[0]])
          end
        end
        if @decision>0
          pbGainEXP
          return
        end
        # Reflect
        for i in 0...2
          if sides[i].effects[PBEffects::Reflect]>0
            sides[i].effects[PBEffects::Reflect]-=1
            if sides[i].effects[PBEffects::Reflect]==0
              pbDisplay(_INTL("Your team's Reflect faded!")) if i==0
              pbDisplay(_INTL("The opposing team's Reflect faded!")) if i==1
            end
          end
        end
        # Light Screen
        for i in 0...2
          if sides[i].effects[PBEffects::LightScreen]>0
            sides[i].effects[PBEffects::LightScreen]-=1
            if sides[i].effects[PBEffects::LightScreen]==0
              pbDisplay(_INTL("Your team's Light Screen faded!")) if i==0
              pbDisplay(_INTL("The opposing team's Light Screen faded!")) if i==1
            end
          end
        end
        # Aurora Veil
        for i in 0...2
          if sides[i].effects[PBEffects::AuroraVeil]>0
            sides[i].effects[PBEffects::AuroraVeil]-=1
            if sides[i].effects[PBEffects::AuroraVeil]==0
              pbDisplay(_INTL("Your team's Aurora Veil faded!")) if i==0
              pbDisplay(_INTL("The opposing team's Aurora Veil faded!")) if i==1
            end
          end
        end
        # Safeguard
        for i in 0...2
          if sides[i].effects[PBEffects::Safeguard]>0
            sides[i].effects[PBEffects::Safeguard]-=1
            if sides[i].effects[PBEffects::Safeguard]==0
              pbDisplay(_INTL("Your team is no longer protected by Safeguard!")) if i==0
              pbDisplay(_INTL("The opposing team is no longer protected by Safeguard!")) if i==1
            end
          end
        end
        # Mist
        for i in 0...2
          if sides[i].effects[PBEffects::Mist]>0
            sides[i].effects[PBEffects::Mist]-=1
            if sides[i].effects[PBEffects::Mist]==0
              pbDisplay(_INTL("Your team's Mist faded!")) if i==0
              pbDisplay(_INTL("The opposing team's Mist faded!")) if i==1
            end
          end
        end
        # Tailwind
        for i in 0...2
          if sides[i].effects[PBEffects::Tailwind]>0
            sides[i].effects[PBEffects::Tailwind]-=1
            if sides[i].effects[PBEffects::Tailwind]==0
              pbDisplay(_INTL("Your team's tailwind stopped blowing!")) if i==0
              pbDisplay(_INTL("The opposing team's tailwind stopped blowing!")) if i==1
            end
          end
        end
        # Lucky Chant
        for i in 0...2
          if sides[i].effects[PBEffects::LuckyChant]>0
            sides[i].effects[PBEffects::LuckyChant]-=1
            if sides[i].effects[PBEffects::LuckyChant]==0
              pbDisplay(_INTL("Your team's Lucky Chant faded!")) if i==0
              pbDisplay(_INTL("The opposing team's Lucky Chant faded!")) if i==1
            end
          end
        end
        # Mud Sport
        if @state.effects[PBEffects::MudSport]>0
          @state.effects[PBEffects::MudSport]-=1
          if @state.effects[PBEffects::MudSport]==0
            pbDisplay(_INTL("The effects of Mud Sport faded."))
          end
        end
        # Water Sport
        if @state.effects[PBEffects::WaterSport]>0
          @state.effects[PBEffects::WaterSport]-=1
          if @state.effects[PBEffects::WaterSport]==0
            pbDisplay(_INTL("The effects of Water Sport faded."))
          end
        end
        # Gravity
        if @state.effects[PBEffects::Gravity]>0
          @state.effects[PBEffects::Gravity]-=1
          if @state.effects[PBEffects::Gravity]==0
            if @field.backup == PBFields::NEWW && @field.effect != PBFields::NEWW
              breakField
              pbDisplay(_INTL("The world broke apart again!"))
              noWeather
            else
              pbDisplay(_INTL("Gravity returned to normal."))
            end
          end
        end
    
        # Terrain
        if @field.duration>0
          @field.checkPermCondition(self)
        end
        if @field.duration>0
          @field.duration-=1
          @field.duration = 0 if @field.duration_condition && !@field.duration_condition.call(self)
          if @field.duration==0
            endTempField
            pbDisplay(_INTL("The terrain returned to normal."))
            noWeather
          end
        end
        # Trick Room - should go here
        # Wonder Room - should go here
        # Magic Room
        if @state.effects[PBEffects::MagicRoom]>0
          @state.effects[PBEffects::MagicRoom]-=1
          if @state.effects[PBEffects::MagicRoom]==0
            pbDisplay(_INTL("The area returned to normal."))
          end
        end
        # Fairy Lock
        if @state.effects[PBEffects::FairyLock]>0
          @state.effects[PBEffects::FairyLock]-=1
          if @state.effects[PBEffects::FairyLock]==0
            # Fairy Lock seems to have no end-of-effect text so I've added some.
            pbDisplay(_INTL("The Fairy Lock was released."))
          end
        end
        # Uproar
        for i in priority
          next if i.isFainted?
          if i.effects[PBEffects::Uproar]>0
            for j in priority
              if !j.isFainted? && j.status==PBStatuses::SLEEP && !j.hasWorkingAbility(:SOUNDPROOF)
                j.effects[PBEffects::Nightmare]=false
                j.status=0
                j.statusCount=0
                pbDisplay(_INTL("{1} woke up in the uproar!",j.pbThis))
              end
            end
            i.effects[PBEffects::Uproar]-=1
            if i.effects[PBEffects::Uproar]==0
              pbDisplay(_INTL("{1} calmed down.",i.pbThis))
            else
              pbDisplay(_INTL("{1} is making an uproar!",i.pbThis))
            end
          end
        end
    
        # Slow Start's end message
        for i in priority
          next if i.isFainted?
          if i.ability==PBAbilities::SLOWSTART && i.turncount==4
            pbDisplay(_INTL("{1} finally got its act together!",i.pbThis))
          end
        end
    
        #Wasteland hazard interaction
        if @field.effect == PBFields::WASTELAND
          for i in priority
            is_fainted_before = i.isFainted?
            partner_fainted_before = @doublebattle && i.pbPartner.isFainted?
            # Stealth Rock
            if i.pbOwnSide.effects[PBEffects::StealthRock]==true
              pbDisplay(_INTL("The waste swallowed up the pointed stones!"))
              i.pbOwnSide.effects[PBEffects::StealthRock]=false
              pbDisplay(_INTL("...Rocks spewed out from the ground below!"))
              for mon in [i, i.pbPartner]
                next if mon.isFainted? || PBStuff::TWOTURNMOVE.include?(mon.effects[PBEffects::TwoTurnAttack])
                eff=PBTypes.getCombinedEffectiveness(PBTypes::ROCK,mon.type1,mon.type2)
                next if eff <=0
                @scene.pbDamageAnimation(mon,0)
                mon.pbReduceHP([(mon.totalhp*eff/16).floor,1].max)
              end
            end
    
            # Spikes
            if i.pbOwnSide.effects[PBEffects::Spikes]>0
              pbDisplay(_INTL("The waste swallowed up the spikes!"))
              i.pbOwnSide.effects[PBEffects::Spikes]=0
              pbDisplay(_INTL("...Stalagmites burst up from the ground!"))
              for mon in [i, i.pbPartner]
                if !mon.isFainted? && !mon.isAirborne? && !PBStuff::TWOTURNMOVE.include?(mon.effects[PBEffects::TwoTurnAttack]) # Dig, Dive, etc
                  @scene.pbDamageAnimation(mon,0)
                  mon.pbReduceHP([(mon.totalhp/3.0).floor,1].max)
                end
              end
            end
    
            # Toxic Spikes
            if i.pbOwnSide.effects[PBEffects::ToxicSpikes]>0
              pbDisplay(_INTL("The waste swallowed up the toxic spikes!"))
              i.pbOwnSide.effects[PBEffects::ToxicSpikes]=0
              pbDisplay(_INTL("...Poison needles shot up from the ground!"))
              for mon in [i, i.pbPartner]
                next if mon.isFainted? || mon.isAirborne? || mon.pbHasType?(:STEEL) || mon.pbHasType?(:POISON)
                next if PBStuff::TWOTURNMOVE.include?(mon.effects[PBEffects::TwoTurnAttack])
                @scene.pbDamageAnimation(mon,0)
                mon.pbReduceHP([(mon.totalhp/8.0).floor,1].max)
                if mon.status==0 && mon.pbCanPoison?(false)
                  mon.status=PBStatuses::POISON
                  mon.statusCount=1
                  mon.effects[PBEffects::Toxic]=0
                  pbCommonAnimation("Poison",mon,nil)
                end
              end
            end
    
            # Sticky Web
            if i.pbOwnSide.effects[PBEffects::StickyWeb]
              pbDisplay(_INTL("The waste swallowed up the sticky web!"))
              i.pbOwnSide.effects[PBEffects::StickyWeb]=false
              pbDisplay(_INTL("...Sticky string shot out of the ground!"))
              for mon in [i, i.pbPartner]
                next if mon.isFainted? && !PBStuff::TWOTURNMOVE.include?(mon.effects[PBEffects::TwoTurnAttack])
                if mon.ability == PBAbilities::CONTRARY && !mon.pbTooHigh?(PBStats::SPEED)
                  mon.pbIncreaseStatBasic(PBStats::SPEED,4)
                    pbCommonAnimation("StatUp",mon,nil)
                    pbDisplay(_INTL("{1}'s Speed went way up!",mon.pbThis))
                elsif !mon.pbTooLow?(PBStats::SPEED)
                  mon.pbReduceStatBasic(PBStats::SPEED,4)
                  pbCommonAnimation("StatDown",mon,nil)
                  pbDisplay(_INTL("{1}'s Speed was severely lowered!",mon.pbThis))
                end
              end
            end
    
            # Fainting
            if @doublebattle && !partner_fainted_before
              partner=i.pbPartner
              if partner && partner.hp<=0
                partner.pbFaint
              end
            end
            if i.hp<=0 && !is_fainted_before
              return if !i.pbFaint
              next
            end
          end
        end
        # End Wasteland hazards
        for i in priority
          next if i.isFainted?
          # Mimicry
          if i.ability == PBAbilities::MIMICRY
            protype = -1
            case @field.effect
              when PBFields::CRYSTALC
                protype = @field.getRoll
              when PBFields::NEWW
                rnd=pbRandom(18)
                protype = rnd
                protype = 18 if rnd == 9
              else
                protype = FIELDEFFECTS[@field.effect][:MIMICRY] if FIELDEFFECTS[@field.effect][:MIMICRY]
            end
            prot1 = i.type1
            prot2 = i.type2
            camotype = protype
            if camotype>0 && (!i.pbHasType?(camotype) || (defined?(prot2) && prot1 != prot2))
              i.type1=camotype
              i.type2=camotype
              typename=PBTypes.getName(camotype)
              pbDisplay(_INTL("{1} had its type changed to {2}!",i.pbThis,typename))
            end
          end
          # Speed Boost
          # A Pokémon's turncount is 0 if it became active after the beginning of a round
          if i.turncount>0 && (i.ability == PBAbilities::SPEEDBOOST || (@field.effect == PBFields::ELECTRICT && i.ability == PBAbilities::MOTORDRIVE))
            if !i.pbTooHigh?(PBStats::SPEED)
              i.pbIncreaseStatBasic(PBStats::SPEED,1)
              pbCommonAnimation("StatUp",i,nil)
              pbDisplay(_INTL("{1}'s {2} raised its Speed!",i.pbThis, PBAbilities.getName(i.ability)))
            end
          end
          if @field.effect == PBFields::SWAMPF && !(i.ability == PBAbilities::WHITESMOKE) && !(i.ability == PBAbilities::CLEARBODY) && !(i.ability == PBAbilities::QUICKFEET) && !(i.ability == PBAbilities::SWIFTSWIM)
            if !i.isAirborne?
              if !i.pbTooLow?(PBStats::SPEED)
                contcheck = i.ability == PBAbilities::CONTRARY
                candrop = i.pbCanReduceStatStage?(PBStats::SPEED)
                canraise = i.pbCanIncreaseStatStage?(PBStats::SPEED) if contcheck
                i.pbReduceStat(PBStats::SPEED,1, statmessage: false)
                pbDisplay(_INTL("{1}'s Speed sank...",i.pbThis)) if !contcheck && candrop
                pbDisplay(_INTL("{1}'s Speed rose!",i.pbThis)) if contcheck && canraise
              end
            end
          end
          #sleepyswamp
          if i.status==PBStatuses::SLEEP && !(i.ability == PBAbilities::MAGICGUARD)
            if @field.effect == PBFields::SWAMPF # Swamp Field
              hploss=i.pbReduceHP((i.totalhp/16.0).floor,true)
              pbDisplay(_INTL("{1}'s strength is sapped by the swamp!",i.pbThis)) if hploss>0
            end
          end
          if i.hp<=0
            return if !i.pbFaint
            next
          end
          if i.effects[PBEffects::Octolock]
            locklowered = false
            if !i.pbTooLow?(PBStats::DEFENSE)
              contcheck = (i.ability == PBAbilities::CONTRARY)
              i.pbReduceStat(PBStats::DEFENSE,1,abilitymessage:false)
              locklowered = true if !contcheck
            end
            if !i.pbTooLow?(PBStats::SPDEF)
              contcheck = (i.ability == PBAbilities::CONTRARY)
              i.pbReduceStat(PBStats::SPDEF,1,abilitymessage:false)
              locklowered = true if !contcheck
            end
            if locklowered
              pbCommonAnimation("StatDown",i,nil)
              pbDisplay(_INTL("The Octolock lowered {1}'s defenses!",i.pbThis))
            end
          end
          #sleepyrainbow
          if i.status==PBStatuses::SLEEP
            if @field.effect == PBFields::RAINBOWF && i.effects[PBEffects::HealBlock]==0#Rainbow Field
            hpgain=(i.totalhp/16.0).floor
            hpgain=(hpgain*1.3).floor if (i.item == PBItems::BIGROOT)
            hpgain=i.pbRecoverHP(hpgain,true)
            pbDisplay(_INTL("{1} recovered health in its peaceful sleep!",i.pbThis))
            end
          end
          #sleepycorro
          if i.status==PBStatuses::SLEEP && i.ability != PBAbilities::MAGICGUARD && i.ability != PBAbilities::POISONHEAL && i.ability != PBAbilities::TOXICBOOST &&
          i.ability != PBAbilities::WONDERGUARD && !i.isAirborne? && !i.pbHasType?(:STEEL) && !i.pbHasType?(:POISON) && @field.effect == PBFields::CORROSIVEF
            hploss=i.pbReduceHP((i.totalhp/16.0).floor,true)
            pbDisplay(_INTL("{1}'s is seared by the corrosion!",i.pbThis)) if hploss>0
          end
          if i.hp<=0
            return if !i.pbFaint
            next
          end
        # Water Compaction on Water-based Fields
        if i.ability == PBAbilities::WATERCOMPACTION
          if [PBFields::SWAMPF,PBFields::WATERS,PBFields::UNDERWATER,PBFields::MURKWATERS].include?(@field.effect)
            if !i.pbTooHigh?(PBStats::DEFENSE)
              i.pbIncreaseStatBasic(PBStats::DEFENSE,2)
              pbCommonAnimation("StatUp",i,nil)
              pbDisplay(_INTL("{1}'s Water Compaction sharply raised its defense!", i.pbThis))
             end
           end
         end
        # Bad Dreams
        if (i.status==PBStatuses::SLEEP || i.ability == PBAbilities::COMATOSE) && i.ability != PBAbilities::MAGICGUARD && @field.effect != PBFields::RAINBOWF
          if i.pbOpposing1.hasWorkingAbility(:BADDREAMS) || i.pbOpposing2.hasWorkingAbility(:BADDREAMS)
            hploss=i.pbReduceHP((i.totalhp/8.0).floor,true)
            pbDisplay(_INTL("{1} is having a bad dream!",i.pbThis)) if hploss>0
          end
        end
        if i.isFainted?
          return if !i.pbFaint
          next
        end
        # Harvest
        if i.ability == PBAbilities::HARVEST && i.item<=0 && i.pokemon.itemRecycle>0 #if an item was recycled, check
          if pbIsBerry?(i.pokemon.itemRecycle) && (pbRandom(100)>50 ||
           (pbWeather==PBWeather::SUNNYDAY && !i.hasWorkingItem(:UTILITYUMBRELLA)) || (@field.effect == PBFields::FLOWERGARDENF && @field.counter>0))
            i.item=i.pokemon.itemRecycle
            i.pokemon.itemInitial=i.pokemon.itemRecycle
            i.pokemon.itemRecycle=0
            firstberryletter=PBItems.getName(i.item).split(//).first
            if firstberryletter=="A" || firstberryletter=="E" || firstberryletter=="I" ||
              firstberryletter=="O" || firstberryletter=="U"
                  pbDisplay(_INTL("{1} harvested an {2}!",i.pbThis,PBItems.getName(i.item)))
            else
              pbDisplay(_INTL("{1} harvested a {2}!",i.pbThis,PBItems.getName(i.item)))
            end
            i.pbBerryCureCheck(true)
          end
        end
        # Ball Fetch
        if i.ability == PBAbilities::BALLFETCH && i.effects[PBEffects::BallFetch]!=0 && i.item<=0
          pokeball=i.effects[PBEffects::BallFetch]
          i.item=pokeball
          i.pokemon.itemInitial=pokeball
          PBDebug.log("[Ability triggered] #{i.pbThis}'s Ball Fetch found #{PBItems.getName(pokeball)}")
          pbDisplay(_INTL("{1} fetched a {2}!",i.pbThis,PBItems.getName(pokeball)))
        end
        # Moody
        if i.ability == PBAbilities::CLOUDNINE && @field.effect == PBFields::RAINBOWF
          failsafe=0
          randoms=[]
          loop do
            failsafe+=1
            break if failsafe==1000
            randomnumber=1+pbRandom(7)
            if !i.pbTooHigh?(randomnumber)
              randoms.push(randomnumber)
              break
            end
          end
          if failsafe!=1000
           i.stages[randoms[0]]+=1
           i.stages[randoms[0]]=6 if i.stages[randoms[0]]>6
           pbCommonAnimation("StatUp",i,nil)
           pbDisplay(_INTL("{1}'s Cloud Nine raised its {2}!",i.pbThis,i.pbGetStatName(randoms[0])))
          end
        end
        if i.ability == PBAbilities::MOODY
          randomup=[]
          randomdown=[]
          failsafe1=0
          failsafe2=0
          loop do
            failsafe1+=1
            break if failsafe1==1000
            randomnumber=1+pbRandom(7)
            if !i.pbTooHigh?(randomnumber)
              randomup.push(randomnumber)
              break
            end
          end
          loop do
            failsafe2+=1
            break if failsafe2==1000
            randomnumber=1+pbRandom(7)
            if !i.pbTooLow?(randomnumber) && randomnumber!=randomup[0]
              randomdown.push(randomnumber)
              break
            end
          end
           if failsafe1!=1000
             i.stages[randomup[0]]+=2
             i.stages[randomup[0]]=6 if i.stages[randomup[0]]>6
             pbCommonAnimation("StatUp",i,nil)
             pbDisplay(_INTL("{1}'s Moody sharply raised its {2}!",i.pbThis,i.pbGetStatName(randomup[0])))
           end
           if failsafe2!=1000
             i.stages[randomdown[0]]-=1
             pbCommonAnimation("StatDown",i,nil)
             pbDisplay(_INTL("{1}'s Moody lowered its {2}!",i.pbThis,i.pbGetStatName(randomdown[0])))
           end
         end
        end
        for i in priority
          next if i.isFainted?
          next if !i.itemWorks?
          # Toxic Orb
          if i.item == PBItems::TOXICORB && i.status==0 && i.pbCanPoison?(false,true)
            i.status=PBStatuses::POISON
            i.statusCount=1
            i.effects[PBEffects::Toxic]=0
            pbCommonAnimation("Poison",i,nil)
            pbDisplay(_INTL("{1} was poisoned by its {2}!",i.pbThis,PBItems.getName(i.item)))
          end
          # Flame Orb
          if i.item == PBItems::FLAMEORB && i.status==0 && i.pbCanBurn?(false,true)
            i.status=PBStatuses::BURN
            i.statusCount=0
            pbCommonAnimation("Burn",i,nil)
            pbDisplay(_INTL("{1} was burned by its {2}!",i.pbThis,PBItems.getName(i.item)))
          end
          # Sticky Barb
          if i.item == PBItems::STICKYBARB && i.ability != PBAbilities::MAGICGUARD
            pbDisplay(_INTL("{1} is hurt by its {2}!",i.pbThis,PBItems.getName(i.item)))
            @scene.pbDamageAnimation(i,0)
            i.pbReduceHP((i.totalhp/8.0).floor)
          end
          if i.isFainted?
            return if !i.pbFaint
            next
          end
        end
        #Emergency exit caused by passive end of turn damage
        for i in priority
          if i.userSwitch == true
            i.userSwitch = false
            pbDisplay(_INTL("{1} went back to {2}!",i.pbThis,pbGetOwner(i.index).name))
            newpoke=0
            newpoke=pbSwitchInBetween(i.index,true,false)
            pbMessagesOnReplace(i.index,newpoke)
            i.vanished=false
            i.pbResetForm
            pbReplace(i.index,newpoke,false)
            pbOnActiveOne(i)
            i.pbAbilitiesOnSwitchIn(true)
          end
        end
        # Hunger Switch
        for i in priority
          next if i.isFainted?
          if i.ability == PBAbilities::HUNGERSWITCH && (i.species == PBSpecies::MORPEKO)
            i.form=(i.form==0) ? 1 : 0
            i.pbUpdate(true)
            scene.pbChangePokemon(i,i.pokemon)
            pbDisplay(_INTL("{1} transformed!",i.pbThis))
          end
        end
        # Form checks
        for i in 0...4
          next if @battlers[i].isFainted?
          @battlers[i].pbCheckForm
          @battlers[i].pbCheckFormRoundEnd
        end
        pbGainEXP
    
        # Checks if a pokemon on either side has fainted on this turn
        # for retaliate
        player   = priority[0]
        opponent = priority[1]
        if player.isFainted? || (@doublebattle && player.pbPartner.isFainted?)
          player.pbOwnSide.effects[PBEffects::Retaliate] = true
        else
          # No pokemon has fainted in this side this turn
          player.pbOwnSide.effects[PBEffects::Retaliate] = false
        end
    
        if opponent.isFainted? || (@doublebattle && opponent.pbPartner.isFainted?)
          opponent.pbOwnSide.effects[PBEffects::Retaliate] = true
        else
          opponent.pbOwnSide.effects[PBEffects::Retaliate] = false
        end
    
        pbSwitch
        pbSwitch
        return if @decision>0
        for i in priority
          next if i.isFainted?
          i.pbAbilitiesOnSwitchIn(false)
        end
        for i in 0...4
          if @battlers[i].turncount>0 && @battlers[i].ability == PBAbilities::TRUANT
            @battlers[i].effects[PBEffects::Truant]=!@battlers[i].effects[PBEffects::Truant]
          end
          if @battlers[i].effects[PBEffects::LockOn]>0   # Also Mind Reader
            @battlers[i].effects[PBEffects::LockOn]-=1
            @battlers[i].effects[PBEffects::LockOnPos]=-1 if @battlers[i].effects[PBEffects::LockOn]==0
          end
          @battlers[i].effects[PBEffects::Roost]=false
          @battlers[i].effects[PBEffects::Flinch]=false
          @battlers[i].effects[PBEffects::FollowMe]=false
          @battlers[i].effects[PBEffects::RagePowder]=false
          @battlers[i].effects[PBEffects::HelpingHand]=false
          @battlers[i].effects[PBEffects::MagicCoat]=false
          @battlers[i].effects[PBEffects::Snatch]=false
          @battlers[i].effects[PBEffects::Electrify]=false
          @battlers[i].effects[PBEffects::TarShot]=false
          @battlers[i].effects[PBEffects::Charge]-=1 if @battlers[i].effects[PBEffects::Charge]>0
          @battlers[i].lastHPLost=0
          @battlers[i].lastAttacker=-1
          @battlers[i].effects[PBEffects::Counter]=-1
          @battlers[i].effects[PBEffects::CounterTarget]=-1
          @battlers[i].effects[PBEffects::MirrorCoat]=-1
          @battlers[i].effects[PBEffects::MirrorCoatTarget]=-1
        end
        # invalidate stored priority
        @usepriority=false
      end
end