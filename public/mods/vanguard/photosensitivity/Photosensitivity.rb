def pbBattleAnimationCore(anim, viewport, location, num_flashes = 0)
  # Removes handling flashes :)
  # Take screenshot of game, for use in some animations
  $game_temp.background_bitmap&.dispose
  $game_temp.background_bitmap = Graphics.snap_to_bitmap
  # Play main animation
  Graphics.freeze
  viewport.color = Color.new(0, 0, 0, 255)   # Ensure screen is black
  Graphics.transition(25, "Graphics/Transitions/" + anim)
  # Slight pause after animation before starting up the battle scene
  pbWait(Graphics.frame_rate / 10)
end