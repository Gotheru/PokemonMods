module MagneticLure
  def pbFilterKnownPkmnFromEncounter(encounters)
    return nil if !encounters || encounters.empty?

    # keep entries with positive weight and uncaptured species
    uncaptured = encounters.select do |enc|
      next false unless enc && enc[0].to_i > 0
      species = enc[1]
      !$Trainer.pokedex.owned?(species)
    end
    return nil if uncaptured.empty?

    # weighted pick by chance (enc[0])
    total = uncaptured.sum { |enc| enc[0].to_i }
    r = rand(total)
    uncaptured.each do |enc|
      r -= enc[0].to_i
      return enc if r < 0
    end
    uncaptured.sample   # fallback (shouldn’t hit)
  end

  def pbShouldFilterKnownPkmnFromEncounter?
    lead = $Trainer&.first_pokemon
    lead && !lead.egg? && lead.item_id == :MAGNET
  end

  def pbGetEncounterLevel(encounter)
    lb = encounter[2]
    ub = encounter[3]
    lead = $Trainer&.first_pokemon
    if lead && !lead.egg? && [:PRESSURE, :HUSTLE, :VITAL_SPIRIT].include?(lead.ability_id)
      lb += (ub - lb) / 2
    end
    lb + rand(1 + ub - lb)
  end

  def choose_wild_pokemon(enc_type, chance_rolls = 1)
    return super unless pbShouldFilterKnownPkmnFromEncounter?

    unless enc_type && GameData::EncounterType.exists?(enc_type)
      raise ArgumentError, _INTL("Encounter type {1} does not exist", enc_type)
    end

    encounters = @encounter_tables[enc_type]
    enc = pbFilterKnownPkmnFromEncounter(encounters)
    return super unless enc

    [enc[1], pbGetEncounterLevel(enc)]
  end
end

PokemonEncounters.prepend(MagneticLure)
