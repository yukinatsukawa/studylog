require 'spec_helper'

RSpec.describe Game do
	before do
		@game = Game.new(["Alice", "Bob"])
		@game.play_one_more_game
	end

	describe '#initialize' do
		it "there_are_4_players" do
			expect(@game.players.size).to eq 4
		end
	end

	describe '#play_one_more_game' do
		#
	end
end
