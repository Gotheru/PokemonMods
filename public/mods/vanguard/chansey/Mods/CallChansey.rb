#-------------------------------------------------------------------------------
# Gotheru's Healing Mod
#-------------------------------------------------------------------------------
class MenuHealParty < MenuEntry
  def initialize
    @icon = "menuHealParty"
    @name = "Call Chansey"
  end

  def selected(menu)
    menu.pbHideMenu
    for i in $Trainer.party
      i.heal
    end
    pbMEPlay("Pkmn healing")
    pbMessage(_INTL("Chansey healed your Pokémon!"))
    menu.pbShowMenu
  end

  def selectable?; return ($Trainer.party_count > 0); end
end

MENU_ENTRIES = MENU_ENTRIES << "MenuHealParty"