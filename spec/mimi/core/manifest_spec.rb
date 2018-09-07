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
end
