require_relative 'AiModel'
require_relative 'CasinoEngine'
require_relative 'PokerCard'
require_relative 'PokerDeck'
require_relative 'PokerHandEvaluator'

def testEvaluatingHands
	handEvaluator = PokerHandEvaluator.new

	for i in 0...10
		deck = PokerDeck.new
		hand = deck.dealHand(5)
		evaluation = handEvaluator.evaluateHand(hand)

		print 'Hand: '
		hand.each do |card|
			print card
		end
		print ' - ' + PokerHandEvaluator::NAME_HAND_EVALUATIONS[evaluation]

		puts 
	end
end

def testCasinoEngineWithAi
	casino = CasinoEngine.new
	aiModel = AiModel.new([])

	for i in 0...10
		hand = casino.startHand

		print 'Before: '
		hand.each do |card|
			print card
		end
		print ' | '

		hand = aiModel.getKeptCards(hand)
		hand = casino.fillHand(hand)

		print 'After: '
		hand.each do |card|
			print card
		end

		print ' - ' + casino.betMultiplierForHand(hand).to_s

		puts
	end
end

if __FILE__ == $0
	testCasinoEngineWithAi
end