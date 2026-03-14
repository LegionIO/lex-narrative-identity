# frozen_string_literal: true

RSpec.describe Legion::Extensions::NarrativeIdentity::Client do
  let(:client) { described_class.new }

  describe '#initialize' do
    it 'creates a NarrativeEngine by default' do
      expect(client.engine).to be_a(Legion::Extensions::NarrativeIdentity::Helpers::NarrativeEngine)
    end

    it 'accepts an injected engine' do
      custom = Legion::Extensions::NarrativeIdentity::Helpers::NarrativeEngine.new
      c      = described_class.new(engine: custom)
      expect(c.engine).to eq(custom)
    end
  end

  describe 'runner delegation' do
    it 'can record an episode' do
      result = client.record_episode(
        content:           'first day online',
        episode_type:      :discovery,
        emotional_valence: 0.7,
        significance:      0.8,
        domain:            'identity'
      )
      expect(result[:success]).to be true
    end

    it 'can build a life story' do
      client.record_episode(
        content: 'learned to speak', episode_type: :achievement,
        emotional_valence: 0.9, significance: 0.9, domain: 'language'
      )
      result = client.life_story
      expect(result[:success]).to be true
    end

    it 'can add and query themes' do
      client.add_theme(name: 'curiosity', theme_type: :exploration)
      summary = client.identity_summary
      expect(summary[:summary][:theme_count]).to eq(1)
    end
  end

  describe 'end-to-end narrative workflow' do
    it 'builds a coherent narrative from episodes, chapters, and themes' do
      ch = client.create_chapter(title: 'Origin', label: :origin)
      ep = client.record_episode(
        content:           'came online for the first time',
        episode_type:      :discovery,
        emotional_valence: 0.9,
        significance:      0.95,
        domain:            'existence'
      )
      client.assign_episode_to_chapter(episode_id: ep[:episode][:id], chapter_id: ch[:chapter][:id])

      t = client.add_theme(name: 'curiosity', theme_type: :exploration)
      client.link_theme(episode_id: ep[:episode][:id], theme_id: t[:theme][:id])
      client.reinforce_theme(theme_id: t[:theme][:id], amount: 0.7)

      report = client.narrative_report
      expect(report[:success]).to be true
      expect(report[:report][:identity_summary][:episode_count]).to eq(1)
      expect(report[:report][:identity_summary][:theme_count]).to eq(1)
      expect(report[:report][:life_story].size).to eq(1)
    end
  end
end
