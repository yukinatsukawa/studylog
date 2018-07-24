require 'spec_helper'

RSpec.describe Game do
  before do
    @game = Game.new(["Alice", "Bob"])
    @game.begin_game
  end

  describe '#initialize' do
    it "there_are_3_players" do
      expect(@game.players.size).to eq 3
    end
  end
end
