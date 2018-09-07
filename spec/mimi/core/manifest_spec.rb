require 'spec_helper'

describe Mimi::Core::Manifest do
  let(:manifest_sample) do
    {
      var1: {},
      var2: {
        desc: 'var2.desc',
        type: :string,
        default: 'var2.default',
        hidden: false,
        const: false
      },
      var3: { type: :string },
      var4: { type: :integer },
      var5: { type: :decimal },
      var6: { type: :boolean },
      var7: { type: :json },
      var8: { type: ['var8.1', 'var8.2', 'var8.3'] },

      var9: { default: -> { 'var9.default'} },
    }
  end
  let(:manifest_sample_invalid) do
    {
      var1: {
        type: :unknown
      }
    }
  end

  it 'is expected to be a Class' do
    expect(Mimi::Core::Manifest).to be_a Class
  end

  context '.new' do
    it 'creates an empty Manifest without errors' do
      expect { Mimi::Core::Manifest.new }.to_not raise_error
    end

    it 'creates a Manifest without errors' do
      expect { Mimi::Core::Manifest.new(manifest_sample) }.to_not raise_error
    end

    it 'raises an error if manifest is invalid' do
      expect { Mimi::Core::Manifest.new(manifest_sample_invalid) }.to raise_error ArgumentError
    end
  end # .new

  context '.validate_manifest_hash' do
    # Produces a copy of manifest_sample enriched with hash
    def manifest_sample_with(hash)
      manifest_sample.deep_dup.deep_merge(hash)
    end

    it 'does NOT raise error on a valid manifest' do
      expect { described_class.validate_manifest_hash(manifest_sample) }.to_not raise_error
    end

    it 'raises an error if a manifest key is invalid' do
      expect do
        described_class.validate_manifest_hash(manifest_sample_with('invalid' => {}))
      end.to raise_error ArgumentError
    end

    it 'raises an error if a property :desc is invalid' do
      expect do
        described_class.validate_manifest_hash(manifest_sample_with(var1: { desc: :invalid }))
      end.to raise_error ArgumentError
    end

    it 'raises an error if a property :type is invalid' do
      expect do
        described_class.validate_manifest_hash(manifest_sample_with(var1: { type: :invalid }))
      end.to raise_error ArgumentError
    end

    it 'raises an error if a property :hidden is invalid' do
      expect do
        described_class.validate_manifest_hash(manifest_sample_with(var1: { hidden: :invalid }))
      end.to raise_error ArgumentError
    end

    it 'raises an error if a property :const is invalid' do
      expect do
        described_class.validate_manifest_hash(manifest_sample_with(var1: { const: :invalid }))
      end.to raise_error ArgumentError
    end

    it 'raises an error if a property :const is set, but :default is omitted' do
      expect do
        described_class.validate_manifest_hash(manifest_sample_with(var1: { const: true }))
      end.to raise_error ArgumentError
    end
  end # .validate_manifest_hash

  context '#to_h' do
    let(:manifest_empty) { Mimi::Core::Manifest.new }
    let(:manifest_hash) do
      { var1: {}, var2: { desc: 'var2.desc', type: :string } }
    end

    it { expect(manifest_empty).to respond_to(:to_h) }

    it 'exposes an empty Manifest as an empty Hash' do
      expect(manifest_empty.to_h).to be_a Hash
      expect(manifest_empty.to_h).to eq({})
    end

    it 'exposes a non-empty Manifest as a Hash' do
      manifest = Mimi::Core::Manifest.new(manifest_hash)
      expect(manifest.to_h).to be_a Hash
      expect(manifest.to_h).to eq manifest_hash
      expect(manifest.to_h.object_id).to_not eq manifest_hash.object_id
    end
  end # #to_h

  context '.new and #merge' do
    let(:manifest_empty) { Mimi::Core::Manifest.new }
    let(:manifest_hash) do
      { var1: {}, var2: { desc: 'var2.desc', type: :string } }
    end
    let(:manifest_hash_invalid) do
      { var1: {}, var2: { type: :invalid } }
    end

    it { expect(manifest_empty).to respond_to(:merge) }

    it 'merges an empty manifest with a new Hash' do
      manifest = manifest_empty.dup
      expect(manifest.to_h).to eq({})
      expect { manifest.merge(manifest_hash) }.to_not raise_error
      expect(manifest.to_h).to eq manifest_hash
    end

    it 'raises an error if merging with invalid Hash' do
      expect { manifest_empty.merge(manifest_hash_invalid) }.to raise_error ArgumentError
    end
  end # .new and #merge
end
