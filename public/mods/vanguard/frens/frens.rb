MenuHandlers.add(:party_menu, :happiness, {
  "name" => _INTL("Set Happiness"),
  "order" => 90,
  "condition" => proc { |screen, party, party_idx| !party[party_idx].egg? },
  "effect" => proc { |screen, party, party_idx|
    mon = party[party_idx]
    params = ChooseNumberParams.new
    params.setRange(0, 255)
    params.setDefaultValue(mon.happiness)
    h = pbMessageChooseNumber(
      _INTL("Set the Pokémon's happiness (max. 255)."), params
    ) { screen.pbUpdate }
    mon.happiness = h
    screen.pbRefreshSingle(party_idx)
    next false
  }
})