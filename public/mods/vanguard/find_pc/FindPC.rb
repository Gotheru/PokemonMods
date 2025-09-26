class PokemonStorageScreen

  def pbFindPokemon # Based on LAWDS code
    isNickname = Kernel.pbMessage(
      _INTL("What do you want to find?"),
      [_INTL("Name"), _INTL("Species"), _INTL("Item")],
      0
    )

    if isNickname == 0
      findEggs = 1
      search = Kernel.pbEnterPokemonName(_INTL("Nickname of the Pokemon?"), 0, 15, "")
    elsif isNickname == 1
      findEggs = Kernel.pbMessage(
        _INTL("Include eggs in the search?"),
        [_INTL("Yes"), _INTL("No eggs"), _INTL("Eggs only")],
        0,
      )
      search = Kernel.pbEnterPokemonName(_INTL("Name of the species?"), 0, 15, "")
    else
      findEggs = 1
      search = Kernel.pbEnterPokemonName(_INTL("Item name?"), 0, 15, "")
    end

    query = search.downcase

    foundArr = ["Done"]
    foundBoxes = [0]
    foundCount = [0]
    
    for i in 0...$PokemonStorage.maxBoxes
      found = false
      for j in 0...$PokemonStorage[i].length
        mon = $PokemonStorage[i, j]
        if mon
          if findEggs == 1
            next if mon.egg?
          elsif findEggs == 2
            next if mon.egg?
          end

          if isNickname == 0
            name = mon.name
          elsif isNickname == 1
            name = mon.species.to_s
          elsif !mon.item_id
            next
          else
            name = mon.item_id.to_s
          end

          if query == name.downcase
            if found
              foundCount[foundCount.length - 1] += 1
            else
              foundArr.push($PokemonStorage[i].name)
              foundBoxes.push(i)
              foundCount.push(1)
              found = true
            end
          end
        end
      end
    end
    
    if foundArr.length > 1
      box = foundBoxes[1]
      Kernel.pbMessage(_INTL("'{1}' was found in {2}", query, foundArr[1]))
      @scene.pbJumpToBox(box)
    else
      if query == ""
        Kernel.pbMessage(_INTL("Sorry, didn't find anything."))
      else
        Kernel.pbMessage(_INTL("Sorry, '{1}' was not found.", query))
      end
    end
  end

end


MenuHandlers.add(:pokemon_storage_box, :find, {
  "name" => _INTL("Find Pokémon"),
  "order" => 50,
  "effect" => proc { |menu| menu.pbFindPokemon }
})
