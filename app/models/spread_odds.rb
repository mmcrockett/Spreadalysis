class SpreadOdds < VisitorStats
  SPREAD_TO_MONEYLINE      = {
                              BigDecimal.new("0") => 100,
                              BigDecimal.new("1") => 114,
                              BigDecimal.new("1.5") => 122,
                              BigDecimal.new("2") => 130,
                              BigDecimal.new("2.5") => 139,
                              BigDecimal.new("3") => 148,
                              BigDecimal.new("3.5") => 158,
                              BigDecimal.new("4") => 168,
                              BigDecimal.new("4.5") => 180,
                              BigDecimal.new("5") => 192,
                              BigDecimal.new("5.5") => 205,
                              BigDecimal.new("6") => 219,
                              BigDecimal.new("6.5") => 233,
                              BigDecimal.new("7") => 249,
                              BigDecimal.new("7.5") => 266,
                              BigDecimal.new("8") => 284,
                              BigDecimal.new("8.5") => 303,
                              BigDecimal.new("9") => 323,
                              BigDecimal.new("9.5") => 345,
                              BigDecimal.new("10") => 368,
                              BigDecimal.new("10.5") => 393,
                              BigDecimal.new("11") => 419,
                              BigDecimal.new("11.5") => 448,
                              BigDecimal.new("12") => 478,
                              BigDecimal.new("12.5") => 510,
                              BigDecimal.new("13") => 544,
                              BigDecimal.new("13.5") => 581,
                              BigDecimal.new("14") => 620,
                              BigDecimal.new("14.5") => 662,
                              BigDecimal.new("15") => 706,
                              BigDecimal.new("15.5") => 754,
                              BigDecimal.new("16") => 805,
                              BigDecimal.new("16.5") => 859,
                              BigDecimal.new("17") => 917,
                              BigDecimal.new("17.5") => 978,
                              BigDecimal.new("18") => 1044,
                              BigDecimal.new("18.5") => 1114,
                              BigDecimal.new("19") => 1189,
                              BigDecimal.new("19.5") => 1270,
                              BigDecimal.new("20") => 1355,
                              BigDecimal.new("20.5") => 1446,
                              BigDecimal.new("21") => 1544,
                              BigDecimal.new("21.5") => 1648,
                              BigDecimal.new("22") => 1758,
                              BigDecimal.new("22.5") => 1877,
                              BigDecimal.new("23") => 2003,
                              BigDecimal.new("23.5") => 2138,
                              BigDecimal.new("24") => 2282
                             } 

  def initialize(line)
    @line = line
  end

  def expected_moneyline
    if (true == SPREAD_TO_MONEYLINE.include?(@line))
      return SPREAD_TO_MONEYLINE[@line]
    else
      raise "!ERROR: Unknown Line: #{@line} #{@line.class} #{SPREAD_TO_MONEYLINE[@line]} #{SPREAD_TO_MONEYLINE.keys.first.class}"
    end
  end
end
