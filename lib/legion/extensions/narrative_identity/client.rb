# frozen_string_literal: true

module Legion
  module Extensions
    module NarrativeIdentity
      class Client
        include Runners::NarrativeIdentity

        attr_reader :engine

        def initialize(engine: nil)
          @engine          = engine || Helpers::NarrativeEngine.new
          @default_engine  = @engine
        end
      end
    end
  end
end
