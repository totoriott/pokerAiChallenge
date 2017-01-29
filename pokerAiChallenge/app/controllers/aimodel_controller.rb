# pokerEngine classes
require 'CasinoEngine'
require 'AiModel'
require 'AiSimulation'

class AimodelController < ApplicationController
	def index
		casino = CasinoEngine.new
		aiModel = AiModel.new([], [])

		aiSimulation = AiSimulation.new
		aiSimulation.runSimulation(aiModel, casino, 10000, false)

		@aiSimulation = aiSimulation
	end
end
