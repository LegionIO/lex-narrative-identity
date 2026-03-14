# frozen_string_literal: true

require 'securerandom'

module Legion
  module Extensions
    module NarrativeIdentity
      module Helpers
        class Theme
          attr_reader :id, :name, :theme_type, :episode_ids
          attr_accessor :strength

          def initialize(name:, theme_type:, strength: 0.0, episode_ids: nil, id: nil)
            @id          = id || SecureRandom.uuid
            @name        = name
            @theme_type  = theme_type
            @strength    = strength.clamp(0.0, 1.0)
            @episode_ids = episode_ids || []
          end

          def reinforce!(amount)
            @strength = (@strength + amount).clamp(0.0, 1.0).round(10)
          end

          def decay!
            @strength = (@strength - Constants::COHERENCE_DECAY).clamp(0.0, 1.0).round(10)
          end

          def prominent?
            @strength >= 0.6
          end

          def to_h
            {
              id:          @id,
              name:        @name,
              theme_type:  @theme_type,
              strength:    @strength,
              episode_ids: @episode_ids.dup
            }
          end
        end
      end
    end
  end
end
