module AutoPickupBattle # Actually works for anything that steals items.
  attr_accessor :preBattleItems

  def pbStartBattleCore
    @preBattleItems = []
    @initialItems[0].each { |i| @preBattleItems.push(i) }
    super
  end

  def pbEndOfBattle
    @preBattleItems.each_with_index do |item, i|
      next unless item != @initialItems[0][i] && @initialItems[0][i]
      pbDisplayPaused(_INTL("{1} found an item and deposited it in your bag!", @party1[i].name))
      pbReceiveItem(@initialItems[0][i])
      @initialItems[0][i] = nil
    end
    super
  end
end

Battle.prepend(AutoPickupBattle)


module AutoPickup
  def pbPickup(pkmn)
    hadItem = pkmn.hasItem?
    super
    if !hadItem && pkmn.hasItem?
      pbMessage(_INTL("{1} picked up an item and deposited it in your bag!", pkmn.name))
      pbReceiveItem(pkmn.item)
      pkmn.item = nil
    end
  end

  def pbHoneyGather(pkmn)
    hadItem = pkmn.hasItem?
    super
    if !hadItem && pkmn.hasItem?
      pbMessage(_INTL("{1} picked up some {2} and deposited it in your bag!", pkmn.name, pkmn.item.name))
      pbReceiveItem(pkmn.item)
      pkmn.item = nil
    end
  end
end

Object.prepend(AutoPickup) unless Object < AutoPickup