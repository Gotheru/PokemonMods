MenuHandlers.add(:party_menu, :hidden_power, {
  "name" => _INTL("Hidden Power"),
  "order" => 80,
  "condition" => proc { |screen, party, party_idx| !party[party_idx].egg? },
  "effect" => proc { |screen, party, party_idx|
    types = []
    GameData::Type.each { |type| types << type if !type.pseudo_type && ![:NORMAL, :SHADOW, :TYPELESS].include?(type.id) }
    commands = types.map { |type| type.name }
    commands << "Cancel"
    choice = screen.scene.pbShowCommands(_INTL("What type do you want {1}'s Hidden Power to be?", party[party_idx].name), commands)
    next if choice < 0 || choice >= types.length
    party[party_idx].hptype = types[choice].id
  }
})