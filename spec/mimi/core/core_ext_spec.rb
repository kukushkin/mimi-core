require 'spec_helper'

describe 'Mimi::Core extensions to base classes' do
  context 'Array' do
    subject { Array.new }

    it { is_expected.to respond_to(:only) }
    it { is_expected.to respond_to(:only!) }
    it { is_expected.to respond_to(:except) }
    it { is_expected.to respond_to(:except!) }

    context '#only' do
      let(:sample) { [:a, :b, :c] }
      subject { sample }

      it 'runs without errors' do
        expect { subject.only(:c, :d) }.to_not raise_error
      end

      it 'filters elements' do
        expect(subject.only(:c, :d)).to eq [:c]
      end

      it 'raises ArgumentError if an array is passed instead of list of arguments' do
        expect { subject.only([:c, :d]) }.to raise_error ArgumentError
      end
    end # #only

    context '#only!' do
      let(:sample) { [:a, :b, :c] }
      subject { sample }

      it 'runs without errors' do
        expect { subject.only!(:c, :d) }.to_not raise_error
      end

      it 'filters elements' do
        expect(subject.only!(:c, :d)).to eq [:c]
      end

      it 'modifies the Array in place' do
        expect { subject.only!(:c, :d) }.to change { sample }.to([:c])
      end

      it 'raises ArgumentError if an array is passed instead of list of arguments' do
        expect { subject.only!([:c, :d]) }.to raise_error ArgumentError
      end
    end # #only!

    context '#except' do
      let(:sample) { [:a, :b, :c] }
      subject { sample }

      it 'runs without errors' do
        expect { subject.except(:c, :d) }.to_not raise_error
      end

      it 'filters elements' do
        expect(subject.except(:c, :d)).to eq [:a, :b]
      end

      it 'raises ArgumentError if an array is passed instead of list of arguments' do
        expect { subject.except([:c, :d]) }.to raise_error ArgumentError
      end
    end # #except

    context '#except!' do
      let(:sample) { [:a, :b, :c] }
      subject { sample }

      it 'runs without errors' do
        expect { subject.except!(:c, :d) }.to_not raise_error
      end

      it 'filters elements' do
        expect(subject.except!(:c, :d)).to eq [:a, :b]
      end

      it 'modifies the Array in place' do
        expect { subject.except!(:c, :d) }.to change { sample }.to([:a, :b])
      end

      it 'raises ArgumentError if an array is passed instead of list of arguments' do
        expect { subject.except!([:c, :d]) }.to raise_error ArgumentError
      end
    end # #except!
  end # Array

  context 'Hash' do
    subject { Hash.new }

    it { is_expected.to respond_to(:only) }
    it { is_expected.to respond_to(:only!) }
    it { is_expected.to respond_to(:except) }
    it { is_expected.to respond_to(:except!) }
    it { is_expected.to respond_to(:deep_merge) }
    it { is_expected.to respond_to(:deep_dup) }
    it { is_expected.to respond_to(:symbolize_keys) }
    it { is_expected.to respond_to(:symbolize_keys!) }
    it { is_expected.to respond_to(:stringify_keys) }
    it { is_expected.to respond_to(:stringify_keys!) }
    it { is_expected.to respond_to(:deep_symbolize_keys) }
    it { is_expected.to respond_to(:deep_symbolize_keys!) }
    it { is_expected.to respond_to(:deep_stringify_keys) }
    it { is_expected.to respond_to(:deep_stringify_keys!) }

    context '#only' do
      let(:sample) do
        { a: { aa: 1 }, b: 2, c: 3 }
      end
      subject { sample }

      it 'runs without errors' do
        expect { subject.only(:c, :d) }.to_not raise_error
      end

      it 'filters elements' do
        expect(subject.only(:c, :d)).to eq({ c: 3 })
      end

      it 'raises ArgumentError if an array is passed instead of list of arguments' do
        expect { subject.only([:c, :d]) }.to raise_error ArgumentError
      end
    end # #only

    context '#only!' do
      let(:sample) do
        { a: { aa: 1 }, b: 2, c: 3 }
      end
      subject { sample }

      it 'runs without errors' do
        expect { subject.only!(:c, :d) }.to_not raise_error
      end

      it 'filters elements' do
        expect(subject.only!(:c, :d)).to eq({ c: 3 })
      end

      it 'modifies the Array in place' do
        expect { subject.only!(:c, :d) }.to change { sample }.to({ c: 3 })
      end

      it 'raises ArgumentError if an array is passed instead of list of arguments' do
        expect { subject.only!([:c, :d]) }.to raise_error ArgumentError
      end
    end # #only!

    context '#except' do
      let(:sample) do
        { a: { aa: 1 }, b: 2, c: 3 }
      end
      subject { sample }

      it 'runs without errors' do
        expect { subject.except(:c, :d) }.to_not raise_error
      end

      it 'filters elements' do
        expect(subject.except(:c, :d)).to eq({ a: { aa: 1 }, b: 2})
      end

      it 'raises ArgumentError if an array is passed instead of list of arguments' do
        expect { subject.except([:c, :d]) }.to raise_error ArgumentError
      end
    end # #except

    context '#except!' do
      let(:sample) do
        { a: { aa: 1 }, b: 2, c: 3 }
      end
      subject { sample }

      it 'runs without errors' do
        expect { subject.except!(:c, :d) }.to_not raise_error
      end

      it 'filters elements' do
        expect(subject.except!(:c, :d)).to eq({ a: { aa: 1 }, b: 2})
      end

      it 'modifies the Array in place' do
        expect { subject.except!(:c, :d) }.to change { sample }.to({ a: { aa: 1 }, b: 2})
      end

      it 'raises ArgumentError if an array is passed instead of list of arguments' do
        expect { subject.except!([:c, :d]) }.to raise_error ArgumentError
      end
    end # #except!

    context '#deep_dup' do
      let(:sample_a) do
        { aa: 1 }
      end
      let(:sample) do
        { a: sample_a, c: 2 }
      end
      subject { sample }

      it 'runs without errors' do
        expect { subject.deep_dup }.to_not raise_error
      end

      it 'duplicates elements' do
        expect(subject.deep_dup).to eq(sample)
      end

      it 'produces a deep copy of a Hash' do
        sample_dup = subject.deep_dup
        expect(sample_dup).to eq sample
        sample_dup[:c] = 3
        expect(sample[:c]).to_not eq 3
        sample_dup[:a][:bb] = 3
        expect(sample[:a]).to eq sample_a
      end
    end # #deep_dup

    context '#symbolize_keys' do
      let(:sample) do
        { 1 => 1, '2' => 2, :"3" => 3 }
      end
      let(:sample_symbolized) do
        { 1 => 1, :"2" => 2, :"3" => 3 }
      end
      subject { sample }

      it 'runs without errors' do
        expect { subject.symbolize_keys }.to_not raise_error
      end

      it 'symbolizes string keys' do
        expect(subject.symbolize_keys).to eq(sample_symbolized)
      end
    end # #symbolize_keys

    context '#symbolize_keys!' do
      let(:sample) do
        { 1 => 1, '2' => 2, :"3" => 3 }
      end
      let(:sample_symbolized) do
        { 1 => 1, :"2" => 2, :"3" => 3 }
      end
      subject { sample }

      it 'runs without errors' do
        expect { subject.symbolize_keys! }.to_not raise_error
      end

      it 'symbolizes string keys' do
        expect(subject.symbolize_keys!).to eq(sample_symbolized)
      end

      it 'modifes Hash in-place' do
        expect { subject.symbolize_keys! }.to change { sample }.to(sample_symbolized)
      end
    end # #symbolize_keys!

    context '#deep_symbolize_keys' do
      let(:sample) do
        { 1 => 1, '2' => 2, :"3" => { 3 => 3, '4' => 4, :"5" => 5 } }
      end
      let(:sample_symbolized) do
        { 1 => 1, :"2" => 2, :"3" => { 3 => 3, :"4" => 4, :"5" => 5 } }
      end
      subject { sample }

      it 'runs without errors' do
        expect { subject.deep_symbolize_keys }.to_not raise_error
      end

      it 'symbolizes string keys' do
        expect(subject.deep_symbolize_keys).to eq(sample_symbolized)
      end
    end # #deep_symbolize_keys

    context '#deep_symbolize_keys!' do
      let(:sample) do
        { 1 => 1, '2' => 2, :"3" => { 3 => 3, '4' => 4, :"5" => 5 } }
      end
      let(:sample_symbolized) do
        { 1 => 1, :"2" => 2, :"3" => { 3 => 3, :"4" => 4, :"5" => 5 } }
      end
      subject { sample }

      it 'runs without errors' do
        expect { subject.deep_symbolize_keys! }.to_not raise_error
      end

      it 'symbolizes string keys' do
        expect(subject.deep_symbolize_keys!).to eq(sample_symbolized)
      end

      it 'modifes Hash in-place' do
        expect { subject.deep_symbolize_keys! }.to change { sample }.to(sample_symbolized)
      end
    end # #deep_symbolize_keys!

    context '#stringify_keys' do
      let(:sample) do
        { 1 => 1, '2' => 2, :"3" => 3 }
      end
      let(:sample_stringified) do
        { '1' => 1, '2' => 2, '3' => 3 }
      end
      subject { sample }

      it 'runs without errors' do
        expect { subject.stringify_keys }.to_not raise_error
      end

      it 'stringifies all keys' do
        expect(subject.stringify_keys).to eq(sample_stringified)
      end
    end # #stringify_keys

    context '#stringify_keys!' do
      let(:sample) do
        { 1 => 1, '2' => 2, :"3" => 3 }
      end
      let(:sample_stringified) do
        { '1' => 1, '2' => 2, '3' => 3 }
      end
      subject { sample }

      it 'runs without errors' do
        expect { subject.stringify_keys! }.to_not raise_error
      end

      it 'stringifies all keys' do
        expect(subject.stringify_keys!).to eq(sample_stringified)
      end

      it 'modifes Hash in-place' do
        expect { subject.stringify_keys! }.to change { sample }.to(sample_stringified)
      end
    end # #stringify_keys

    context '#deep_stringify_keys' do
      let(:sample) do
        { 1 => 1, '2' => 2, :"3" => { 3 => 3, '4' => 4, :"5" => 5 } }
      end
      let(:sample_stringified) do
        { '1' => 1, '2' => 2, '3' => { '3' => 3, '4' => 4, '5' => 5 } }
      end
      subject { sample }

      it 'runs without errors' do
        expect { subject.deep_stringify_keys }.to_not raise_error
      end

      it 'stringifies all keys' do
        expect(subject.deep_stringify_keys).to eq(sample_stringified)
      end
    end # #deep_stringify_keys

    context '#deep_stringify_keys!' do
      let(:sample) do
        { 1 => 1, '2' => 2, :"3" => { 3 => 3, '4' => 4, :"5" => 5 } }
      end
      let(:sample_stringified) do
        { '1' => 1, '2' => 2, '3' => { '3' => 3, '4' => 4, '5' => 5 } }
      end
      subject { sample }

      it 'runs without errors' do
        expect { subject.deep_stringify_keys! }.to_not raise_error
      end

      it 'stringifies all keys' do
        expect(subject.deep_stringify_keys!).to eq(sample_stringified)
      end

      it 'modifes Hash in-place' do
        expect { subject.deep_stringify_keys! }.to change { sample }.to(sample_stringified)
      end
    end # #deep_stringify_keys
  end # Hash
end
