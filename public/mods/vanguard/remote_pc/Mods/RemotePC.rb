#-------------------------------------------------------------------------------
# Gotheru's Remote PC Mod
#-------------------------------------------------------------------------------
class MenuRemotePC < MenuEntry
  def initialize
    @icon = "menuPC"
    @name = "Remote PC"
  end

  def selected(menu)
    menu.pbHideMenu()
    pbPokeCenterPC()
    menu.pbShowMenu()
  end

  def selectable?; return true; end # todo fix this
end

MENU_ENTRIES = MENU_ENTRIES << "MenuRemotePC"