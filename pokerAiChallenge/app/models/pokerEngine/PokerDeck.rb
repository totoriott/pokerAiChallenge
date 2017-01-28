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

	def evaluateHand(hand)
		evaluation = ""

		self.cardsGroupedByValue(hand)

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

	for i in 0...5
		deck = PokerDeck.new
		hand = deck.dealHand(5)
		handEvaluator.evaluateHand(hand)
	end
end