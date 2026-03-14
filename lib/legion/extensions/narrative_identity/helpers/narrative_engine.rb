# frozen_string_literal: true

module Legion
  module Extensions
    module NarrativeIdentity
      module Helpers
        class NarrativeEngine
          attr_reader :episodes, :themes, :chapters

          def initialize
            @episodes = {}
            @themes   = {}
            @chapters = {}
          end

          def add_episode(content:, episode_type:, emotional_valence:, significance:, domain:)
            prune_episodes! if @episodes.size >= Constants::MAX_EPISODES
            episode = Episode.new(
              content:           content,
              episode_type:      episode_type,
              emotional_valence: emotional_valence,
              significance:      significance,
              domain:            domain
            )
            @episodes[episode.id] = episode
            episode
          end

          def assign_to_chapter(episode_id:, chapter_id:)
            episode = @episodes.fetch(episode_id, nil)
            chapter = @chapters.fetch(chapter_id, nil)
            return false unless episode && chapter

            episode.chapter_id = chapter_id
            chapter.episode_ids << episode_id unless chapter.episode_ids.include?(episode_id)
            true
          end

          def create_chapter(title:, label:)
            prune_chapters! if @chapters.size >= Constants::MAX_CHAPTERS
            chapter = Chapter.new(title: title, label: label)
            @chapters[chapter.id] = chapter
            chapter
          end

          def close_chapter(chapter_id:)
            chapter = @chapters.fetch(chapter_id, nil)
            return false unless chapter

            chapter.end_time = Time.now.utc
            true
          end

          def add_theme(name:, theme_type:)
            prune_themes! if @themes.size >= Constants::MAX_THEMES
            theme = Theme.new(name: name, theme_type: theme_type)
            @themes[theme.id] = theme
            theme
          end

          def link_theme(episode_id:, theme_id:)
            episode = @episodes.fetch(episode_id, nil)
            theme   = @themes.fetch(theme_id, nil)
            return false unless episode && theme

            episode.themes << theme_id unless episode.themes.include?(theme_id)
            theme.episode_ids << episode_id unless theme.episode_ids.include?(episode_id)
            true
          end

          def reinforce_theme(theme_id:, amount:)
            theme = @themes.fetch(theme_id, nil)
            return false unless theme

            theme.reinforce!(amount)
            true
          end

          def narrative_coherence
            return 0.0 if @episodes.empty? || @themes.empty?

            linked       = @episodes.values.count { |ep| ep.themes.any? }
            base         = (linked.to_f / @episodes.size).round(10)
            theme_factor = prominent_themes.size.to_f / [@themes.size, 1].max
            ((base * 0.7) + (theme_factor * 0.3)).round(10).clamp(0.0, 1.0)
          end

          def identity_summary
            {
              top_themes:        prominent_themes.first(5).map(&:to_h),
              defining_episodes: most_defining_episodes(limit: 5).map(&:to_h),
              current_chapter:   current_chapter&.to_h,
              coherence:         narrative_coherence,
              coherence_label:   coherence_label,
              episode_count:     @episodes.size,
              theme_count:       @themes.size,
              chapter_count:     @chapters.size
            }
          end

          def life_story
            @chapters.values.sort_by(&:start_time).map do |chapter|
              eps = chapter.episode_ids.filter_map { |id| @episodes[id] }.sort_by(&:created_at)
              {
                chapter:  chapter.to_h,
                episodes: eps.map { |ep| ep.to_h.merge(theme_names: theme_names_for(ep)) }
              }
            end
          end

          def most_defining_episodes(limit: 5)
            @episodes.values.sort_by { |ep| -ep.significance }.first(limit)
          end

          def prominent_themes
            @themes.values.select(&:prominent?).sort_by { |t| -t.strength }
          end

          def current_chapter
            @chapters.values.find(&:current?)
          end

          def decay_all_themes!
            @themes.each_value(&:decay!)
          end

          def narrative_report
            {
              identity_summary: identity_summary,
              life_story:       life_story,
              narrative_state:  {
                coherence:         narrative_coherence,
                coherence_label:   coherence_label,
                prominent_themes:  prominent_themes.map(&:to_h),
                defining_episodes: most_defining_episodes(limit: 3).map(&:to_h),
                current_chapter:   current_chapter&.to_h
              }
            }
          end

          def to_h
            {
              episodes: @episodes.transform_values(&:to_h),
              themes:   @themes.transform_values(&:to_h),
              chapters: @chapters.transform_values(&:to_h)
            }
          end

          private

          def coherence_label
            score = narrative_coherence
            Constants::COHERENCE_LABELS.each do |entry|
              range, label = entry.first
              return label if range.cover?(score)
            end
            :absent
          end

          def theme_names_for(episode)
            episode.themes.filter_map { |tid| @themes[tid]&.name }
          end

          def prune_episodes!
            oldest = @episodes.values.min_by(&:created_at)
            @episodes.delete(oldest.id) if oldest
          end

          def prune_themes!
            weakest = @themes.values.min_by(&:strength)
            @themes.delete(weakest.id) if weakest
          end

          def prune_chapters!
            closed = @chapters.values.reject(&:current?).min_by(&:start_time)
            target = closed || @chapters.values.min_by(&:start_time)
            @chapters.delete(target.id) if target
          end
        end
      end
    end
  end
end
