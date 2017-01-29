class PokerDeck
	# for now, we are assuming it's one deck, 52 cards, maybe joker
	def initialize(addJoker)
		@cards = []
		maxValue = 51
		if addJoker
			maxValue = 52
		end
		for i in 0..maxValue
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