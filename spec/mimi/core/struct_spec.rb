require 'spec_helper'

describe Mimi::Core::Struct do
  it "is a Class" do
    expect(described_class).to be_a Class
  end

  context ".new()" do
    it "accepts a Hash" do
      expect { described_class.new(a: 1, b: 2) }.to_not raise_error
    end

    it "accepts no parameters" do
      expect { described_class.new() }.to_not raise_error
    end

    it "does NOT accept a parameter which is not a Hash" do
      expect { described_class.new([:a, 1]) }.to raise_error(ArgumentError)
    end
  end # .new()

  context "an initialized instance" do
    let(:params) do
      { a: 1, b: 2, c: { d: true } }
    end

    subject { described_class.new(params) }

    it "constructs a Mimi::Core::Struct object" do
      expect { subject }.to_not raise_error
      expect(subject).to be_a(Mimi::Core::Struct)
    end

    it { is_expected.to respond_to(:[]) }
    it { is_expected.to_not respond_to(:[]=) }
    it { is_expected.to respond_to(:to_h) }
    it { is_expected.to respond_to(:dup) }
    it { is_expected.to respond_to(:==) }
  end

  describe "#==" do
    let(:struct1) { described_class.new(a: 1) }
    let(:struct2) { described_class.new(a: 1) }
    let(:struct3) { described_class.new(a: 2) }

    subject { struct1 == struct2 }

    it "runs without errors" do
      expect { subject }.to_not raise_error
    end

    it "returns true if different Structs have equal values" do
      expect(struct1 == struct2).to be true
    end

    it "returns false if different Structs have different values" do
      expect(struct1 == struct3).to be false
    end
  end # #==

  describe "#dup" do
    let(:struct1) { described_class.new(a: 1) }
    let(:struct2) { struct1.dup }

    subject { struct2 }

    it "runs without errors" do
      expect { subject }.to_not raise_error
    end

    it "returns a new object" do
      expect(subject.object_id).to_not eq struct1.object_id
    end

    it "a new object provides access to member attributes" do
      expect(subject).to respond_to(:a)
      expect { subject[:a] }.to_not raise_error
    end
  end # #dup

  context "when initialized with a Hash" do
    let(:params) do
      { a: 1, b: 2, c: { d: true } }
    end

    subject { described_class.new(params) }

    it "constructs a Mimi::Core::Struct object" do
      expect { subject }.to_not raise_error
      expect(subject).to be_a(Mimi::Core::Struct)
    end

    it "provides read access to members as methods" do
      expect(subject).to respond_to(:a)
      expect(subject).to respond_to(:b)
      expect(subject).to respond_to(:c)
    end

    it "does NOT provide write access to members as methods" do
      expect(subject).to_not respond_to(:a=)
      expect(subject).to_not respond_to(:b=)
      expect(subject).to_not respond_to(:c=)
    end

    it "does NOT allow method access to non-defined members" do
      expect(subject).to_not respond_to(:d)
      expect { subject.d }.to raise_error(NoMethodError)
    end

    it "provides access to members as indifferent Hash keys" do
      expect { subject[:a] }.to_not raise_error
      expect(subject[:a]).to eq 1
      expect { subject["a"] }.to_not raise_error
      expect(subject["a"]).to eq 1
    end

    it "does NOT allow access as Hash key to non-defined members" do
      expect { subject[:d] }.to raise_error(NameError)
      expect { subject["d"] }.to raise_error(NameError)
    end
  end # when initialized with a Hash
end
