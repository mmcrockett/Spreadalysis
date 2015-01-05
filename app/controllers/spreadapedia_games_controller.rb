require 'open-uri'

class SpreadapediaGamesController < ApplicationController
  # GET /spreadapedia_games
  # GET /spreadapedia_games.json
  def index
    @spreadapedia_games = SpreadapediaGames.where("date > '2012-08-01' AND (vscore IS NULL or hscore IS NULL or vmoneyline IS NULL or hmoneyline IS NULL)").all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @spreadapedia_games }
    end
  end

  # GET /spreadapedia_games/1
  # GET /spreadapedia_games/1.json
  def show
    @spreadapedia_game = SpreadapediaGames.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @spreadapedia_game }
    end
  end

  # GET /spreadapedia_games/new
  # GET /spreadapedia_games/new.json
  def new
    page = "http://www.nfl.com/liveupdate/scorestrip/scorestrip.json"
    page = "http://www.nfl.com/liveupdate/scorestrip/postseason/scorestrip.json"
    data = open(page).read()
    @games = []

    while (nil != data.index(",,"))
      data.gsub!(",,", ",\"\",")
    end
    @data = JSON.parse(data)

    @data["ss"].each do |row|
      puts "#{row}:#{row[2]}"

      if (4 > @games.size)
        weeks = 4
        type  = "WC"
      elsif (8 > @games.size)
        weeks = 3
        type  = "DP"
      elsif (10 > @games.size)
        weeks = 2
        type  = "CC"
      else
        weeks = 0
        type  = "Superbowl"
      end

      if ((true == Game.final?(row[2])) and ("#{row[12]}" != "55836"))
        components = {}
        components[:visitor] = Game.team(row[4])
        components[:home]    = Game.team(row[7])
        components[:hscore]  = row[9]
        components[:vscore]  = row[6]
        components[:week]    = type
        date    = Date.current()

        while (row[0] != date.strftime("%a"))
          date = date.yesterday()
        end
        components[:date] = date.weeks_ago(weeks)

        g = SpreadapediaGames.where(components).first

        if (nil == g)
          g = SpreadapediaGames.new(components)

          if (g.vscore == g.hscore)
            g.game_result("tie")
          elsif (g.vscore > g.hscore)
            g.game_result("win")
          else
            g.game_result("loss")
          end
        end

        @games << g
      end
    end

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @spreadapedia_game }
    end
  end

  # GET /spreadapedia_games/1/edit
  def edit
    @spreadapedia_game = SpreadapediaGames.find(params[:id])
  end

  # POST /spreadapedia_games
  # POST /spreadapedia_games.json
  def create
    g = SpreadapediaGames.new(params[:spreadapedia_games])
    g.line_result(params[:spreadapedia_games][:lresult])
    g.overunder_result(params[:spreadapedia_games][:ouresult])
    g.save()

    respond_to do |format|
      format.html { redirect_to '/spreadapedia_games/new', notice: 'Spreadapedia game was successfully created.' }
      format.json { render json: @spreadapedia_game, status: :created, location: @spreadapedia_game }
    end
  end

  # PUT /spreadapedia_games/1
  # PUT /spreadapedia_games/1.json
  def update
    @spreadapedia_game = SpreadapediaGames.find(params[:id])

    respond_to do |format|
      if @spreadapedia_game.update_attributes(params[:spreadapedia_games])
        format.html { redirect_to @spreadapedia_game, notice: 'Spreadapedia game was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @spreadapedia_game.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /spreadapedia_games/1
  # DELETE /spreadapedia_games/1.json
  def destroy
    @spreadapedia_game = SpreadapediaGames.find(params[:id])
    @spreadapedia_game.destroy

    respond_to do |format|
      format.html { redirect_to spreadapedia_games_url }
      format.json { head :no_content }
    end
  end
end
