# based on daycare pc mod from reborn server

def ring_daycare
  unless getCompletedQuests.include?(:Quest33) && $PokemonGlobal.day_care
    pbMessage(_INTL("You can't use that yet!"))
  end
  pbMessage(_INTL("\\se[PC open]Hi, sweetie! Do you want me to take care of your Pokémon?"))
  command_list = []
  commands = []
  MenuHandlers.each_available(:daycare_menu) do |option, hash, name|
    command_list.push(name)
    commands.push(hash)
  end
  command = 0
  loop do
    choice = pbMessage(_INTL("What do you want to do?"), command_list, -1, nil, command)
    break if choice < 0
    commands[choice]["effect"].call == "break"
  end
  pbPlayCloseMenuSE
end

MenuHandlers.add(:pc_menu, :daycare, {
  "name" => _INTL("Ring the Daycare"),
  "condition" => proc { next getCompletedQuests.include?(:Quest33) && $PokemonGlobal.day_care },
  "order" => 90,
  "effect" => proc { |menu| ring_daycare }
})

ItemHandlers::UseInField.add(:COINCASE, proc { |item|
  ring_daycare
  next true
})

MenuHandlers.add(:daycare_menu, :summary, {
  "name" => _INTL("Summary"),
  "order" => 0,
  "effect" => proc do |menu|
    day_care = $PokemonGlobal.day_care
    slots = day_care.slots
    num = day_care.count
    pbMessage(_INTL("We got {1} Pokémon in the Day Care right now.", num))
    slots.each do |slot|
      next unless slot.filled?
      mon = slot.pokemon
      initial_level = mon.level
      gender = [_INTL("♂"),_INTL("♀"),_INTL("genderless")][mon.gender]
      pbMessage(_INTL("{1} ({2}), Lv. {3}", mon.name, gender, initial_level))
    end
    if DayCare.egg_generated?
      pbMessage(_INTL("Ah, we got an egg here!"))
    elsif day_care.count == 2
      compat = day_care.compatibility
      pbMessage(compat == 0 ?
                  _INTL("They don't seem to like each other much.") :
                  _INTL("They seem pretty friendly with each other!"))
    end
  end
})

MenuHandlers.add(:daycare_menu, :deposit, {
  "name" => _INTL("Deposit Pokémon"),
  "order" => 1,
  "effect" => proc do |menu|
    if DayCare.egg_generated?
      pbMessage(_INTL("You should pick up this egg first!"))
    elsif DayCare.count == DayCare::MAX_SLOTS
      pbMessage(_INTL("You already have {1} Pokémon over here!", DayCare::MAX_SLOTS))
    elsif $player.party.length <= 1
      pbMessage(_INTL("That's the last Pokémon in your party!"))
    else
      pbChooseNonEggPokemon(1,3)
      next unless pbGet(1) >= 0
      DayCare.deposit(pbGet(1))
      pbMessage(_INTL("We'll take care of {1}.", pbGet(3)))
    end
  end
})

MenuHandlers.add(:daycare_menu, :withdraw, {
  "name" => _INTL("Withdraw Pokémon"),
  "order" => 2,
  "effect" => proc do |menu|
    if DayCare.egg_generated?
      pbMessage(_INTL("You should pick up this egg first!"))
    elsif DayCare.count == 0
      pbMessage(_INTL("There is no Pokémon here to withdraw!"))
    elsif $player.party_full?
      pbMessage(_INTL("You have a full party! You should deposit one of your Pokémon first."))
    else
      DayCare.choose(_INTL("Which one do you want back?"), 1)
      next unless pbGet(1) >= 0
      DayCare.get_details(pbGet(1), 3, 4)
      DayCare.withdraw(pbGet(1))
      pbMessage(_INTL("Alright, I'll give you {1} back.", pbGet(3)))
    end
  end
})

MenuHandlers.add(:daycare_menu, :wait_for_egg, {
  "name" => _INTL("Wait for Egg"),
  "order" => 3,
  "effect" => proc do |menu|
    if DayCare.egg_generated?
      pbMessage(_INTL("There's an egg here, I don't think another egg will show up..."))
    elsif DayCare.count < 2
      pbMessage(_INTL("There aren't two Pokémon in the Day Care. I don't think an egg will show up..."))
    elsif $PokemonGlobal.day_care.get_compatibility == 0
      pbMessage(_INTL("The Pokémon don't seem to like each other much..."))
    else
      $PokemonGlobal.day_care.egg_generated = true
      pbMessage(_INTL("Ah, it looks like an egg showed up!"))
    end
  end
})

MenuHandlers.add(:daycare_menu, :collect_egg, {
  "name" => _INTL("Collect Egg"),
  "order" => 4,
  "effect" => proc do |menu|
    if !DayCare.egg_generated?
      pbMessage(_INTL("We don't see an egg here... Maybe it'll turn up soon!"))
    else
      DayCare.collect_egg
      pbMessage(_INTL("Here's the egg!"))
    end
  end
})

MenuHandlers.add(:daycare_menu, :hatch_eggs, {
  "name" => _INTL("Hatch Eggs"),
  "order" => 4,
  "effect" => proc do |menu|
    $player.party.each do |mon|
      mon.steps_to_hatch = 1 if mon.egg?
    end
    pbMessage(_INTL("Any eggs in your party were sped up to hatch!"))
  end
})

MenuHandlers.add(:daycare_menu, :cancel, {
  "name" => _INTL("Never Mind"),
  "order" => 100,
  "effect" => proc { |menu| next "break" }
})