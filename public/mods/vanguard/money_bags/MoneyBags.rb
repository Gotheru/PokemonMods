module MoneyBags
  def pbGainMoney
    old_money = pbPlayer.money
    super
    cur_money = pbPlayer.money
    money_gains = cur_money - old_money
    money_gains *= 4
    pbPlayer.money += money_gains
    pbDisplayPaused(_INTL("You got an extra ${1}! ez money heh...", money_gains.to_s_formatted)) if money_gains > 0
  end
end

Battle.prepend(MoneyBags)