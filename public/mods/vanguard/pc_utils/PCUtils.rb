class PokemonStorageScreen
  def pbBoxCommands
    commands = []
    commandNames = []
    MenuHandlers.each_available(:pokemon_storage_box) do |option, hash, name|
      commands << hash
      commandNames << name
    end
    commandNames << "Cancel"
    command = pbShowCommands(_INTL("What do you want to do?"), commandNames)
    return unless 0 <= command && command < commands.length
    commands[command]["effect"].call(self)
  end
end

MenuHandlers.add(:pokemon_storage_box, :jump, {
  "name" => _INTL("Jump"),
  "order" => 10,
  "effect" => proc { |menu|
    destBox = menu.scene.pbChooseBox(_INTL("Jump to which Box?"))
    menu.scene.pbJumpToBox(destBox) if destBox >= 0
  }
})

MenuHandlers.add(:pokemon_storage_box, :wallpaper, {
  "name" => _INTL("Wallpaper"),
  "order" => 20,
  "effect" => proc { |menu|
    papers = menu.storage.availableWallpapers
    index = 0
    papers[1].length.times do |i|
      if papers[1][i] == menu.storage[menu.storage.currentBox].background
        index = i
        break
      end
    end
    wpaper = menu.pbShowCommands(_INTL("Pick the wallpaper."), papers[0], index)
    menu.scene.pbChangeBackground(papers[1][wpaper]) if wpaper >= 0
  }
})

MenuHandlers.add(:pokemon_storage_box, :name, {
  "name" => _INTL("Name"),
  "order" => 30,
  "effect" => proc { |menu| menu.scene.pbBoxName(_INTL("Box name?"), 0, 12) }
})