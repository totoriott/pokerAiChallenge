require_relative 'CasinoEngine'
require_relative 'PokerHandEvaluator'

class AiRule
	RULE_TYPE_JOKER = 0;
	RULE_TYPE_HAND_OF_VALUE = 1;
	RULE_TYPE_SAME_SUIT = 2;
	RULE_TYPE_SAME_VALUE = 3;
	RULE_TYPE_RUN_OF_LENGTH = 4;

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

class AiDoubleRule
	DOUBLE_RULE_TYPE_WINNINGS_BELOW = 0
	DOUBLE_RULE_TYPE_CARD_BELOW = 1
	DOUBLE_RULE_TYPE_CARD_ABOVE = 2
	DOUBLE_RULE_TYPE_ROUND_BELOW = 3

	DOUBLE_AI_ACTION_MANDATORY = 0
	DOUBLE_AI_ACTION_GO_IF_TRUE = 1

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
	DOUBLE_ACTION_LOWER = 0
	DOUBLE_ACTION_HIGHER = 1

	def initialize(myRules, myDoubleRules)
		@rules = myRules
		@doubleRules = myDoubleRules

		# testing
		# todo: joker won't mesh properly with other rules yet
		@rules.push(AiRule.new(AiRule::RULE_TYPE_HAND_OF_VALUE, 1, AiRule::AI_ACTION_KEEP_AND_CONTINUE))
		@rules.push(AiRule.new(AiRule::RULE_TYPE_SAME_SUIT, 4, AiRule::AI_ACTION_KEEP_AND_CONTINUE))
		@rules.push(AiRule.new(AiRule::RULE_TYPE_SAME_VALUE, 2, AiRule::AI_ACTION_KEEP_AND_CONTINUE))
		@rules.push(AiRule.new(AiRule::RULE_TYPE_RUN_OF_LENGTH, 4, AiRule::AI_ACTION_KEEP_AND_CONTINUE))
		@rules.push(AiRule.new(AiRule::RULE_TYPE_JOKER, 1, AiRule::AI_ACTION_KEEP_AND_STOP))
		
		@doubleRules.push(AiDoubleRule.new(AiDoubleRule::DOUBLE_RULE_TYPE_WINNINGS_BELOW, 32, AiDoubleRule::DOUBLE_AI_ACTION_GO_IF_TRUE))
		@doubleRules.push(AiDoubleRule.new(AiDoubleRule::DOUBLE_RULE_TYPE_ROUND_BELOW, 1, AiDoubleRule::DOUBLE_AI_ACTION_GO_IF_TRUE))
		@doubleRules.push(AiDoubleRule.new(AiDoubleRule::DOUBLE_RULE_TYPE_CARD_BELOW, 6, AiDoubleRule::DOUBLE_AI_ACTION_GO_IF_TRUE))
		@doubleRules.push(AiDoubleRule.new(AiDoubleRule::DOUBLE_RULE_TYPE_CARD_ABOVE, 9, AiDoubleRule::DOUBLE_AI_ACTION_GO_IF_TRUE))
	end

	# todo: maybe these can be moved
	def cardsInHandOfSuit(hand, suit)
		hand.select { |card| card.suit == suit }
	end

	def cardsInHandOfValue(hand, value)
		hand.select { |card| card.value == value }
	end

	def runOfLengthInHand(hand, length)
		result = []
		for i in 0..12
			startRun = i
			endRun = i + (length-1)
			# TODO: fix this to only pull one of each card (i.e. 2345, not 23445)
			if endRun == 13 # Ace, wraparound
				attempt = hand.select { |card| (card.value >= startRun and card.value <= endRun) or (card.value == 0 and !card.isJoker) }
				if attempt.length == length
					result = attempt
				end
			elsif endRun < 13
				attempt = hand.select { |card| card.value >= startRun and card.value <= endRun }
				if attempt.length == length
					result = attempt
				end
			end
		end
		result
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
		when AiRule::RULE_TYPE_SAME_SUIT
			handEvaluator = PokerHandEvaluator.new
			groupedSuits = handEvaluator.cardsGroupedBySuit(hand)
			if !groupedSuits[rule.count].nil?
				# todo: handle if you have multiple such cases
				suit = groupedSuits[rule.count][0]
				cardsInHandOfSuit(hand, suit)
			else
				[]
			end
		when AiRule::RULE_TYPE_SAME_VALUE
			handEvaluator = PokerHandEvaluator.new
			groupedValues = handEvaluator.cardsGroupedByValue(hand)
			if !groupedValues[rule.count].nil?
				# todo: handle if you have multiple such cases
				value = groupedValues[rule.count][0]
				cardsInHandOfValue(hand, value)
			else
				[]
			end
		when AiRule::RULE_TYPE_RUN_OF_LENGTH
			handEvaluator = PokerHandEvaluator.new
			longestRunLength = handEvaluator.lengthOfLongestRunOfCards(hand)
			if longestRunLength == rule.count
				runOfLengthInHand(hand, rule.count)
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
			if matchCards.length > 0
				# todo: uncomment if you wanna make sure you're saving cards ok
				#puts matchCards
				#puts
				if rule.action == AiRule::AI_ACTION_KEEP_AND_CONTINUE
					hand = hand - matchCards
					keptHand += matchCards
				elsif rule.action == AiRule::AI_ACTION_KEEP_AND_STOP
					hand = hand - matchCards
					keptHand += matchCards
					break
				end
			end
		end

		keptHand
	end

	def shouldDoubleUp(winnings, visibleCard, doubleRound)
		mandatoryOk = true
		goIfTrue = false

		@doubleRules.each do |rule|
			ruleSuccess = false

			if rule.ruleType == AiDoubleRule::DOUBLE_RULE_TYPE_WINNINGS_BELOW
				ruleSuccess = winnings < rule.count
			elsif rule.ruleType == AiDoubleRule::DOUBLE_RULE_TYPE_CARD_BELOW
				if !visibleCard.nil?
					ruleSuccess = visibleCard.value < rule.count
				elsif rule.action == AiDoubleRule::DOUBLE_AI_ACTION_MANDATORY
					ruleSuccess = true # don't fail mandatory if it's first round
				end
			elsif rule.ruleType == AiDoubleRule::DOUBLE_RULE_TYPE_CARD_ABOVE
				if !visibleCard.nil?
					ruleSuccess = visibleCard.value > rule.count
				elsif rule.action == AiDoubleRule::DOUBLE_AI_ACTION_MANDATORY
					ruleSuccess = true # don't fail mandatory if it's first round
				end
			elsif rule.ruleType == AiDoubleRule::DOUBLE_RULE_TYPE_ROUND_BELOW
				ruleSuccess = doubleRound < rule.count
			end

			if ruleSuccess and rule.action == AiDoubleRule::DOUBLE_AI_ACTION_GO_IF_TRUE
				goIfTrue = true
			end
			if !ruleSuccess and rule.action == AiDoubleRule::DOUBLE_AI_ACTION_MANDATORY
				mandatoryOk = false
			end
		end

		mandatoryOk and goIfTrue
	end

	def getDoubleUpAction(winnings, visibleCard) 
		if (visibleCard.value < 8)
			DOUBLE_ACTION_HIGHER 
		else
			DOUBLE_ACTION_LOWER
		end
		# TODO
	end
end