# frozen_string_literal: true

RSpec.describe Legion::Extensions::NarrativeIdentity::Helpers::Constants do
  describe 'limits' do
    it 'defines MAX_EPISODES' do
      expect(described_class::MAX_EPISODES).to eq(500)
    end

    it 'defines MAX_THEMES' do
      expect(described_class::MAX_THEMES).to eq(50)
    end

    it 'defines MAX_CHAPTERS' do
      expect(described_class::MAX_CHAPTERS).to eq(20)
    end
  end

  describe 'episode types' do
    it 'includes expected types' do
      expect(described_class::EPISODE_TYPES).to include(:achievement, :failure, :discovery,
                                                        :relationship, :challenge, :transformation, :routine)
    end

    it 'is frozen' do
      expect(described_class::EPISODE_TYPES).to be_frozen
    end
  end

  describe 'theme types' do
    it 'includes expected types' do
      expect(described_class::THEME_TYPES).to include(:growth, :agency, :communion, :redemption,
                                                      :contamination, :stability, :exploration)
    end

    it 'is frozen' do
      expect(described_class::THEME_TYPES).to be_frozen
    end
  end

  describe 'weights' do
    it 'sums to 1.0' do
      total = described_class::EMOTIONAL_VALENCE_WEIGHT +
              described_class::SIGNIFICANCE_WEIGHT +
              described_class::RECENCY_WEIGHT
      expect(total).to be_within(0.001).of(1.0)
    end
  end

  describe 'CHAPTER_LABELS' do
    it 'defines origin through current' do
      expect(described_class::CHAPTER_LABELS).to eq(%i[origin early_learning growth mastery current])
    end
  end

  describe 'SIGNIFICANCE_LABELS' do
    it 'maps 0.9 to defining' do
      entry = described_class::SIGNIFICANCE_LABELS.find { |e| e.first[0].cover?(0.9) }
      expect(entry.first[1]).to eq(:defining)
    end

    it 'maps 0.5 to notable' do
      entry = described_class::SIGNIFICANCE_LABELS.find { |e| e.first[0].cover?(0.5) }
      expect(entry.first[1]).to eq(:notable)
    end

    it 'maps 0.05 to trivial' do
      entry = described_class::SIGNIFICANCE_LABELS.find { |e| e.first[0].cover?(0.05) }
      expect(entry.first[1]).to eq(:trivial)
    end
  end

  describe 'COHERENCE_LABELS' do
    it 'maps 0.9 to unified' do
      entry = described_class::COHERENCE_LABELS.find { |e| e.first[0].cover?(0.9) }
      expect(entry.first[1]).to eq(:unified)
    end

    it 'maps 0.1 to absent' do
      entry = described_class::COHERENCE_LABELS.find { |e| e.first[0].cover?(0.1) }
      expect(entry.first[1]).to eq(:absent)
    end
  end
end
