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

			'[' + cardTypes[@cardValue % 13] + suitTypes[@cardValue / 13] + ']'
		end
	end
end

class PokerDeck
	# for now, we are assuming it's one deck, 52 cards + joker
	def initialize
		@cards = []
		for i in 0..52
			@cards.push(PokerCard.new(i))
		end
		self.shuffleDeck
	end

	def printDeck
		print 'Deck: '
		@cards.each do |card|
			print card
		end
		puts
	end

	def shuffleDeck
		@cards = @cards.shuffle
	end
end

if __FILE__ == $0
	deck = PokerDeck.new
	deck.printDeck
end