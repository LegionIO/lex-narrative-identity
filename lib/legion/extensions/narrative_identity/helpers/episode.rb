# frozen_string_literal: true

require 'securerandom'

module Legion
  module Extensions
    module NarrativeIdentity
      module Helpers
        class Episode
          attr_reader :id, :content, :episode_type, :emotional_valence,
                      :significance, :domain, :themes, :created_at
          attr_accessor :chapter_id

          def initialize(content:, episode_type:, emotional_valence:, significance:, domain:, **)
            @id                = SecureRandom.uuid
            @content           = content
            @episode_type      = episode_type
            @emotional_valence = emotional_valence.clamp(-1.0, 1.0)
            @significance      = significance.clamp(0.0, 1.0)
            @domain            = domain
            @chapter_id        = nil
            @themes            = []
            @created_at        = Time.now.utc
          end

          def positive?
            @emotional_valence.positive?
          end

          def negative?
            @emotional_valence.negative?
          end

          def defining?
            @significance >= 0.8
          end

          def significance_label
            Constants::SIGNIFICANCE_LABELS.each do |entry|
              range, label = entry.first
              return label if range.cover?(@significance)
            end
            :trivial
          end

          def to_h
            {
              id:                @id,
              content:           @content,
              episode_type:      @episode_type,
              emotional_valence: @emotional_valence,
              significance:      @significance,
              domain:            @domain,
              chapter_id:        @chapter_id,
              themes:            @themes.dup,
              created_at:        @created_at
            }
          end
        end
      end
    end
  end
end
