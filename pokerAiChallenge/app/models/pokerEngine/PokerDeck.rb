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
		evaluation = ""

		groupedValues = self.cardsGroupedByValue(hand)
		groupedSuits = self.cardsGroupedBySuit(hand)
		longestRunLength = self.lengthOfLongestRunOfCards(hand)

		# one pair
		if !groupedValues[2].nil?
			evaluation = "One pair"
		end

		# two pair
		if !groupedValues[2].nil? and groupedValues[2].length == 2
			evaluation = "Two pair"
		end

		# three of a kind
		if !groupedValues[3].nil?
			evaluation = "Three of a kind"
		end

		# straight
		if longestRunLength == 5
			evaluation = "Straight"
		end

		# flush
		if !groupedSuits[5].nil?
			evaluation = "Flush"
		end

		# full house
		if !groupedValues[2].nil? and !groupedValues[3].nil?
			evaluation = "Full house"
		end

		# four of a kind
		if !groupedValues[4].nil?
			evaluation = "Four of a kind"
		end

		# straight flush
		if !groupedSuits[5].nil? and longestRunLength == 5
			evaluation = "Straight flush"
		end

		# five of a kind
		if !groupedValues[5].nil?
			evaluation = "Five of a kind"
		end

		# royal flush
		if !groupedSuits[5].nil? and longestRunLength == 5
			if groupedValues[1].include? 0 and groupedValues[1].include? 12 # if it has an A and K
				evaluation = "Royal straight flush"
			end
		end

		print 'Hand: '
		hand.each do |card|
			print card
		end
		print ' - ' + evaluation

		puts 
	end
end

if __FILE__ == $0
	handEvaluator = PokerHandEvaluator.new

	for i in 0...10
		deck = PokerDeck.new
		hand = deck.dealHand(5)
		handEvaluator.evaluateHand(hand)
	end
end