# frozen_string_literal: true

module Legion
  module Extensions
    module NarrativeIdentity
      module Runners
        module NarrativeIdentity
          extend self

          def record_episode(content:, episode_type:, emotional_valence:, significance:, domain:,
                             engine: nil, **)
            return { success: false, error: "unknown episode_type: #{episode_type.inspect}" } unless
              Helpers::Constants::EPISODE_TYPES.include?(episode_type)

            episode = resolve_engine(engine).add_episode(
              content: content, episode_type: episode_type,
              emotional_valence: emotional_valence, significance: significance, domain: domain
            )
            Legion::Logging.debug "[narrative_identity] recorded episode #{episode.id[0..7]} type=#{episode_type}"
            { success: true, episode: episode.to_h }
          rescue StandardError => e
            { success: false, error: e.message }
          end

          def assign_episode_to_chapter(episode_id:, chapter_id:, engine: nil, **)
            result = resolve_engine(engine).assign_to_chapter(episode_id: episode_id, chapter_id: chapter_id)
            Legion::Logging.debug "[narrative_identity] assign episode=#{episode_id[0..7]} ok=#{result}"
            { success: result, episode_id: episode_id, chapter_id: chapter_id }
          rescue StandardError => e
            { success: false, error: e.message }
          end

          def create_chapter(title:, label:, engine: nil, **)
            return { success: false, error: "unknown chapter label: #{label.inspect}" } unless
              Helpers::Constants::CHAPTER_LABELS.include?(label)

            chapter = resolve_engine(engine).create_chapter(title: title, label: label)
            Legion::Logging.debug "[narrative_identity] created chapter #{chapter.id[0..7]} label=#{label}"
            { success: true, chapter: chapter.to_h }
          rescue StandardError => e
            { success: false, error: e.message }
          end

          def close_chapter(chapter_id:, engine: nil, **)
            result = resolve_engine(engine).close_chapter(chapter_id: chapter_id)
            Legion::Logging.debug "[narrative_identity] close_chapter #{chapter_id[0..7]} ok=#{result}"
            { success: result, chapter_id: chapter_id }
          rescue StandardError => e
            { success: false, error: e.message }
          end

          def add_theme(name:, theme_type:, engine: nil, **)
            return { success: false, error: "unknown theme_type: #{theme_type.inspect}" } unless
              Helpers::Constants::THEME_TYPES.include?(theme_type)

            theme = resolve_engine(engine).add_theme(name: name, theme_type: theme_type)
            Legion::Logging.debug "[narrative_identity] added theme #{theme.id[0..7]} type=#{theme_type}"
            { success: true, theme: theme.to_h }
          rescue StandardError => e
            { success: false, error: e.message }
          end

          def link_theme(episode_id:, theme_id:, engine: nil, **)
            result = resolve_engine(engine).link_theme(episode_id: episode_id, theme_id: theme_id)
            Legion::Logging.debug "[narrative_identity] link theme=#{theme_id[0..7]} episode=#{episode_id[0..7]} ok=#{result}"
            { success: result, episode_id: episode_id, theme_id: theme_id }
          rescue StandardError => e
            { success: false, error: e.message }
          end

          def reinforce_theme(theme_id:, amount:, engine: nil, **)
            result = resolve_engine(engine).reinforce_theme(theme_id: theme_id, amount: amount)
            Legion::Logging.debug "[narrative_identity] reinforce theme=#{theme_id[0..7]} amount=#{amount} ok=#{result}"
            { success: result, theme_id: theme_id, amount: amount }
          rescue StandardError => e
            { success: false, error: e.message }
          end

          def narrative_coherence(engine: nil, **)
            score = resolve_engine(engine).narrative_coherence
            Legion::Logging.debug "[narrative_identity] coherence=#{score}"
            { success: true, coherence: score }
          rescue StandardError => e
            { success: false, error: e.message }
          end

          def identity_summary(engine: nil, **)
            summary = resolve_engine(engine).identity_summary
            Legion::Logging.debug '[narrative_identity] identity_summary requested'
            { success: true, summary: summary }
          rescue StandardError => e
            { success: false, error: e.message }
          end

          def life_story(engine: nil, **)
            story = resolve_engine(engine).life_story
            Legion::Logging.debug "[narrative_identity] life_story chapters=#{story.size}"
            { success: true, life_story: story }
          rescue StandardError => e
            { success: false, error: e.message }
          end

          def most_defining_episodes(limit: 5, engine: nil, **)
            episodes = resolve_engine(engine).most_defining_episodes(limit: limit)
            Legion::Logging.debug "[narrative_identity] defining_episodes count=#{episodes.size}"
            { success: true, episodes: episodes.map(&:to_h) }
          rescue StandardError => e
            { success: false, error: e.message }
          end

          def prominent_themes(engine: nil, **)
            themes = resolve_engine(engine).prominent_themes
            Legion::Logging.debug "[narrative_identity] prominent_themes count=#{themes.size}"
            { success: true, themes: themes.map(&:to_h) }
          rescue StandardError => e
            { success: false, error: e.message }
          end

          def current_chapter(engine: nil, **)
            chapter = resolve_engine(engine).current_chapter
            Legion::Logging.debug "[narrative_identity] current_chapter=#{chapter&.id&.slice(0..7)}"
            { success: true, chapter: chapter&.to_h }
          rescue StandardError => e
            { success: false, error: e.message }
          end

          def decay_themes(engine: nil, **)
            resolve_engine(engine).decay_all_themes!
            Legion::Logging.debug '[narrative_identity] theme decay applied'
            { success: true }
          rescue StandardError => e
            { success: false, error: e.message }
          end

          def narrative_report(engine: nil, **)
            report = resolve_engine(engine).narrative_report
            Legion::Logging.debug '[narrative_identity] narrative_report generated'
            { success: true, report: report }
          rescue StandardError => e
            { success: false, error: e.message }
          end

          include Legion::Extensions::Helpers::Lex if defined?(Legion::Extensions::Helpers::Lex)

          private

          def resolve_engine(engine)
            engine || (@default_engine ||= Helpers::NarrativeEngine.new)
          end
        end
      end
    end
  end
end
