require_relative 'PokerDeck'
require_relative 'PokerHandEvaluator'

class CasinoEngine
	def initialize
	end

	# todo: maybe make this customizable
	BET_MULTIPLIER_TABLE = {
		PokerHandEvaluator::HAND_EVALUATIONS_NOTHING => 0,
		PokerHandEvaluator::HAND_EVALUATIONS_ONE_PAIR => 0,
		PokerHandEvaluator::HAND_EVALUATIONS_TWO_PAIR => 1,
		PokerHandEvaluator::HAND_EVALUATIONS_THREE_OF_A_KIND => 1,
		PokerHandEvaluator::HAND_EVALUATIONS_STRAIGHT => 3,
		PokerHandEvaluator::HAND_EVALUATIONS_FLUSH => 4,
		PokerHandEvaluator::HAND_EVALUATIONS_FULL_HOUSE => 10,
		PokerHandEvaluator::HAND_EVALUATIONS_FOUR_OF_A_KIND => 20,
		PokerHandEvaluator::HAND_EVALUATIONS_STRAIGHT_FLUSH => 25,
		PokerHandEvaluator::HAND_EVALUATIONS_FIVE_OF_A_KIND => 60,
		PokerHandEvaluator::HAND_EVALUATIONS_ROYAL_FLUSH => 25,
		PokerHandEvaluator::HAND_EVALUATIONS_ROYAL_FLUSH_NATURAL => 250
	}

	DOUBLE_UP_ROUND_LIMIT = 10
	DOUBLE_UP_WINNINGS_LIMIT = 1500000 # can start a new double up if you're below this

	def betMultiplierForHand(hand)
		handEvaluator = PokerHandEvaluator.new
		evaluation = handEvaluator.evaluateHand(hand)

		BET_MULTIPLIER_TABLE[evaluation]
	end

	# creates a new deck and deals the player a hand
	def startHand
		@curDeck = PokerDeck.new(true)
		@doubleDeck = PokerDeck.new(false)
		@doubleCard = nil

		@curDeck.dealHand(5)
	end

	# fills hand back up to full (i.e. after discarding)
	def fillHand(hand)
		while hand.length < 5
			hand.push(@curDeck.dealCard)
		end
		hand
	end
end