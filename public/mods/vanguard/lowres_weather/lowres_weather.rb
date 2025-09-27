module LowResWeather
  LOWRES = true
  def initialize(*args); return if LOWRES; super(args); end
  def dispose(*args); return if LOWRES; super(args); end
  def fade_in(*args); return if LOWRES; super(args); end
  def type=(*args); return if LOWRES; super(args); end
  def max=(*args); return if LOWRES; super(args); end
  def ox=(*args); return if LOWRES; super(args); end
  def oy=(*args); return if LOWRES; super(args); end
  def get_weather_tone(*args); return if LOWRES; super(args); end
  def prepare_bitmaps(*args); return if LOWRES; super(args); end
  def ensureSprites(*args); return if LOWRES; super(args); end
  def ensureTiles(*args); return if LOWRES; super(args); end
  def set_sprite_bitmaps(*args); return if LOWRES; super(args); end
  def set_tile_bitmap(*args); return if LOWRES; super(args); end
  def reset_sprite_position(*args); return if LOWRES; super(args); end
  def update_sprite_position(*args); return if LOWRES; super(args); end
  def recalculate_tile_positions(*args); return if LOWRES; super(args); end
  def update_tile_position(*args); return if LOWRES; super(args); end
  def update_screen_tone(*args); return if LOWRES; super(args); end
  def update_fading(*args); return if LOWRES; super(args); end
  def update(*args); return if LOWRES; super(args); end
end

RPG::Weather.prepend(LowResWeather)
