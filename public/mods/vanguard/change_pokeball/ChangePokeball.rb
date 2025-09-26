MenuHandlers.add(:party_menu, :pokeball, {
  "name" => _INTL("PokéBall"),
  "order" => 70,
  "condition" => proc { |screen, party, party_idx| next !party[party_idx].egg? },
  "effect" => proc { |screen, party, party_idx|
    command_list = []
    balls = []
    GameData::Item.each do |i|
      item = GameData::Item.get(i)
      next unless item.is_poke_ball?
      command_list.push(item.name)
      balls.push(item)
    end
    command_list.sort!
    balls.sort_by! { |b| b.name }
    command_list.push(_INTL("Cancel"))
    # Choose a menu option
    choice = screen.scene.pbShowCommands(_INTL("What type of PokéBall do you want to use?"), command_list)
    next if choice < 0 || choice >= balls.length
    party[party_idx].poke_ball = balls[choice].id
  }
})