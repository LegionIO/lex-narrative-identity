# frozen_string_literal: true

require 'securerandom'

module Legion
  module Extensions
    module NarrativeIdentity
      module Helpers
        class Chapter
          attr_reader :id, :title, :label, :episode_ids, :start_time
          attr_accessor :end_time

          def initialize(title:, label:, episode_ids: nil, start_time: nil, end_time: nil, id: nil)
            @id          = id || SecureRandom.uuid
            @title       = title
            @label       = label
            @episode_ids = episode_ids || []
            @start_time  = start_time || Time.now.utc
            @end_time    = end_time
          end

          def current?
            @end_time.nil?
          end

          def episode_count
            @episode_ids.size
          end

          def to_h
            {
              id:          @id,
              title:       @title,
              label:       @label,
              episode_ids: @episode_ids.dup,
              start_time:  @start_time,
              end_time:    @end_time
            }
          end
        end
      end
    end
  end
end
