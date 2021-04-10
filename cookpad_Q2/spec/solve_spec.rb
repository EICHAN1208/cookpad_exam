require './lib/solve'

RSpec.describe 'CLI' do
  describe 'CLI' do
    subject { CLI.listen }

    before do
      allow(BattleField).to receive(:play).and_return(nil)
    end

    it 'playメソッドが呼ばれる' do
      subject
      expect(BattleField).to have_received(:play)
    end
  end

  describe 'BatleField' do
    subject { BattleField.play(monsters) }

    let(:names) { %w[griffin vampire dragon troll medusa] }
    let(:monsters) { names.map { |name| Monster.new(name, 0) } }

    it '強い順にならぶ' do
      expect(subject).to eq %w[troll dragon medusa griffin vampire]
    end
  end
end
