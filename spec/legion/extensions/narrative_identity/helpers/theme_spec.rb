# frozen_string_literal: true

RSpec.describe Legion::Extensions::NarrativeIdentity::Helpers::Theme do
  let(:theme) do
    described_class.new(name: 'perseverance', theme_type: :growth, strength: 0.5)
  end

  describe '#initialize' do
    it 'assigns an id' do
      expect(theme.id).to be_a(String)
      expect(theme.id.length).to eq(36)
    end

    it 'assigns name' do
      expect(theme.name).to eq('perseverance')
    end

    it 'assigns theme_type' do
      expect(theme.theme_type).to eq(:growth)
    end

    it 'assigns strength' do
      expect(theme.strength).to eq(0.5)
    end

    it 'initializes episode_ids as empty array' do
      expect(theme.episode_ids).to eq([])
    end

    it 'clamps strength above 1.0' do
      t = described_class.new(name: 'x', theme_type: :agency, strength: 2.0)
      expect(t.strength).to eq(1.0)
    end

    it 'clamps strength below 0.0' do
      t = described_class.new(name: 'x', theme_type: :agency, strength: -0.5)
      expect(t.strength).to eq(0.0)
    end

    it 'accepts an explicit id' do
      t = described_class.new(name: 'x', theme_type: :growth, id: 'my-id')
      expect(t.id).to eq('my-id')
    end
  end

  describe '#reinforce!' do
    it 'increases strength' do
      theme.reinforce!(0.2)
      expect(theme.strength).to eq(0.7)
    end

    it 'clamps at 1.0' do
      theme.reinforce!(0.8)
      expect(theme.strength).to eq(1.0)
    end

    it 'rounds to 10 decimal places' do
      t = described_class.new(name: 'x', theme_type: :growth, strength: 0.1)
      t.reinforce!(0.2)
      expect(t.strength).to be_a(Float)
      expect(t.strength).to be_within(0.0000000001).of(0.3)
    end
  end

  describe '#decay!' do
    it 'decreases strength by COHERENCE_DECAY' do
      decay = Legion::Extensions::NarrativeIdentity::Helpers::Constants::COHERENCE_DECAY
      theme.decay!
      expect(theme.strength).to be_within(0.0001).of(0.5 - decay)
    end

    it 'clamps at 0.0' do
      weak = described_class.new(name: 'x', theme_type: :stability, strength: 0.005)
      weak.decay!
      expect(weak.strength).to eq(0.0)
    end
  end

  describe '#prominent?' do
    it 'returns true when strength >= 0.6' do
      t = described_class.new(name: 'x', theme_type: :agency, strength: 0.6)
      expect(t.prominent?).to be true
    end

    it 'returns false when strength < 0.6' do
      expect(theme.prominent?).to be false
    end

    it 'returns true at exactly 0.6' do
      t = described_class.new(name: 'x', theme_type: :agency, strength: 0.6)
      expect(t.prominent?).to be true
    end
  end

  describe '#to_h' do
    it 'includes all fields' do
      h = theme.to_h
      expect(h).to include(:id, :name, :theme_type, :strength, :episode_ids)
    end

    it 'returns a copy of episode_ids' do
      h = theme.to_h
      h[:episode_ids] << 'injected'
      expect(theme.episode_ids).to be_empty
    end
  end
end
