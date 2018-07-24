require "player"
require "deck"

class Game
  attr_reader :players

  def initialize(player_names)
    @players = [User.new("You")]
    @user = @players[0]
    @dealer = Dealer.new("Dealer")
    player_names.each { |name| @players << Player.new(name)}
  end

  def begin_game
    while @user.want_one_more_game
      play_one_more_game
    end
  end

  def play_one_more_game
    init

    @players.each { |player| player.bet_money }
    2.times { @players.each { |player| player.hit(@deck) } }
    2.times { @dealer.hit(@deck) }

    while @players.any? { |player| player.want_one_more_turn }
      play_one_more_turn
    end

    while @dealer.want_one_more_turn
      @dealer.select ? @dealer.hit(@deck) : @dealer.stand
    end

    @dealer.open_hand
    @players.each { |player| player.judge(@dealer) }

    puts "Do you want to play one more game? [yes->(y):no->(n)]"
    input = gets.chomp
    if input == "y"
      @user.want_one_more_game = true
    else
      @user.want_one_more_game = false
    end
  end

  def play_one_more_turn
    @players.each do |player|
      if player.want_one_more_turn
        player.select ? player.hit(@deck) : player.stand
      end
    end
  end

  def init
    @players.each { |player| player.init }
    @dealer.init
    @deck = Deck.new
    @deck.shuffle
  end
end
