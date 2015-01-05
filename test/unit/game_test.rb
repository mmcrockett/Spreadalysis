require 'test_helper'

class GameTest < ActiveSupport::TestCase
  test "rename nfl teams" do
    assert_equal("DAL", Game.team("dallas"))
    assert_equal("DAL", Game.team("dallas cowboys"))
    assert_equal("NO", Game.team("new orleans saints"))
    assert_equal("NO", Game.team("New orleans"))
    assert_equal("NO", Game.team("NO"))
    assert_equal("NWE", Game.team("new england patriots"))
    assert_equal("NWE", Game.team("New england"))
    assert_equal("NWE", Game.team("NE"))
    assert_equal("NYJ", Game.team("new york jets"))
    assert_equal("NYJ", Game.team("nyj"))
    assert_equal("NYJ", Game.team("ny jets"))
    assert_equal("NYG", Game.team("new york giants"))
    assert_equal("NYG", Game.team("nyg"))
    assert_equal("NYG", Game.team("ny giants"))
    assert_equal("STL", Game.team("St. louis rams"))
    assert_equal("STL", Game.team("st louis rams"))
    assert_equal("STL", Game.team("st louis"))
    assert_equal("STL", Game.team("stl"))
  end
end
  end
end
