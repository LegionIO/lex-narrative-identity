# frozen_string_literal: true

RSpec.describe Legion::Extensions::NarrativeIdentity::Helpers::Chapter do
  let(:chapter) do
    described_class.new(title: 'The Beginning', label: :origin)
  end

  describe '#initialize' do
    it 'assigns an id' do
      expect(chapter.id).to be_a(String)
      expect(chapter.id.length).to eq(36)
    end

    it 'assigns title' do
      expect(chapter.title).to eq('The Beginning')
    end

    it 'assigns label' do
      expect(chapter.label).to eq(:origin)
    end

    it 'initializes episode_ids as empty array' do
      expect(chapter.episode_ids).to eq([])
    end

    it 'sets start_time to current time' do
      expect(chapter.start_time).to be_a(Time)
    end

    it 'sets end_time to nil by default' do
      expect(chapter.end_time).to be_nil
    end

    it 'accepts an explicit id' do
      c = described_class.new(title: 't', label: :current, id: 'my-chap')
      expect(c.id).to eq('my-chap')
    end

    it 'accepts explicit start_time' do
      t = Time.now.utc - 3600
      c = described_class.new(title: 'x', label: :growth, start_time: t)
      expect(c.start_time).to eq(t)
    end
  end

  describe '#current?' do
    it 'returns true when end_time is nil' do
      expect(chapter.current?).to be true
    end

    it 'returns false when end_time is set' do
      chapter.end_time = Time.now.utc
      expect(chapter.current?).to be false
    end
  end

  describe '#episode_count' do
    it 'returns 0 for new chapter' do
      expect(chapter.episode_count).to eq(0)
    end

    it 'reflects episode_ids size' do
      chapter.episode_ids << 'ep-1'
      chapter.episode_ids << 'ep-2'
      expect(chapter.episode_count).to eq(2)
    end
  end

  describe '#to_h' do
    it 'includes all fields' do
      h = chapter.to_h
      expect(h).to include(:id, :title, :label, :episode_ids, :start_time, :end_time)
    end

    it 'returns nil for end_time when chapter is open' do
      expect(chapter.to_h[:end_time]).to be_nil
    end

    it 'returns a copy of episode_ids' do
      h = chapter.to_h
      h[:episode_ids] << 'injected'
      expect(chapter.episode_ids).to be_empty
    end
  end
end
