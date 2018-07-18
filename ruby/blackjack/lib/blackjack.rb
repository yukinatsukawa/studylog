class Card
	attr_reader :suit, :rank

	def initialize(suit, rank)
		@suit = suit
		@rank = rank
	end

	def display_rank
		case @rank
		when 11
			"J"
		when 12
			"Q"
		when 13
			"K"
		when 1
			"A"
		else
			@rank
		end
	end
end

class Deck
	attr_reader :cards

	def initialize
		suits = ["♤", "♡", "♢", "♧"]
		ranks = (1..13).to_a

		@cards = []
		suits.each do |suit|
			ranks.each do |rank|
				@cards << Card.new(suit, rank)
			end
		end
	end

	def shuffle
		@cards.shuffle!
	end
end

class Player
	include Enumerable

	attr_reader :want_one_more_turn
	attr_reader :hands_value
	attr_reader :name
	attr_reader :bet

	MINIMUM_BET = 100
	MAXIMUM_BET = 5000
	BET_UNIT = 100

	def initialize(name)
		@name = name
		@wallet = 10000
		@bet = 0
		@hands = []
		@hands_value = 0
		@want_one_more_turn = true
	end

	def init
		@bet = 0
		@hands = []
		@hands_value = 0
		@want_one_more_turn = true
	end

	def bet_money
		@bet = 100
		puts "#{@name} bet #{@bet}."
	end

	def select
		count_hands_value < 17
	end

	def hit(deck)
		@hands << deck.cards.shift
		show_card
		@want_one_more_turn = false if count_hands_value >= 21
	end

	def stand
		@want_one_more_turn = false
	end

	def show_card
		puts "#{@name} got #{@hands.last.suit} #{@hands.last.display_rank}. hands_value:#{count_hands_value}"
	end

	def count_hands_value
		@hands_value = 0
		@hands.each { |card| @hands_value += value_rank(card.rank) }
		@hands.each { |card| switch_ace(card) }
		@hands_value
	end

	def value_rank(rank)
		case rank
		when 1
			11
		when 2..10
			rank
		when 11..13
			10
		else
			nil
		end
	end

	def switch_ace(card)
		if @hands_value > 21 && card.rank == 1
			@hands_value -= 10
		end
	end

	def open_hand
		message = "#{@name} have "
		@hands.each { |card| message += "#{card.suit} #{card.display_rank} "}
		message += "and hands_value is #{count_hands_value}."
		puts message
	end
end

class User < Player
	attr_accessor :want_one_more_game
	def initialize(name)
		super(name)
		@want_one_more_game = true
	end

	def bet_money
		puts "How much money do you bet?"
		input = gets.chomp.to_i
		if input > @wallet
			puts "You don't have so much money."
			bet
		elsif input > MAXIMUM_BET
			puts "You can bet #{MAXIMUM_BET} at most."
			bet
		elsif input < MINIMUM_BET
			puts "You have to bet #{MINIMUM_BET} at least."
			bet
		else
			@bet = input
			@wallet -= input
			puts "You bet #{@bet}. You have #{@wallet} in your wallet."
		end
	end

	def select
		puts "Which do you do, hit or stand? hands_value:#{count_hands_value} [hit->(h):stand->(s)]"
		input = gets.chomp
		if input == 'h'
			true
		else
			false
		end
	end
end

class Dealer < Player
	def show_card
		if @hands.size < 2
			puts "#{@name} got #{@hands.last.suit} #{@hands.last.display_rank}. hands_value:#{count_hands_value}"
		else
			puts "#{@name} got a card."
		end
	end
end

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

		judge

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

	def judge
		@dealer.open_hand
		@players.each do |player|
			if player.hands_value > 21
				puts "#{player.name} lose. #{player.name} lose #{player.bet}."
			elsif @dealer.hands_value > 21
				puts "#{player.name} win! #{player.name} get #{player.bet}."
			else
				case player.hands_value <=> @dealer.hands_value
				when 1
					puts "#{player.name} win! #{player.name} get #{player.bet}."
				when 0
					puts "#{player.name} draw."
				when -1
					puts "#{player.name} lose. #{player.name} lose #{player.bet}."
				end
			end
		end					
	end
end
