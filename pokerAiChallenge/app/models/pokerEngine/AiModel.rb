class AiRule
	RULE_TYPE_JOKER = 0;

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
		@rules.push(AiRule.new(AiRule::RULE_TYPE_JOKER, 1, AiRule::AI_ACTION_KEEP_AND_STOP))
	end

	def cardsThatMatchRule(hand, rule)
		case rule.ruleType
		when AiRule::RULE_TYPE_JOKER
			jokerCards = hand.select { |card| card.isJoker == true }
			jokerCards
		else
			[]
		end
	end

	# returns a subset of hand corresponding to what cards to keep
	def getKeptCards(hand)
		keptHand = []

		@rules.each do |rule|
			matchCards = cardsThatMatchRule(hand, rule)
			if matchCards.length >= rule.count
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