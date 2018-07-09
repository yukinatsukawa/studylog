require 'minitest/autorun'

class User
	attr_reader :name

	def initialize(name, weight)
		@name = name
		@weight = weight
	end

	def heavier_than?(other_user)
		other_user.weight < @weight
	end

	protected
	def weight
		@weight
	end
end

class WeightTest < Minitest::Test

	def setup
		@foo = User.new('Foo', 55)
		@bar = User.new('Bar', 62)
	end

	def test_foo_heavier_than_bar?
		assert_equal @foo.heavier_than?(@bar), false
	end

	def test_send_foo_weight
		assert_equal @foo.send(:weight), 55
	end
end