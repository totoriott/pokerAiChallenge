require_relative 'CasinoEngine'

class AiRule
	RULE_TYPE_JOKER = 0;
	RULE_TYPE_HAND_OF_VALUE = 1;

	AI_ACTION_KEEP_AND_CONTINUE = 0;
	AI_ACTION_KEEP_AND_STOP = 1;

	def initialize(myRuleType, myCount, myAction)
		@ruleType = myRuleType
		@count = myCount
		@action = myAction
	end

	def ruleType
		@ruleType
	end

	def count
		@count
	end

	def action
		@action
	end
end

class AiModel
	def initialize(myRules)
		@rules = myRules

		# testing
		# todo: joker won't mesh properly with other rules yet
		@rules.push(AiRule.new(AiRule::RULE_TYPE_HAND_OF_VALUE, 1, AiRule::AI_ACTION_KEEP_AND_STOP))
		@rules.push(AiRule.new(AiRule::RULE_TYPE_JOKER, 1, AiRule::AI_ACTION_KEEP_AND_STOP))
	end

	def cardsThatMatchRule(hand, rule)
		case rule.ruleType
		when AiRule::RULE_TYPE_HAND_OF_VALUE 
			# TODO: pass in casino engine
			casinoEngine = CasinoEngine.new
			valueOfHand = casinoEngine.betMultiplierForHand(hand)
			if valueOfHand >= rule.count
				hand
			else
				[]
			end
		when AiRule::RULE_TYPE_JOKER
			jokerCards = hand.select { |card| card.isJoker == true }
			if jokerCards.length >= rule.count
				jokerCards
			else
				[]
			end
		else
			[]
		end
	end

	# returns a subset of hand corresponding to what cards to keep
	def getKeptCards(hand)
		keptHand = []

		@rules.each do |rule|
			matchCards = cardsThatMatchRule(hand, rule)
			if matchCards.length >= 0
				if rule.action == AiRule::AI_ACTION_KEEP_AND_CONTINUE
					# todo: implement
					ok = 2
				elsif rule.action == AiRule::AI_ACTION_KEEP_AND_STOP
					keptHand += matchCards
					break
				end
			end
		end

		keptHand
	end
end