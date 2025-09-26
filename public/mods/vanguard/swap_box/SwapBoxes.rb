MenuHandlers.add(:pokemon_storage_box, :swap, {
  "name" => _INTL("Swap Boxes"),
  "order" => 70,
  "effect" => proc { |menu|
    idx = menu.storage.currentBox
    box1 = menu.storage[idx]
    commands = []
    menu.storage.boxes.each { |box| commands << box.name }
    chosenBox = menu.pbShowCommands(_INTL("Which box do you want to swap it with?"), commands)
    next if chosenBox < 0
    box2 = menu.storage[chosenBox]
    next unless box2
    (0...box1.length).each { |i| box1[i], box2[i] = box2[i], box1[i] }
    box1.name, box2.name = box2.name, box1.name
    box1.background, box2.background = box2.background, box1.background
    menu.scene.pbHardRefresh
  }
})