def build_national_dex!
  return if defined?($NATIONAL_DEX_BUILT) && $NATIONAL_DEX_BUILT
  $NATIONAL_DEX = Hash.new(0)
  GameData::Species.each_species { |s| $NATIONAL_DEX[s.species] = $NATIONAL_DEX.size + 1 }
  $NATIONAL_DEX_BUILT = true
end

class Pokemon
  def dexNumber;
    build_national_dex!
    $NATIONAL_DEX[@species]
  end

  def statByIdx(idx)
    case idx
    when 0; @totalhp
    when 1; @attack
    when 2; @defense
    when 3; @spatk
    when 4; @spdef
    else;   @speed
    end
  end

  def baseStatByIdx(idx)
    sp = GameData::Species.get_species_form(@species, @form || 0)
    base = sp.base_stats
    case idx
    when 0; base[:HP]
    when 1; base[:ATTACK]
    when 2; base[:DEFENSE]
    when 3; base[:SPECIAL_ATTACK]
    when 4; base[:SPECIAL_DEFENSE]
    when 5; base[:SPEED]
    end
  end
end

class PokemonStorageScreen
  def pbSortPokemonInPc
    commands = ["Species", "Type", "Name", "Stat", "Base Stat", "Cancel"]
    sortType = Kernel.pbMessage("How do you want to sort? (only sorts the first 39 boxes)", commands, commands.length)

    if sortType == commands.length - 1 || sortType == -1
      return
    end

    boxesToSort = 39 # only sort first 39 boxes
    pokemonsToSort = []
    eggs = []
    for iBox in 0...boxesToSort
      for i in 0...$PokemonStorage[iBox].length
        poke = $PokemonStorage[iBox, i]
        if poke
          if poke.egg?
            eggs.push(poke)
          else
            pokemonsToSort.push(poke)
          end
        end
      end
    end
    
    build_national_dex!
    case sortType
    when 0  # species, then name
      pokemonsToSort.sort_by! { |p| [p.dexNumber, p.name] }
    when 1  # type1, type2, species, name
      pokemonsToSort.sort_by! { |p| [p.type1, p.type2, p.dexNumber, p.name] }
    when 2    # name, then species
      pokemonsToSort.sort_by! { |p| [p.name, p.dexNumber] }
    else
      stats = [_INTL("HP"), _INTL("Attack"), _INTL("Defense"), _INTL("Sp. Attack"), _INTL("Sp. Defense"), _INTL("Speed")]
      chosenStat = Kernel.pbMessage(_INTL("Choose the stat you want to sort by"), stats, 0) # 0 so there is no Cancel option
      # Sort by descending stat number, then species
      pokemonsToSort.sort_by! { |p| [-p.statByIdx(chosenStat), p.dexNumber] } if sortType == 3
      pokemonsToSort.sort_by! { |p| [-p.baseStatByIdx(chosenStat), p.dexNumber] } if sortType == 4
    end

    # always sort eggs by species
    eggs.sort!{|poke1, poke2| poke1.dexNumber <=> poke2.dexNumber}

    # always put eggs after pokemons
    sortedList = pokemonsToSort + eggs

    # put in boxes
    pokemonIterator = 0
    for iBox in 0...boxesToSort
      for i in 0...$PokemonStorage[iBox].length
        if pokemonIterator > sortedList.length
          $PokemonStorage[iBox, i] = nil
        else
          $PokemonStorage[iBox, i] = sortedList[pokemonIterator]
          pokemonIterator += 1
        end
      end
    end
    
    Kernel.pbMessage(_INTL("Finished sorting boxes."))
    @scene.pbHardRefresh
  end
end

MenuHandlers.add(:pokemon_storage_box, :sort, {
  "name" => _INTL("Sort Boxes"),
  "order" => 40,
  "effect" => proc { |menu| menu.pbSortPokemonInPc }
})
