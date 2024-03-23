local bxhnz7tp5bge7wvu = bxhnz7tp5bge7wvu_interface
local SB = xgtuznwgpm8uxfhf

local function is_tanking()
  local isTanking = UnitDetailedThreatSituation("player", "target")
  return isTanking
end

local function haste_mod()
  local haste = UnitSpellHaste("player")
  return 1 + haste / 100
end

local function gcd_duration()
  return 1.5 / haste_mod()
end

local function gcd()
end

local function combat()
  if not player.alive then return end
  
  local cosmic_healing_potion = bxhnz7tp5bge7wvu.settings.fetch('gu_nikopol_cosmic_healing_potion', false)
  
  if GetCVar("nameplateShowEnemies") == '0' then
    SetCVar("nameplateShowEnemies", 1)
  end
  
  macro('/cqs')
  
  if player.buff(SB.BearForm).down then return end
  if player.channeling(SB.ConvoketheSpirits) then return end
  
  if castable(SB.FrenziedRegeneration) and player.health.effective < 60 then
    return cast(SB.FrenziedRegeneration)
  end
  
  if GetItemCooldown(5512) == 0 and player.health.effective < 30 then
    macro('/use Healthstone')
  end
  
  if cosmic_healing_potion and GetItemCooldown(187802) == 0 and player.health.effective < 10 then
    macro('/use Cosmic Healing Potion')
  end
  
  if toggle('auto_target', false) then
    local nearest_target = enemies.match(function (unit)
      return unit.alive and unit.combat and unit.distance <= 5
    end)
    
    if (not target.exists or target.distance > 5) and nearest_target and nearest_target.name then
      macro('/target ' .. nearest_target.name)
    end
  end
  
  local enemies_around_5 = enemies.around(5)
  
  if target.enemy and target.alive and target.distance <= 5 then
    auto_attack()
        
    if toggle('interrupts', false) and target.interrupt(70) then
      if spell(SB.SkullBash).cooldown == 0 then
        return cast(SB.SkullBash, target)
      end
    end
        
    if toggle('cooldowns', false) then
    end
  
    if castable(SB.Mangle) then
      return cast(SB.Mangle, 'target')
    end
    
    if castable(SB.Mangle) then
      return cast(SB.Mangle, 'target')
    end
    
    if castable(SB.ThrashBear) then
      return cast(SB.ThrashBear)
    end
    
    if castable(SB.Moonfire) and target.debuff(SB.MoonfireDebuff).remains < gcd_duration() then
      return cast(SB.Moonfire, 'target')
    end
    
    if is_tanking() then
      if castable(SB.Ironfur) then
        cast(SB.Ironfur)
      end
    else
      if castable(SB.Maul) then
        return cast(SB.Maul, 'target')
      end
    end
    
    if castable(SB.SwipeBear) then
      return cast(SB.SwipeBear)
    end
  end
end

local function resting()
  if not player.alive then return end

end

function interface()
    local gu_gui = {
    key = 'gu_nikopol',
    title = 'Guardian',
    width = 250,
    height = 320,
    resize = true,
    show = false,
    template = {
      { type = 'header', text = 'Guardian Settings' },
      { type = 'rule' },   
      { type = 'text', text = 'Healing Settings' },
      { key = 'cosmic_healing_potion', type = 'checkbox', text = 'Cosmic Healing Potion', desc = 'Use Cosmic Healing Potion when below 10% health', default = false },
    }
  }

  configWindow = bxhnz7tp5bge7wvu.interface.builder.buildGUI(gu_gui)
  
  bxhnz7tp5bge7wvu.interface.buttons.add_toggle({
    name = 'dispell',
    label = 'Auto Dispell',
    on = {
      label = 'DSP',
      color = bxhnz7tp5bge7wvu.interface.color.green,
      color2 = bxhnz7tp5bge7wvu.interface.color.green
    },
    off = {
      label = 'dsp',
      color = bxhnz7tp5bge7wvu.interface.color.grey,
      color2 = bxhnz7tp5bge7wvu.interface.color.dark_grey
    }
  })
  bxhnz7tp5bge7wvu.interface.buttons.add_toggle({
    name = 'auto_target',
    label = 'Auto Target',
    on = {
      label = 'AT',
      color = bxhnz7tp5bge7wvu.interface.color.green,
      color2 = bxhnz7tp5bge7wvu.interface.color.green
    },
    off = {
      label = 'at',
      color = bxhnz7tp5bge7wvu.interface.color.grey,
      color2 = bxhnz7tp5bge7wvu.interface.color.dark_grey
    }
  })
  bxhnz7tp5bge7wvu.interface.buttons.add_toggle({
    name = 'settings',
    label = 'Rotation Settings',
    font = 'bxhnz7tp5bge7wvu_icon',
    on = {
      label = bxhnz7tp5bge7wvu.interface.icon('cog'),
      color = bxhnz7tp5bge7wvu.interface.color.cyan,
      color2 = bxhnz7tp5bge7wvu.interface.color.dark_cyan
    },
    off = {
      label = bxhnz7tp5bge7wvu.interface.icon('cog'),
      color = bxhnz7tp5bge7wvu.interface.color.grey,
      color2 = bxhnz7tp5bge7wvu.interface.color.dark_grey
    },
    callback = function(self)
      if configWindow.parent:IsShown() then
        configWindow.parent:Hide()
      else
        configWindow.parent:Show()
      end
    end
  })
end

bxhnz7tp5bge7wvu.rotation.register({
  spec = bxhnz7tp5bge7wvu.rotation.classes.druid.guardian,
  name = 'gu_nikopol',
  label = 'Guardian by Nikopol',
  gcd = gcd,
  combat = combat,
  resting = resting,
  interface = interface
})
