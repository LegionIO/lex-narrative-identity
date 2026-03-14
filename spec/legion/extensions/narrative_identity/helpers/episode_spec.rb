# frozen_string_literal: true

RSpec.describe Legion::Extensions::NarrativeIdentity::Helpers::Episode do
  let(:episode) do
    described_class.new(
      content:           'Solved the routing bug after two days of debugging',
      episode_type:      :achievement,
      emotional_valence: 0.8,
      significance:      0.75,
      domain:            'engineering'
    )
  end

  describe '#initialize' do
    it 'assigns an id' do
      expect(episode.id).to be_a(String)
      expect(episode.id.length).to eq(36)
    end

    it 'assigns content' do
      expect(episode.content).to eq('Solved the routing bug after two days of debugging')
    end

    it 'assigns episode_type' do
      expect(episode.episode_type).to eq(:achievement)
    end

    it 'assigns emotional_valence' do
      expect(episode.emotional_valence).to eq(0.8)
    end

    it 'assigns significance' do
      expect(episode.significance).to eq(0.75)
    end

    it 'assigns domain' do
      expect(episode.domain).to eq('engineering')
    end

    it 'sets chapter_id to nil by default' do
      expect(episode.chapter_id).to be_nil
    end

    it 'initializes themes as empty array' do
      expect(episode.themes).to eq([])
    end

    it 'sets created_at to current time' do
      expect(episode.created_at).to be_a(Time)
    end

    it 'generates a unique UUID id per instance' do
      ep1 = described_class.new(content: 'a', episode_type: :routine, emotional_valence: 0.0, significance: 0.1, domain: 'd')
      ep2 = described_class.new(content: 'b', episode_type: :routine, emotional_valence: 0.0, significance: 0.1, domain: 'd')
      expect(ep1.id).not_to eq(ep2.id)
    end

    it 'clamps emotional_valence above 1.0' do
      ep = described_class.new(
        content: 'x', episode_type: :routine, emotional_valence: 2.5, significance: 0.5, domain: 'd'
      )
      expect(ep.emotional_valence).to eq(1.0)
    end

    it 'clamps emotional_valence below -1.0' do
      ep = described_class.new(
        content: 'x', episode_type: :failure, emotional_valence: -3.0, significance: 0.5, domain: 'd'
      )
      expect(ep.emotional_valence).to eq(-1.0)
    end

    it 'clamps significance above 1.0' do
      ep = described_class.new(
        content: 'x', episode_type: :achievement, emotional_valence: 0.5, significance: 1.5, domain: 'd'
      )
      expect(ep.significance).to eq(1.0)
    end

    it 'clamps significance below 0.0' do
      ep = described_class.new(
        content: 'x', episode_type: :routine, emotional_valence: 0.0, significance: -0.3, domain: 'd'
      )
      expect(ep.significance).to eq(0.0)
    end
  end

  describe '#positive?' do
    it 'returns true when valence > 0' do
      expect(episode.positive?).to be true
    end

    it 'returns false when valence <= 0' do
      neg = described_class.new(
        content: 'bad day', episode_type: :failure, emotional_valence: -0.5, significance: 0.5, domain: 'd'
      )
      expect(neg.positive?).to be false
    end
  end

  describe '#negative?' do
    it 'returns true when valence < 0' do
      neg = described_class.new(
        content: 'bad day', episode_type: :failure, emotional_valence: -0.3, significance: 0.4, domain: 'd'
      )
      expect(neg.negative?).to be true
    end

    it 'returns false when valence >= 0' do
      expect(episode.negative?).to be false
    end
  end

  describe '#defining?' do
    it 'returns true when significance >= 0.8' do
      high = described_class.new(
        content: 'life changing', episode_type: :transformation,
        emotional_valence: 0.9, significance: 0.9, domain: 'd'
      )
      expect(high.defining?).to be true
    end

    it 'returns false when significance < 0.8' do
      expect(episode.defining?).to be false
    end

    it 'returns true at exactly 0.8' do
      ep = described_class.new(
        content: 'just defining', episode_type: :achievement,
        emotional_valence: 0.5, significance: 0.8, domain: 'd'
      )
      expect(ep.defining?).to be true
    end
  end

  describe '#significance_label' do
    it 'returns :defining for significance >= 0.8' do
      ep = described_class.new(content: 'x', episode_type: :achievement,
                               emotional_valence: 0.5, significance: 0.9, domain: 'd')
      expect(ep.significance_label).to eq(:defining)
    end

    it 'returns :major for 0.6..0.79' do
      ep = described_class.new(content: 'x', episode_type: :achievement,
                               emotional_valence: 0.5, significance: 0.7, domain: 'd')
      expect(ep.significance_label).to eq(:major)
    end

    it 'returns :notable for 0.4..0.59' do
      ep = described_class.new(content: 'x', episode_type: :discovery,
                               emotional_valence: 0.0, significance: 0.5, domain: 'd')
      expect(ep.significance_label).to eq(:notable)
    end

    it 'returns :minor for 0.2..0.39' do
      ep = described_class.new(content: 'x', episode_type: :routine,
                               emotional_valence: 0.0, significance: 0.3, domain: 'd')
      expect(ep.significance_label).to eq(:minor)
    end

    it 'returns :trivial for significance < 0.2' do
      ep = described_class.new(content: 'x', episode_type: :routine,
                               emotional_valence: 0.0, significance: 0.1, domain: 'd')
      expect(ep.significance_label).to eq(:trivial)
    end
  end

  describe '#to_h' do
    it 'includes all fields' do
      h = episode.to_h
      expect(h).to include(:id, :content, :episode_type, :emotional_valence,
                           :significance, :domain, :chapter_id, :themes, :created_at)
    end

    it 'returns a copy of themes array' do
      h = episode.to_h
      h[:themes] << 'injected'
      expect(episode.themes).to be_empty
    end
  end
end
