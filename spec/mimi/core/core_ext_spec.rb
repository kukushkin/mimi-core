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
    it { is_expected.to respond_to(:deep_symbolize_keys) }
    it { is_expected.to respond_to(:deep_stringify_keys) }

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
  end # Hash
end
