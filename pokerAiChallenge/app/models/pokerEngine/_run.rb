require_relative 'PokerCard'
require_relative 'PokerDeck'
require_relative 'PokerHandEvaluator'

if __FILE__ == $0
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