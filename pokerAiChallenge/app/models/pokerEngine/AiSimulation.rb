require_relative 'AiModel'
require_relative 'CasinoEngine'
require_relative 'PokerCard'
require_relative 'PokerDeck'
require_relative 'PokerHandEvaluator'

class AiSimulation
	def runSimulation(aiModel, casinoEngine, handCount, printHands=false)
		totalPayout = 0
		winningHands = 0;

		for i in 0...handCount
			hand = casinoEngine.startHand

			if printHands
				print 'Before: '
				hand.each do |card|
					print card
				end
				print ' | '
			end

			hand = aiModel.getKeptCards(hand)
			hand = casinoEngine.fillHand(hand)
			payout = casinoEngine.betMultiplierForHand(hand)
			totalPayout += payout
			if payout > 0
				winningHands += 1
			end

			if printHands
				print 'After: '
				hand.each do |card|
					print card
				end

				print ' - ' + payout.to_s
				puts
			end
		end

		print "Total payout " + totalPayout.to_s + " over " + handCount.to_s + " hands."
		puts
		print winningHands.to_s + " winning hands in " + handCount.to_s + " hands."
		puts
		print (1.0*totalPayout/handCount).to_s + " average payout"
		puts
		print (100.0*winningHands/handCount).to_s + "% win percentage"
		puts
	end
end