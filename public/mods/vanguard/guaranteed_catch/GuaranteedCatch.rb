module GottaCatchThemAll 
  def pbStartBattle
    if @initialized_balls.nil?
      @initialized_balls = true
      GameData::Item.each do |item|
        next unless item.is_poke_ball?
        Battle::PokeBallEffects::IsUnconditional.add(item.id, proc { |ball, battle, battler| next true })
      end
    end
    super
  end
end

Battle.prepend(GottaCatchThemAll)