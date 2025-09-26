module ShinyGummies
  def pbFilterOutOtherPkmnFromEncounter(encounters)
    return nil if !encounters || encounters.empty?
    
    lead = $Trainer&.first_pokemon
    return nil if !lead

    species = GameData::Species.get(lead.species)
    family = species.get_family_species

    # keep entries with positive weight and uncaptured species
    same_family = encounters.select do |enc|
      next false unless enc && enc[0].to_i > 0
      family.include?(enc[1])
    end
    return nil if same_family.empty?

    # weighted pick by chance (enc[0])
    total = same_family.sum { |enc| enc[0].to_i }
    r = rand(total)
    same_family.each do |enc|
      r -= enc[0].to_i
      return enc if r < 0
    end
    same_family.sample   # fallback (shouldn’t hit)
  end

  def pbShouldFilterOutOtherPkmn?
    lead = $Trainer&.first_pokemon
    lead && !lead.egg? && [:HPUP, :PROTEIN, :IRON, :CALCIUM, :ZINC, :CARBOS].include?(lead.item_id)
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
    return super unless pbShouldFilterOutOtherPkmn?

    unless enc_type && GameData::EncounterType.exists?(enc_type)
      raise ArgumentError, _INTL("Encounter type {1} does not exist", enc_type)
    end

    encounters = @encounter_tables[enc_type]
    enc = pbFilterOutOtherPkmnFromEncounter(encounters)
    return super unless enc

    [enc[1], pbGetEncounterLevel(enc)]
  end
end

PokemonEncounters.prepend(ShinyGummies)