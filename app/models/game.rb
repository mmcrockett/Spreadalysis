class Game < ActiveRecord::Base
  attr_accessible :date, :hline, :home, :hscore, :visitor, :vline, :vscore, :vspread, :overunder

  NFC_EAST  = ["DAL", "PHI", "NYG", "WAS"]
  NFC_SOUTH = ["NO",  "TB",  "ATL", "CAR"]
  NFC_WEST  = ["SF",  "SEA", "ARI", "STL"]
  NFC_NORTH = ["CHI", "DET", "MIN", "GB"]
  AFC_EAST  = ["MIA", "NWE", "NYJ", "BUF"]
  AFC_SOUTH = ["IND", "HOU", "TEN", "JAC"]
  AFC_WEST  = ["OAK", "SD",  "DEN", "KC"]
  AFC_NORTH = ["CLE", "CIN", "BAL", "PIT"]

  AFC = AFC_NORTH + AFC_SOUTH + AFC_EAST + AFC_WEST
  NFC = NFC_NORTH + NFC_SOUTH + NFC_EAST + NFC_WEST

  NFL = AFC + NFC

  def self.final?(value)
    return (value.downcase.include?("final"))
  end

  def self.week(value)
    week = "#{value.match(/\d+/)[0]}".to_i

    if (week < 0)
      raise "!ERROR: Unknown week: #{value}"
    end

    return week
  end

  def self.team(name)
    name.upcase!
    name.gsub!(".", "")

    # Direct match, return it
    if (true == NFL.include?(name))
      return name
    end

    # See if the "Indianapolis" starts with IND
    NFL.each do |team|
      if (true == name.start_with?(team))
        return team
      end
    end

    Game.acronyms(name).each do |possible_name|
      if (true == NFL.include?(possible_name))
        return possible_name
      end
    end

    raise "!ERROR: Unable to find team for #{name}!"
  end

  def self.acronyms(name)
    parts = name.upcase.split
    acronyms = [""]

    parts.each do |p|
      acronyms[0] << p[0]
    end

    if (2 <= acronyms[0].length)
      acronyms << acronyms[0][0..-2]
    else
      acronyms << acronyms[0]
    end

    acronyms << parts[0] + acronyms[0][-1]
    acronyms << parts[0] + acronyms[0][-2]

    if (true == name.include?("NEW ENGLAND"))
      acronyms << "NWE"
    elsif ("NE" == name)
      acronyms << "NWE"
    end

    return acronyms
  end
end
