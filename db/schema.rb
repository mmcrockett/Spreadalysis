# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20130109230124) do

  create_table "aggregate_winners", :force => true do |t|
    t.decimal "vspread"
    t.integer "games"
    t.integer "wins"
    t.integer "losses"
    t.integer "winsspread"
    t.integer "lossspread"
  end

  create_table "games", :force => true do |t|
    t.date    "date",                                    :null => false
    t.string  "visitor",                                 :null => false
    t.integer "vscore",                                  :null => false
    t.string  "home",                                    :null => false
    t.integer "hscore",                                  :null => false
    t.decimal "vspread",   :precision => 4, :scale => 1
    t.decimal "overunder", :precision => 4, :scale => 1, :null => false
    t.integer "vline"
    t.integer "hline"
  end

  create_table "over_stats", :force => true do |t|
    t.integer "games",                                :null => false
    t.decimal "over",   :precision => 4, :scale => 1, :null => false
    t.integer "overs",                                :null => false
    t.integer "unders",                               :null => false
  end

  create_table "spreadapedia_games", :force => true do |t|
    t.date    "date",                                     :null => false
    t.string  "week",                                     :null => false
    t.string  "visitor",                                  :null => false
    t.string  "home",                                     :null => false
    t.decimal "line",       :precision => 4, :scale => 1, :null => false
    t.decimal "overunder",  :precision => 4, :scale => 1, :null => false
    t.integer "vscore",                                   :null => false
    t.integer "hscore",                                   :null => false
    t.integer "lresult",                                  :null => false
    t.integer "result",                                   :null => false
    t.integer "ouresult"
    t.integer "vmoneyline"
    t.integer "hmoneyline"
  end

  create_table "visitor_stats", :force => true do |t|
    t.integer "games",                                   :null => false
    t.decimal "line",      :precision => 4, :scale => 1, :null => false
    t.integer "wins",                                    :null => false
    t.integer "losses",                                  :null => false
    t.integer "atswins",                                 :null => false
    t.integer "atslosses",                               :null => false
  end

end
