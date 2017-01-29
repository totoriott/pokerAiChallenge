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

	def isJoker
		return self.suit == 4
	end
end