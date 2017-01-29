require_relative 'AiModel'
require_relative 'AiSimulation'
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

	aiSimulation = AiSimulation.new
	aiSimulation.runSimulation(aiModel, casino, 10000, false)
end

if __FILE__ == $0
	testCasinoEngineWithAi
end