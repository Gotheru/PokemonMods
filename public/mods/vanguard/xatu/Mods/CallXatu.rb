class MenuXatu < MenuEntry
  def initialize
    @icon = "MenuXatu"
    @name = "Call Xatu"
  end

  def selected(menu)
    menu.pbHideMenu
    ret = nil
    pbFadeOutIn(99999) {
      scene  = PokemonRegionMap_Scene.new(-1, false)
      screen = PokemonRegionMapScreen.new(scene)
      ret    = screen.pbStartFlyScreen     # ret = [name, map_id, x, y, dir] or nil
    }
    if ret
      xatu = pbGenerateWildPokemon(:XATU, 50)
      pbHiddenMoveAnimation(xatu)
      pbFadeOutIn {
        $game_temp.player_new_map_id    = ret[1]
        $game_temp.player_new_x         = ret[2]
        $game_temp.player_new_y         = ret[3]
        $game_temp.player_new_direction = ret[4]
        $scene.transfer_player
      }
      return true
    end
    menu.pbShowMenu
  end


  def selectable?
    return false if !$game_player.can_map_transfer_with_follower?
    $game_switches[481]
  end
end

MENU_ENTRIES = MENU_ENTRIES << "MenuXatu"


# There is a bug in the original code if you take one of the options away from the player. This should fix the bug
class VolsteonsPauseMenu < Component
  def refreshMenu
    calculateDisplayIndex
    middle = @displayIndexes.length/2
    for i in 0...@displayIndexes.length
      if !@entries[@displayIndexes[i]]
        return refreshMenu # Just try again until it updates completely?
      end
      @sprites["icon#{i}"].setBitmap(@entries[@displayIndexes[i]].icon)
      @sprites["icon#{i}"].zoom_x = 1
      @sprites["icon#{i}"].zoom_y = 1
    end
    @sprites["icon#{middle}"].zoom_x = ACTIVE_SCALE
    @sprites["icon#{middle}"].zoom_y = ACTIVE_SCALE
    if @entries.length <= 8
      b2 = @entries[@entryIndexes[0]].icon
      b1 = ((@entries.length%2==0)? @entries[@entryIndexes[0]] : @entries[@entryIndexes[@displayIndexes.length - 1]]).icon
    else
      offset = (@entryIndexes.length - 7)/2
      of2 = (@entryIndexes.length%2 - 1).abs
      b1 = @entries[@entryIndexes[offset - 1 + of2]].icon
      b2 = @entries[@entryIndexes[@entryIndexes.length - offset]].icon
    end
    @sprites["dummyiconL"].setBitmap(b1)
    @sprites["dummyiconR"].setBitmap(b2)
    return if !SHOW_MENU_NAMES
    @sprites["entrytext"].bitmap.clear
    text = @entries[@currentSelection].name
    pbSetSystemFont(@sprites["entrytext"].bitmap)
    baseColor = MENU_TEXTCOLOR[$PokemonSystem.current_menu_theme].is_a?(Color) ? MENU_TEXTCOLOR[$PokemonSystem.current_menu_theme] : Color.new(248,248,248)
    shadowColor = MENU_TEXTOUTLINE[$PokemonSystem.current_menu_theme].is_a?(Color) ? MENU_TEXTOUTLINE[$PokemonSystem.current_menu_theme] : Color.new(48,48,48)
    pbDrawTextPositions(@sprites["entrytext"].bitmap,[[text,128,12,2,baseColor,shadowColor]])
  end
end

# Implement actualy Fly (not implemented in the base game)

class PokemonRegionMap_Scene
  def pbMapScene
    x_offset = 0
    y_offset = 0
    new_x    = 0
    new_y    = 0
    dist_per_frame = 8 * 20 / Graphics.frame_rate
    loop do
      Graphics.update
      Input.update
      pbUpdate
      if x_offset != 0 || y_offset != 0
        x_offset += (x_offset > 0) ? -dist_per_frame : (x_offset < 0) ? dist_per_frame : 0
        y_offset += (y_offset > 0) ? -dist_per_frame : (y_offset < 0) ? dist_per_frame : 0
        @sprites["cursor"].x = new_x - x_offset
        @sprites["cursor"].y = new_y - y_offset
        next
      end

      ox = 0
      oy = 0
      case Input.dir8
      when 1, 2, 3
        oy = 1 if @map_y < BOTTOM
      when 7, 8, 9
        oy = -1 if @map_y > TOP
      end
      case Input.dir8
      when 1, 4, 7
        ox = -1 if @map_x > LEFT
      when 3, 6, 9
        ox = 1 if @map_x < RIGHT
      end

      if ox != 0 || oy != 0
        @map_x += ox
        @map_y += oy
        x_offset = ox * SQUARE_WIDTH
        y_offset = oy * SQUARE_HEIGHT
        new_x = @sprites["cursor"].x + x_offset
        new_y = @sprites["cursor"].y + y_offset
      end

      @sprites["mapbottom"].maplocation = pbGetMapLocation(@map_x, @map_y)
      @sprites["mapbottom"].mapdetails  = pbGetMapDetails(@map_x, @map_y)

      if Input.trigger?(Input::BACK)
        if @editor && @changed
          pbSaveMapData if pbConfirmMessage(_INTL("Save changes?")) { pbUpdate }
          break if pbConfirmMessage(_INTL("Exit from the map?")) { pbUpdate }
        else
          break
        end
      elsif Input.trigger?(Input::USE) && @mode == 1
        healspot = pbGetFlyingSpot(@map_x, @map_y)
        if healspot
          name = healspot[0]
          if pbConfirmMessage(_INTL("Would you like to teleport to {1}?", name)) { pbUpdate }
            return healspot
          end
        end
      elsif Input.trigger?(Input::USE) && @editor
        pbChangeMapLocation(@map_x, @map_y)
      elsif Input.trigger?(Input::ACTION) && !@wallmap && !@fly_map && pbCanFly?
        pbPlayDecisionSE
        @mode = (@mode == 1) ? 0 : 1
        refresh_fly_screen
      end
    end
    pbPlayCloseMenuSE
    nil
  end

  def pbGetFlyingSpot(x, y)
    return nil unless @map[2]
    @map[2].each do |p|
      next unless p[0] == x && p[1] == y
      next unless p[2]

      case p[2].to_s
      when "Oceia"             then return [p[2].to_s, 200, 14, 35, 2] if $game_switches[484]
      when "Vanguard Academy"  then return [p[2].to_s,  58, 28, 24, 2] if $game_switches[481]
      when "Souten Farm"       then return [p[2].to_s,  62, 26, 11, 2] if $game_switches[482]
      when "Souten"            then return [p[2].to_s,  67, 58, 14, 2] if $game_switches[483]
      when "Qyilex"            then return [p[2].to_s,   6,  9, 36, 2] if $game_switches[485]
      when "Arlen"             then return [p[2].to_s, 201, 12, 54, 2] if $game_switches[486]
      when "Avaros"            then return [p[2].to_s, 183,  6,  9, 2] if $game_switches[488]
      when "Runaans Port"      then return [p[2].to_s,  94, 42, 54, 2] if $game_variables[91] >= 13
      when "Koriko"            then return [p[2].to_s, 111, 62, 59, 2] if $game_switches[490]
      when "Rivera"            then return [p[2].to_s, 139,  7, 18, 2] if $game_switches[491]
      when "Citrine"           then return [p[2].to_s, 157, 28,  8, 2] if $game_switches[492]
      when "Eastcliff"         then return [p[2].to_s,  39, 24, 13, 2] if $game_switches[493]
      when "Kirba"             then return [p[2].to_s, 173, 13, 42, 2] if $game_switches[494]
      when "Auburn Woodlands"  then return [p[2].to_s, 231, 26, 20, 2] if $game_variables[140] >= 2
      when "West Lavendam"     then return [p[2].to_s, 263,  9,  8, 2] if $game_switches[217]
      when "East Lavendam"     then return [p[2].to_s, 276, 38, 26, 2] if $game_switches[218]
      when "Kaedara"           then return [p[2].to_s, 250, 23, 30, 2] if $game_switches[219]
      when "Winterveil"        then return [p[2].to_s, 262,  9, 24, 2] if $game_switches[220]
      else
        return nil
      end
    end
    nil
  end
end
