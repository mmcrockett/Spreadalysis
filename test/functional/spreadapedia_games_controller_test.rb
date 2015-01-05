require 'test_helper'

class SpreadapediaGamesControllerTest < ActionController::TestCase
  setup do
    @spreadapedia_game = spreadapedia_games(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:spreadapedia_games)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create spreadapedia_game" do
    assert_difference('SpreadapediaGame.count') do
      post :create, spreadapedia_game: {  }
    end

    assert_redirected_to spreadapedia_game_path(assigns(:spreadapedia_game))
  end

  test "should show spreadapedia_game" do
    get :show, id: @spreadapedia_game
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @spreadapedia_game
    assert_response :success
  end

  test "should update spreadapedia_game" do
    put :update, id: @spreadapedia_game, spreadapedia_game: {  }
    assert_redirected_to spreadapedia_game_path(assigns(:spreadapedia_game))
  end

  test "should destroy spreadapedia_game" do
    assert_difference('SpreadapediaGame.count', -1) do
      delete :destroy, id: @spreadapedia_game
    end

    assert_redirected_to spreadapedia_games_path
  end
end
