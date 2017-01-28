class PokerHandEvaluator
	HAND_EVALUATIONS_NOTHING = 0
	HAND_EVALUATIONS_ONE_PAIR = 1
	HAND_EVALUATIONS_TWO_PAIR = 2
	HAND_EVALUATIONS_THREE_OF_A_KIND = 3
	HAND_EVALUATIONS_STRAIGHT = 4
	HAND_EVALUATIONS_FLUSH = 5
	HAND_EVALUATIONS_FULL_HOUSE = 6
	HAND_EVALUATIONS_FOUR_OF_A_KIND = 7
	HAND_EVALUATIONS_STRAIGHT_FLUSH = 8
	HAND_EVALUATIONS_FIVE_OF_A_KIND = 9
	HAND_EVALUATIONS_ROYAL_FLUSH = 10
	HAND_EVALUATIONS_ROYAL_FLUSH_NATURAL = 11
	NAME_HAND_EVALUATIONS = ["Nothing", "One Pair", "Two Pair", "Three of a Kind", 
		"Straight", "Flush", "Full House", "Four of a Kind", 
		"Five of a Kind", "Straight Flush", "Royal Straight Flush", "Natural Royal Straight Flush"]

	def initialize
	end

	# returns a hash of {# of cards => [card values]}
	def cardsGroupedByValue(hand)
		handValues = hand.map{ |card| card.value }
		grouped = handValues.group_by{ |value| handValues.count(value)}
		finalGrouped = {}

		grouped.each do |key, array|
			array = array.uniq
			finalGrouped[key] = array
		end

		finalGrouped
	end

	# returns a hash of {# of cards => [suit values]}
	def cardsGroupedBySuit(hand)
		handValues = hand.map{ |card| card.suit }
		grouped = handValues.group_by{ |suit| handValues.count(suit)}
		finalGrouped = {}

		grouped.each do |key, array|
			array = array.uniq
			finalGrouped[key] = array
		end

		finalGrouped
	end

	def lengthOfLongestRunOfCards(hand)
		maxRunLength = 0;
		handValues = hand.map{ |card| card.value }

		for i in 0..12 # this is a little inefficient due to repeats. sorry
			runLength = 0

			j = i
			while j <= 13
				if handValues.include? j or (j == 13 and handValues.include? 0) # ace wraparound
					runLength += 1
					if (runLength > maxRunLength)
						maxRunLength = runLength
					end
				else 
					break
				end

				j += 1;
			end
		end

		maxRunLength
	end

	def evaluateHand(hand)
		hasJoker = false;
		hand.each do |card|
			if card.suit == 4
				hasJoker = true
			end
		end

		if hasJoker
			bestEvaluation = HAND_EVALUATIONS_NOTHING

			# consider the joker as every possible card in the deck
			newDeck = PokerDeck.new
			cardGiven = newDeck.dealCard
			while cardGiven	and !cardGiven.isJoker
				handWithoutJoker = hand.select { |card| card.isJoker == false }
				handWithoutJoker.push(cardGiven)

				evaluation = self.evaluateHandWithoutJoker(handWithoutJoker)
				if evaluation == HAND_EVALUATIONS_ROYAL_FLUSH_NATURAL
					evaluation = HAND_EVALUATIONS_ROYAL_FLUSH
				end

				if (evaluation > bestEvaluation)
					bestEvaluation = evaluation
				end

				cardGiven = newDeck.dealCard	
			end

			bestEvaluation
		else 
			self.evaluateHandWithoutJoker(hand)
		end
	end

	# note this assumes a 5 card poker hand
	def evaluateHandWithoutJoker(hand)
		evaluation = HAND_EVALUATIONS_NOTHING

		groupedValues = self.cardsGroupedByValue(hand)
		groupedSuits = self.cardsGroupedBySuit(hand)
		longestRunLength = self.lengthOfLongestRunOfCards(hand)

		# one pair
		if !groupedValues[2].nil?
			evaluation = HAND_EVALUATIONS_ONE_PAIR
		end

		# two pair
		if !groupedValues[2].nil? and groupedValues[2].length == 2
			evaluation = HAND_EVALUATIONS_TWO_PAIR
		end

		# three of a kind
		if !groupedValues[3].nil?
			evaluation = HAND_EVALUATIONS_THREE_OF_A_KIND
		end

		# straight
		if longestRunLength == 5
			evaluation = HAND_EVALUATIONS_STRAIGHT
		end

		# flush
		if !groupedSuits[5].nil?
			evaluation = HAND_EVALUATIONS_FLUSH
		end

		# full house
		if !groupedValues[2].nil? and !groupedValues[3].nil?
			evaluation = HAND_EVALUATIONS_FULL_HOUSE
		end

		# four of a kind
		if !groupedValues[4].nil?
			evaluation = HAND_EVALUATIONS_FOUR_OF_A_KIND
		end

		# straight flush
		if !groupedSuits[5].nil? and longestRunLength == 5
			evaluation = HAND_EVALUATIONS_STRAIGHT_FLUSH
		end

		# five of a kind
		if !groupedValues[5].nil?
			evaluation = HAND_EVALUATIONS_FIVE_OF_A_KIND
		end

		# royal flush
		if !groupedSuits[5].nil? and longestRunLength == 5
			if groupedValues[1].include? 0 and groupedValues[1].include? 12 # if it has an A and K
				evaluation = HAND_EVALUATIONS_ROYAL_FLUSH_NATURAL
			end
		end

		return evaluation
	end
end