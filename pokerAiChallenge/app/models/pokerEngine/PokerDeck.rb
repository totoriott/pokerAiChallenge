class PokerCard
	def initialize(value)
		@cardValue = value
	end

	def to_s
		if @cardValue == 52
			'[Joker]'
		else
			suitTypes = ['H', 'D', 'C', 'S']
			cardTypes = ['A', '2', '3', '4', '5', '6', '7', '8', '9', '10', 'J', 'Q', 'K']

			'[' + cardTypes[self.value] + suitTypes[self.suit] + ']'
		end
	end

	def suit
		return @cardValue / 13
	end

	def value
		return @cardValue % 13
	end
end

class PokerDeck
	# for now, we are assuming it's one deck, 52 cards, no joker
	def initialize
		@cards = []
		for i in 0...52 # todo: add index 52 when you want joker
			@cards.push(PokerCard.new(i))
		end
		self.shuffleDeck
	end

	def printDeck
		# note that the deck is dealt from the back
		# we could get around this by reversing the deck before printing or dealing
		print 'Deck: '
		@cards.each do |card|
			print card
		end
		puts
	end

	def shuffleDeck
		@cards = @cards.shuffle
	end

	def dealCard
		@cards.pop
	end

	def dealHand(handSize)
		hand = []
		for i in 0...handSize
			hand.push(self.dealCard)
		end
		hand
	end
end

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
	NAME_HAND_EVALUATIONS = ["Nothing", "One Pair", "Two Pair", "Three of a Kind", 
		"Straight", "Flush", "Full House", "Four of a Kind", 
		"Five of a Kind", "Straight Flush", "Royal Straight Flush"]

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

	# note this assumes a 5 card poker hand
	# todo: this will suck 1000x more with joker
	def evaluateHand(hand)
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
				evaluation = HAND_EVALUATIONS_ROYAL_FLUSH
			end
		end

		return evaluation
	end
end

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