# frozen_string_literal: true

module Legion
  module Extensions
    module NarrativeIdentity
      module Helpers
        module Constants
          MAX_EPISODES = 500
          MAX_THEMES   = 50
          MAX_CHAPTERS = 20

          EPISODE_TYPES = %i[
            achievement
            failure
            discovery
            relationship
            challenge
            transformation
            routine
          ].freeze

          THEME_TYPES = %i[
            growth
            agency
            communion
            redemption
            contamination
            stability
            exploration
          ].freeze

          EMOTIONAL_VALENCE_WEIGHT = 0.4
          SIGNIFICANCE_WEIGHT      = 0.3
          RECENCY_WEIGHT           = 0.3
          COHERENCE_DECAY          = 0.01

          SIGNIFICANCE_LABELS = [
            { (0.8..1.0)  => :defining  },
            { (0.6...0.8) => :major     },
            { (0.4...0.6) => :notable   },
            { (0.2...0.4) => :minor     },
            { (0.0...0.2) => :trivial   }
          ].freeze

          COHERENCE_LABELS = [
            { (0.8..1.0)  => :unified    },
            { (0.6...0.8) => :coherent   },
            { (0.4...0.6) => :developing },
            { (0.2...0.4) => :fragmented },
            { (0.0...0.2) => :absent     }
          ].freeze

          CHAPTER_LABELS = %i[origin early_learning growth mastery current].freeze
        end
      end
    end
  end
end
