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

			if payout > 0
				winningHands += 1

				while payout > 0 and casinoEngine.canDoubleUp and aiModel.shouldDoubleUp(payout, casinoEngine.doubleCard, casinoEngine.doubleAttempt)
					casinoEngine.prepareDoubleCardIfNone

					action = aiModel.getDoubleUpAction(payout, casinoEngine.doubleCard)
					payout *= casinoEngine.performDoubleUp(action)
				end
				# todo: calculate average time you win doubles
			end

			totalPayout += payout

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