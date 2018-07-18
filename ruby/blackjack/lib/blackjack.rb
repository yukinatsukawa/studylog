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

	def initialize(name)
		@name = name
		@hands = []
		@total = 0
		@want_one_more_turn = true
	end

	def init
		@hands = []
		@total = 0
		@want_one_more_turn = true
	end

	def select
		count_score < 17
	end

	def hit(deck)
		@hands << deck.cards.shift
		show_card
		@want_one_more_turn = false if count_score >= 21
	end

	def stand
		@want_one_more_turn = false
	end

	def show_card
		puts "#{@name} got #{@hands.last.suit} #{@hands.last.display_rank}. score:#{count_score}"
	end

	def count_score
		@total = 0
		@hands.each { |card| @total += value_rank(card.rank) }
		@hands.each { |card| switch_ace(card) }
		@total
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
		if @total > 21 && card.rank == 1
			@total -= 10
		end
	end

	def open_hand
		message = "#{@name} have "
		@hands.each { |card| message += "#{card.suit} #{card.display_rank} "}
		message += "and score is #{count_score}."
		puts message
	end
end

class User < Player
	def select
		puts "Which do you do, hit or stand? score:#{count_score} [hit->(h):stand->(s)]"
		answer = gets.chomp
		if answer == 'h'
			true
		else
			false
		end
	end
end

class Dealer < Player
	def show_card
		if @hands.size < 2
			puts "#{@name} got #{@hands.last.suit} #{@hands.last.display_rank}. score:#{count_score}"
		else
			puts "#{@name} got a card."
		end
	end
end

class Game
	attr_reader :players

	def initialize(player_names)
		@players = [User.new("You")]
		@dealer = Dealer.new("Dealer")
		player_names.each { |name| @players << Player.new(name)}
	end

	def play_one_more_game
		init

		@players.each { |player| player.hit(@deck) }
		@players.each { |player| player.hit(@deck) }

		while @players.any? { |player| player.want_one_more_turn }
			play_one_more_turn
		end

		while @dealer.want_one_more_turn
			@dealer.select ? @dealer.hit(@deck) : @dealer.stand
		end

		judge
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
		@deck = Deck.new
		@deck.shuffle
	end

	def judge
		@dealer.open_hand
	end
end
