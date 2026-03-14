# frozen_string_literal: true

RSpec.describe Legion::Extensions::NarrativeIdentity::Helpers::NarrativeEngine do
  let(:engine) { described_class.new }

  def add_ep(content: 'test event', type: :achievement, valence: 0.5, sig: 0.5, domain: 'test')
    engine.add_episode(
      content:           content,
      episode_type:      type,
      emotional_valence: valence,
      significance:      sig,
      domain:            domain
    )
  end

  describe '#add_episode' do
    it 'creates and stores an episode' do
      ep = add_ep
      expect(engine.episodes[ep.id]).to eq(ep)
    end

    it 'returns an Episode object' do
      expect(add_ep).to be_a(Legion::Extensions::NarrativeIdentity::Helpers::Episode)
    end

    it 'increments episode count' do
      3.times { add_ep }
      expect(engine.episodes.size).to eq(3)
    end

    it 'prunes oldest episode when MAX_EPISODES reached' do
      max = Legion::Extensions::NarrativeIdentity::Helpers::Constants::MAX_EPISODES
      first_ep = add_ep(content: 'oldest')
      (max - 1).times { |i| add_ep(content: "ep #{i}") }
      expect(engine.episodes.size).to eq(max)
      add_ep(content: 'newest overflow')
      expect(engine.episodes.size).to eq(max)
      expect(engine.episodes.key?(first_ep.id)).to be false
    end
  end

  describe '#create_chapter' do
    it 'creates and stores a chapter' do
      ch = engine.create_chapter(title: 'Act One', label: :origin)
      expect(engine.chapters[ch.id]).to eq(ch)
    end

    it 'returns a Chapter object' do
      expect(engine.create_chapter(title: 'x', label: :growth)).to be_a(
        Legion::Extensions::NarrativeIdentity::Helpers::Chapter
      )
    end
  end

  describe '#assign_to_chapter' do
    it 'assigns episode to chapter bidirectionally' do
      ep = add_ep
      ch = engine.create_chapter(title: 'Act One', label: :origin)
      result = engine.assign_to_chapter(episode_id: ep.id, chapter_id: ch.id)
      expect(result).to be true
      expect(ep.chapter_id).to eq(ch.id)
      expect(ch.episode_ids).to include(ep.id)
    end

    it 'returns false for unknown episode' do
      ch = engine.create_chapter(title: 'x', label: :current)
      expect(engine.assign_to_chapter(episode_id: 'no-such', chapter_id: ch.id)).to be false
    end

    it 'returns false for unknown chapter' do
      ep = add_ep
      expect(engine.assign_to_chapter(episode_id: ep.id, chapter_id: 'no-such')).to be false
    end

    it 'does not duplicate episode_id in chapter' do
      ep = add_ep
      ch = engine.create_chapter(title: 'x', label: :current)
      engine.assign_to_chapter(episode_id: ep.id, chapter_id: ch.id)
      engine.assign_to_chapter(episode_id: ep.id, chapter_id: ch.id)
      expect(ch.episode_ids.count(ep.id)).to eq(1)
    end
  end

  describe '#close_chapter' do
    it 'sets end_time on the chapter' do
      ch = engine.create_chapter(title: 'x', label: :growth)
      expect(ch.current?).to be true
      result = engine.close_chapter(chapter_id: ch.id)
      expect(result).to be true
      expect(ch.current?).to be false
      expect(ch.end_time).to be_a(Time)
    end

    it 'returns false for unknown chapter' do
      expect(engine.close_chapter(chapter_id: 'missing')).to be false
    end
  end

  describe '#add_theme' do
    it 'creates and stores a theme' do
      t = engine.add_theme(name: 'resilience', theme_type: :growth)
      expect(engine.themes[t.id]).to eq(t)
    end

    it 'returns a Theme object' do
      expect(engine.add_theme(name: 'x', theme_type: :agency)).to be_a(
        Legion::Extensions::NarrativeIdentity::Helpers::Theme
      )
    end
  end

  describe '#link_theme' do
    it 'links theme to episode bidirectionally' do
      ep = add_ep
      t  = engine.add_theme(name: 'growth', theme_type: :growth)
      result = engine.link_theme(episode_id: ep.id, theme_id: t.id)
      expect(result).to be true
      expect(ep.themes).to include(t.id)
      expect(t.episode_ids).to include(ep.id)
    end

    it 'returns false for unknown episode' do
      t = engine.add_theme(name: 'x', theme_type: :agency)
      expect(engine.link_theme(episode_id: 'no-ep', theme_id: t.id)).to be false
    end

    it 'returns false for unknown theme' do
      ep = add_ep
      expect(engine.link_theme(episode_id: ep.id, theme_id: 'no-theme')).to be false
    end

    it 'does not duplicate theme_id on episode' do
      ep = add_ep
      t  = engine.add_theme(name: 'x', theme_type: :growth)
      engine.link_theme(episode_id: ep.id, theme_id: t.id)
      engine.link_theme(episode_id: ep.id, theme_id: t.id)
      expect(ep.themes.count(t.id)).to eq(1)
    end
  end

  describe '#reinforce_theme' do
    it 'increases theme strength' do
      t = engine.add_theme(name: 'courage', theme_type: :agency)
      expect { engine.reinforce_theme(theme_id: t.id, amount: 0.3) }
        .to change { t.strength }.by(0.3)
    end

    it 'returns false for unknown theme' do
      expect(engine.reinforce_theme(theme_id: 'ghost', amount: 0.1)).to be false
    end
  end

  describe '#narrative_coherence' do
    it 'returns 0.0 with no episodes' do
      expect(engine.narrative_coherence).to eq(0.0)
    end

    it 'returns 0.0 with no themes' do
      add_ep
      expect(engine.narrative_coherence).to eq(0.0)
    end

    it 'returns > 0 when episodes are linked to themes' do
      ep = add_ep
      t  = engine.add_theme(name: 'x', theme_type: :growth)
      engine.link_theme(episode_id: ep.id, theme_id: t.id)
      engine.reinforce_theme(theme_id: t.id, amount: 0.7)
      expect(engine.narrative_coherence).to be > 0.0
    end

    it 'returns a value between 0 and 1' do
      5.times do
        ep = add_ep
        t  = engine.add_theme(name: "theme #{ep.id}", theme_type: :growth)
        engine.link_theme(episode_id: ep.id, theme_id: t.id)
        engine.reinforce_theme(theme_id: t.id, amount: 0.8)
      end
      score = engine.narrative_coherence
      expect(score).to be >= 0.0
      expect(score).to be <= 1.0
    end
  end

  describe '#most_defining_episodes' do
    it 'returns episodes sorted by significance descending' do
      add_ep(sig: 0.3)
      add_ep(sig: 0.9)
      add_ep(sig: 0.5)
      result = engine.most_defining_episodes(limit: 3)
      sigs   = result.map(&:significance)
      expect(sigs).to eq(sigs.sort.reverse)
    end

    it 'respects limit' do
      5.times { add_ep(sig: rand) }
      expect(engine.most_defining_episodes(limit: 3).size).to eq(3)
    end

    it 'returns fewer than limit when not enough episodes' do
      2.times { add_ep }
      expect(engine.most_defining_episodes(limit: 5).size).to eq(2)
    end
  end

  describe '#prominent_themes' do
    it 'returns only themes with strength >= 0.6' do
      strong = engine.add_theme(name: 'strong', theme_type: :agency)
      engine.reinforce_theme(theme_id: strong.id, amount: 0.7)
      weak = engine.add_theme(name: 'weak', theme_type: :stability)
      engine.reinforce_theme(theme_id: weak.id, amount: 0.3)
      result = engine.prominent_themes
      expect(result.map(&:id)).to include(strong.id)
      expect(result.map(&:id)).not_to include(weak.id)
    end

    it 'returns empty array when no prominent themes' do
      engine.add_theme(name: 'faint', theme_type: :stability)
      expect(engine.prominent_themes).to eq([])
    end
  end

  describe '#current_chapter' do
    it 'returns nil when no chapters exist' do
      expect(engine.current_chapter).to be_nil
    end

    it 'returns the chapter with no end_time' do
      ch1 = engine.create_chapter(title: 'Past', label: :origin)
      engine.close_chapter(chapter_id: ch1.id)
      ch2 = engine.create_chapter(title: 'Now', label: :current)
      expect(engine.current_chapter).to eq(ch2)
    end
  end

  describe '#decay_all_themes!' do
    it 'reduces strength on all themes' do
      t1 = engine.add_theme(name: 'a', theme_type: :growth)
      engine.reinforce_theme(theme_id: t1.id, amount: 0.5)
      t2 = engine.add_theme(name: 'b', theme_type: :agency)
      engine.reinforce_theme(theme_id: t2.id, amount: 0.8)
      s1_before = t1.strength
      s2_before = t2.strength
      engine.decay_all_themes!
      decay = Legion::Extensions::NarrativeIdentity::Helpers::Constants::COHERENCE_DECAY
      expect(t1.strength).to be_within(0.001).of(s1_before - decay)
      expect(t2.strength).to be_within(0.001).of(s2_before - decay)
    end
  end

  describe '#identity_summary' do
    it 'returns expected keys' do
      summary = engine.identity_summary
      expect(summary).to include(
        :top_themes, :defining_episodes, :current_chapter,
        :coherence, :coherence_label, :episode_count, :theme_count, :chapter_count
      )
    end

    it 'coherence_label is a symbol' do
      expect(engine.identity_summary[:coherence_label]).to be_a(Symbol)
    end

    it 'reflects episode count' do
      3.times { add_ep }
      expect(engine.identity_summary[:episode_count]).to eq(3)
    end
  end

  describe '#life_story' do
    it 'returns an array of chapter entries' do
      ch = engine.create_chapter(title: 'Act I', label: :origin)
      ep = add_ep
      engine.assign_to_chapter(episode_id: ep.id, chapter_id: ch.id)
      story = engine.life_story
      expect(story).to be_an(Array)
      expect(story.first[:chapter][:id]).to eq(ch.id)
      expect(story.first[:episodes].map { |e| e[:id] }).to include(ep.id)
    end

    it 'returns empty array when no chapters' do
      expect(engine.life_story).to eq([])
    end
  end

  describe '#narrative_report' do
    it 'returns expected top-level keys' do
      report = engine.narrative_report
      expect(report).to include(:identity_summary, :life_story, :narrative_state)
    end

    it 'narrative_state includes coherence' do
      expect(engine.narrative_report[:narrative_state]).to include(:coherence, :coherence_label)
    end
  end

  describe '#to_h' do
    it 'serializes episodes, themes, and chapters' do
      add_ep
      engine.add_theme(name: 't', theme_type: :growth)
      engine.create_chapter(title: 'ch', label: :current)
      h = engine.to_h
      expect(h[:episodes].size).to eq(1)
      expect(h[:themes].size).to eq(1)
      expect(h[:chapters].size).to eq(1)
    end
  end
end
