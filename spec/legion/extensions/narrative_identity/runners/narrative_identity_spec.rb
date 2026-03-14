# frozen_string_literal: true

RSpec.describe Legion::Extensions::NarrativeIdentity::Runners::NarrativeIdentity do
  let(:engine) { Legion::Extensions::NarrativeIdentity::Helpers::NarrativeEngine.new }
  let(:runner) { Object.new.extend(described_class) }

  def record(content: 'did a thing', type: :achievement, valence: 0.5, sig: 0.6, domain: 'test')
    runner.record_episode(
      content:           content,
      episode_type:      type,
      emotional_valence: valence,
      significance:      sig,
      domain:            domain,
      engine:            engine
    )
  end

  describe '#record_episode' do
    it 'returns success: true' do
      expect(record[:success]).to be true
    end

    it 'returns episode hash' do
      result = record
      expect(result[:episode]).to include(:id, :content, :episode_type, :significance)
    end

    it 'rejects unknown episode_type' do
      result = runner.record_episode(
        content: 'x', episode_type: :bogus, emotional_valence: 0.0, significance: 0.5,
        domain: 'd', engine: engine
      )
      expect(result[:success]).to be false
      expect(result[:error]).to include('unknown episode_type')
    end

    it 'stores the episode in the engine' do
      result = record
      expect(engine.episodes.key?(result[:episode][:id])).to be true
    end
  end

  describe '#create_chapter' do
    it 'returns success: true' do
      result = runner.create_chapter(title: 'Act I', label: :origin, engine: engine)
      expect(result[:success]).to be true
    end

    it 'returns chapter hash' do
      result = runner.create_chapter(title: 'Act I', label: :growth, engine: engine)
      expect(result[:chapter]).to include(:id, :title, :label)
    end

    it 'rejects unknown label' do
      result = runner.create_chapter(title: 'bad', label: :invalid, engine: engine)
      expect(result[:success]).to be false
      expect(result[:error]).to include('unknown chapter label')
    end
  end

  describe '#close_chapter' do
    it 'closes an existing chapter' do
      created = runner.create_chapter(title: 'Past', label: :origin, engine: engine)
      ch_id   = created[:chapter][:id]
      result  = runner.close_chapter(chapter_id: ch_id, engine: engine)
      expect(result[:success]).to be true
    end

    it 'returns false for nonexistent chapter' do
      result = runner.close_chapter(chapter_id: 'ghost-id', engine: engine)
      expect(result[:success]).to be false
    end
  end

  describe '#assign_episode_to_chapter' do
    it 'links episode to chapter' do
      ep  = record
      ch  = runner.create_chapter(title: 'Now', label: :current, engine: engine)
      res = runner.assign_episode_to_chapter(
        episode_id: ep[:episode][:id],
        chapter_id: ch[:chapter][:id],
        engine:     engine
      )
      expect(res[:success]).to be true
    end

    it 'returns false for unknown IDs' do
      res = runner.assign_episode_to_chapter(
        episode_id: 'no-ep', chapter_id: 'no-ch', engine: engine
      )
      expect(res[:success]).to be false
    end
  end

  describe '#add_theme' do
    it 'returns success: true' do
      result = runner.add_theme(name: 'courage', theme_type: :growth, engine: engine)
      expect(result[:success]).to be true
    end

    it 'returns theme hash' do
      result = runner.add_theme(name: 'resilience', theme_type: :agency, engine: engine)
      expect(result[:theme]).to include(:id, :name, :theme_type)
    end

    it 'rejects unknown theme_type' do
      result = runner.add_theme(name: 'x', theme_type: :nonsense, engine: engine)
      expect(result[:success]).to be false
      expect(result[:error]).to include('unknown theme_type')
    end
  end

  describe '#link_theme' do
    it 'links theme and episode' do
      ep = record
      t  = runner.add_theme(name: 'growth', theme_type: :growth, engine: engine)
      r  = runner.link_theme(episode_id: ep[:episode][:id], theme_id: t[:theme][:id], engine: engine)
      expect(r[:success]).to be true
    end

    it 'returns false for missing episode or theme' do
      r = runner.link_theme(episode_id: 'no-ep', theme_id: 'no-t', engine: engine)
      expect(r[:success]).to be false
    end
  end

  describe '#reinforce_theme' do
    it 'increases theme strength' do
      t       = runner.add_theme(name: 'x', theme_type: :growth, engine: engine)
      theme   = engine.themes[t[:theme][:id]]
      before  = theme.strength
      runner.reinforce_theme(theme_id: t[:theme][:id], amount: 0.3, engine: engine)
      expect(theme.strength).to be > before
    end

    it 'returns false for unknown theme' do
      r = runner.reinforce_theme(theme_id: 'ghost', amount: 0.1, engine: engine)
      expect(r[:success]).to be false
    end
  end

  describe '#narrative_coherence' do
    it 'returns success: true with coherence value' do
      result = runner.narrative_coherence(engine: engine)
      expect(result[:success]).to be true
      expect(result[:coherence]).to be_a(Float)
    end
  end

  describe '#identity_summary' do
    it 'returns success: true with summary' do
      result = runner.identity_summary(engine: engine)
      expect(result[:success]).to be true
      expect(result[:summary]).to include(:episode_count, :theme_count)
    end
  end

  describe '#life_story' do
    it 'returns success: true with life_story array' do
      result = runner.life_story(engine: engine)
      expect(result[:success]).to be true
      expect(result[:life_story]).to be_an(Array)
    end
  end

  describe '#most_defining_episodes' do
    it 'returns success: true with episodes array' do
      result = runner.most_defining_episodes(limit: 3, engine: engine)
      expect(result[:success]).to be true
      expect(result[:episodes]).to be_an(Array)
    end

    it 'respects the limit' do
      5.times { record }
      result = runner.most_defining_episodes(limit: 3, engine: engine)
      expect(result[:episodes].size).to be <= 3
    end
  end

  describe '#prominent_themes' do
    it 'returns success: true with themes array' do
      result = runner.prominent_themes(engine: engine)
      expect(result[:success]).to be true
      expect(result[:themes]).to be_an(Array)
    end
  end

  describe '#current_chapter' do
    it 'returns success: true' do
      result = runner.current_chapter(engine: engine)
      expect(result[:success]).to be true
    end

    it 'returns nil chapter when none exists' do
      expect(runner.current_chapter(engine: engine)[:chapter]).to be_nil
    end

    it 'returns the open chapter' do
      runner.create_chapter(title: 'Now', label: :current, engine: engine)
      result = runner.current_chapter(engine: engine)
      expect(result[:chapter]).not_to be_nil
    end
  end

  describe '#decay_themes' do
    it 'returns success: true' do
      result = runner.decay_themes(engine: engine)
      expect(result[:success]).to be true
    end

    it 'applies decay to all themes' do
      t = runner.add_theme(name: 'x', theme_type: :growth, engine: engine)
      runner.reinforce_theme(theme_id: t[:theme][:id], amount: 0.5, engine: engine)
      theme  = engine.themes[t[:theme][:id]]
      before = theme.strength
      runner.decay_themes(engine: engine)
      expect(theme.strength).to be < before
    end
  end

  describe '#narrative_report' do
    it 'returns success: true with report' do
      result = runner.narrative_report(engine: engine)
      expect(result[:success]).to be true
      expect(result[:report]).to include(:identity_summary, :life_story, :narrative_state)
    end
  end

  describe 'default engine memoization' do
    it 'uses a shared default engine across calls when no engine injected' do
      r = Object.new.extend(described_class)
      r.record_episode(
        content: 'event', episode_type: :achievement,
        emotional_valence: 0.5, significance: 0.5, domain: 'd'
      )
      summary = r.identity_summary
      expect(summary[:summary][:episode_count]).to eq(1)
    end
  end
end
