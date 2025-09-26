MenuHandlers.add(:pokemon_storage_box, :release, {
  "name" => _INTL("Release All"),
  "order" => 60,
  "effect" => proc { |menu|
    idx = menu.storage.currentBox
    box = menu.storage[idx]
    if pbConfirmMessage(_INTL("Do you want to release all the Pokémon in this box?"))
      (0...box.length).each { |i| box[i] = nil }
    end
    menu.scene.pbHardRefresh
  }
})