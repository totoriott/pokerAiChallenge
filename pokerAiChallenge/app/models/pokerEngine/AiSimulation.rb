require_relative 'AiModel'
require_relative 'CasinoEngine'
require_relative 'PokerCard'
require_relative 'PokerDeck'
require_relative 'PokerHandEvaluator'

class AiSimulation
	def runSimulation(aiModel, casinoEngine, handCount, printHands=false)
		totalPayout = 0
		winningHands = 0;
		doubleTries = 0; # each individual double up
		doubleSuccesses = 0;
		doubleOverallTries = 0; # when you went into double and left with money
		doubleOverallSuccesses = 0;

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
				triedDouble = false

				while payout > 0 and casinoEngine.canDoubleUp(payout) and aiModel.shouldDoubleUp(payout, casinoEngine.doubleCard, casinoEngine.doubleAttempt)
					triedDouble = true
					doubleTries += 1
					casinoEngine.prepareDoubleCardIfNone

					action = aiModel.getDoubleUpAction(payout, casinoEngine.doubleCard)
					payout *= casinoEngine.performDoubleUp(action)

					if payout > 0
						doubleSuccesses += 1
					end
				end

				if triedDouble
					doubleOverallTries += 1
					if payout > 0
						doubleOverallSuccesses += 1
					end
				end
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
		print (100.0*doubleSuccesses/doubleTries).to_s + "% double win percentage (" + doubleSuccesses.to_s + "/" + doubleTries.to_s + ")"
		puts
		print (100.0*doubleOverallSuccesses/doubleOverallTries).to_s + "% double runs ended in payout (" + doubleOverallSuccesses.to_s + "/" + doubleOverallTries.to_s + ")"
		puts
	end
end