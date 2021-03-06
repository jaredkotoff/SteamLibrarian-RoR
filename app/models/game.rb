class Game < ActiveRecord::Base
  has_many :game_concepts
  has_many :game_themes
  has_many :game_genres
  has_many :users_games
  
  
  def self.getInfo(name, appid)
    game = GiantBomb::Game.find(name)[0]
    Game.newGame(game, appid)
  end

  
  def self.checkGames(games, force_update)
    game_ids = []
    game_genres = []
    update_game_genres = []
    game_concepts =[]
    update_game_concepts = []
    game_themes = [] 
    update_game_themes = []
    games.each do |gameObject|
      gb_id = nil
      new = false
      # Checks if the game already exists
      game = Game.find_by(appid: gameObject['appid'])
      if(game)
        gb_id = game.gb_id
        new = false
      else
        new = true
        # Look up by name if we dont already have it in our DB
        gbLookup = GiantBomb::Game.find(gameObject['name'])[0]
        # if the look up suceeded and we dont have that gb_id in our db
        if gbLookup != nil && !Game.exists?(gb_id: gbLookup.id)
          gb_id = gbLookup.id
        end
      end
      
      if(gb_id)
        # Get info directly from the game
        apicall = HTTParty.get("http://www.giantbomb.com/api/game/3030-" + gb_id.to_s + "/?api_key=" + ENV['GIANTBOMB_API_KEY'] + "&format=json")
        if(apicall['status_code'] == 1)
          gbObject = apicall['results']
          if gbObject != nil && gbObject != []
            if(new)
              #create new Game entry
              game = Game.new
              game.gb_id = gbObject['id']
              game.appid = gameObject['appid']
            end
            game.name = gbObject['name']
            game.api_detail_url = gbObject['api_detail_url']
            game.site_detail_url = gbObject['site_detail_url']
            game.deck = gbObject['deck']
            game.image = gbObject['image']['icon_url'] if gbObject['image'] != nil
            game.date_last_updated = gbObject['date_last_updated']
            if game.save
              if(new)
                game_genres << [game.id, gbObject['genres']] if gbObject['genres'] != nil
                game_themes << [game.id, gbObject['themes']] if gbObject['themes'] != nil
                game_concepts << [game.id, gbObject['concepts']] if gbObject['concepts'] != nil
              elsif(force_update)
                update_game_genres << [game.id, gbObject['genres']] if gbObject['genres'] != nil
                update_game_themes << [game.id, gbObject['themes']] if gbObject['themes'] != nil
                update_game_concepts << [game.id, gbObject['concepts']] if gbObject['concepts'] != nil
              end
            end
          end
          game_ids << [game.id, gameObject['playtime_forever'], gameObject['playtime_2weeks']]
        end
      end
    end
    GameGenre.add(game_genres) if game_genres != []
    GameTheme.add(game_themes) if game_themes != []
    GameConcept.add(game_concepts) if game_concepts != []
    if(force_update)
      GameGenre.update(update_game_genres) if update_game_genres != []
      GameTheme.update(update_game_themes) if update_game_themes != []
      GameConcept.update(update_game_concepts) if update_game_concepts != []
    end
    return game_ids
  end


  def self.deleteGame(gameID)
    #delete existing game object
    game = Game.find(gameID)
    game.destroy
  end
end
 