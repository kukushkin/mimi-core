require 'spec_helper'

describe Mimi::Core::Manifest do
  #
  # Constructs a manifest object from Hash
  #
  # @param hash [Hash]
  # @return [Mimi::Core::Manifest]
  #
  def manifest_from(hash)
    Mimi::Core::Manifest.new(hash)
  end

  let(:properties_defaults) do
    { desc: '', type: :string, hidden: false, const: false }
  end
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

    it { expect(described_class).to respond_to(:validate_manifest_hash) }

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
      {
        var1: {},
        var2: { desc: 'var2.desc', type: :string }
      }
    end
    let(:manifest_hash_with_defaults) do
      {
        var1: properties_defaults,
        var2: properties_defaults.merge(desc: 'var2.desc', type: :string)
      }
    end

    it { expect(manifest_empty).to respond_to(:to_h) }

    it 'exposes an empty Manifest as an empty Hash' do
      expect(manifest_empty.to_h).to be_a Hash
      expect(manifest_empty.to_h).to eq({})
    end

    it 'exposes a non-empty Manifest as a Hash' do
      manifest = Mimi::Core::Manifest.new(manifest_hash)
      expect(manifest.to_h).to be_a Hash
      expect(manifest.to_h).to eq manifest_hash_with_defaults
      expect(manifest.to_h.object_id).to_not eq manifest_hash.object_id
    end
  end # #to_h

  context '.new and #merge!' do
    let(:manifest_empty) { Mimi::Core::Manifest.new }
    let(:manifest_hash) do
      { var1: {}, var2: { desc: 'var2.desc', type: :string } }
    end
    let(:manifest_hash_with_defaults) do
      {
        var1: properties_defaults,
        var2: properties_defaults.merge(desc: 'var2.desc', type: :string)
      }
    end
    let(:manifest_hash_2) do
      { var2: { type: :integer, default: 1 } }
    end
    let(:manifest_hash_merged_with_defaults) do
      {
        var1: properties_defaults,
        var2: properties_defaults.merge(desc: 'var2.desc', type: :integer, default: 1)
      }
    end
    let(:manifest_hash_invalid) do
      { var1: {}, var2: { type: :invalid } }
    end

    it { expect(manifest_empty).to respond_to(:merge) }
    it { expect(manifest_empty).to respond_to(:merge!) }


    it 'does NOT raise an error when merging an empty Hash' do
      expect { manifest_empty.merge!({}) }.to_not raise_error
    end

    it 'raises an error if merging with invalid Hash' do
      expect { manifest_empty.merge!(manifest_hash_invalid) }.to raise_error ArgumentError
    end

    it 'successfully merges an empty manifest with a new Hash' do
      manifest = manifest_empty.dup
      expect(manifest.to_h).to eq({})
      expect { manifest.merge!(manifest_hash) }.to_not raise_error
      expect(manifest.to_h).to eq manifest_hash_with_defaults
    end

    it 'successfully deep-merges a non-empty manifest with a new Hash' do
      manifest = manifest_empty.dup
      expect(manifest.to_h).to eq({})
      expect { manifest.merge!(manifest_hash) }.to_not raise_error
      expect { manifest.merge!(manifest_hash_2) }.to_not raise_error
      expect(manifest.to_h).to eq manifest_hash_merged_with_defaults
    end
  end # .new and #merge

  context '#apply' do
    let(:manifest_full_hash) do
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

        var9: { default: -> { 'var9.default' } },
      }
    end
    let(:manifest_full) { manifest_from(manifest_full_hash) }
    let(:manifest_empty) { manifest_from({}) }
    let(:config_valid) do
      {
        var1: 1,
        var2: 2,
        var3: 3,
        var4: 4,
        var5: 5,
        var6: 'true',
        var7: '[{"var7":"val7"}]',
        var8: 'var8.1',
        var9: 9
      }
    end
    let(:values_valid) do
      {
        var1: '1',
        var2: '2',
        var3: '3',
        var4: 4,
        var5: BigDecimal(5),
        var6: true,
        var7: [{ 'var7' => 'val7' }],
        var8: 'var8.1',
        var9: '9'
      }
    end

    it { expect(manifest_full).to respond_to(:apply) }

    it 'accepts configuration values and responds with a Hash of processed values' do
      expect { manifest_full.apply(config_valid) }.to_not raise_error
      expect(manifest_full.apply(config_valid)).to be_a Hash
      expect(manifest_full.apply(config_valid)).to eq values_valid
    end

    it 'responds with empty Hash on an empty manifest and configuration' do
      expect { manifest_empty.apply({}) }.to_not raise_error
      expect(manifest_empty.apply({})).to eq({})
    end

    it 'processes a default value of nil, as-is' do
      manifest = manifest_from(var1: { type: :string, default: nil })
      expect(manifest.apply({})).to eq(var1: nil)
    end

    it 'processes a default with a literal value, type string' do
      manifest = manifest_from(var1: { type: :string, default: '1' })
      expect(manifest.apply({})).to eq(var1: '1')
    end

    it 'processes a default with a literal value, type integer' do
      manifest = manifest_from(var1: { type: :integer, default: 1 })
      expect(manifest.apply({})).to eq(var1: 1)
    end

    it 'processes a default with a literal value, converting value to given type' do
      manifest = manifest_from(var1: { type: :integer, default: '1' })
      expect(manifest.apply({})).to eq(var1: 1)
      manifest = manifest_from(var1: { type: :decimal, default: '1.0' })
      expect(manifest.apply({})).to eq(var1: BigDecimal(1))
    end

    it 'prevents changing :const parameters' do
      manifest = manifest_from(var1: { type: :string, const: true, default: 1 })
      expect(manifest.apply(var1: 123)).to eq(var1: '1')
    end

    it 'raises an ArgumentError if a required parameter is missing' do
      manifest = manifest_from(var1: {})
      expect { manifest.apply({}) }.to raise_error(ArgumentError)
    end

    it 'raises an ArgumentError if provided value is invalid, type: integer' do
      manifest = manifest_from(var1: { type: :integer })
      expect { manifest.apply(var1: '1abc') }.to raise_error(ArgumentError)
    end

    it 'raises an ArgumentError if provided value is invalid, type: decimal' do
      manifest = manifest_from(var1: { type: :decimal })
      expect { manifest.apply(var1: '1abc') }.to raise_error(ArgumentError)
    end

    it 'raises an ArgumentError if provided value is invalid, type: boolean' do
      manifest = manifest_from(var1: { type: :boolean })
      expect { manifest.apply(var1: 't') }.to raise_error(ArgumentError)
    end

    it 'raises an ArgumentError if provided value is invalid, type: json' do
      manifest = manifest_from(var1: { type: :json })
      expect { manifest.apply(var1: 'a') }.to raise_error(ArgumentError)
    end

    it 'raises an ArgumentError if provided value is invalid, type: enum' do
      manifest = manifest_from(var1: { type: ['a', 'b', 'c'] })
      expect { manifest.apply(var1: 'd') }.to raise_error(ArgumentError)
    end
  end # #apply

  context '#keys' do
    let(:manifest_full) { manifest_from(manifest_sample) }
    let(:keys_sample) { manifest_sample.keys.dup }
    subject { manifest_from({}) }

    it { is_expected.to respond_to(:keys) }

    it 'responds with empty Array on an empty manifest' do
      expect(subject.keys).to eq []
    end

    it 'responds with a list of configurable parameter names on a non-empty manifest' do
      expect(manifest_full.keys).to eq keys_sample
    end
  end # #keys

  context '#required?' do
    subject { manifest_from(manifest_sample) }

    it { is_expected.to respond_to(:required?) }

    it 'responds with false on an undeclared configurable parameter' do
      expect(subject.required?(:foobar)).to eq false
    end

    it 'responds with false on a declared optional parameter' do
      expect(subject.required?(:var2)).to eq false
    end

    it 'responds with true on a declared required parameter' do
      expect(subject.required?(:var1)).to eq true
    end

    it 'raises an error if the argument is not a Symbol' do
      expect { subject.required?('var1') }.to raise_error(ArgumentError)
    end
  end # #required?

  context '.from_yaml, #to_yaml' do
    let(:sample_yaml) { fixture('manifest.1.yml') }
    let(:sample_hash) do
      {
        min1: properties_defaults,
        opt1: properties_defaults.merge(desc: 'opt1.desc', default: 'opt1.default'),
        req1: properties_defaults.merge(desc: 'req1.desc'),
        opt2: properties_defaults.merge(type: :integer, default: nil),
        const1: properties_defaults.merge(desc: 'const1.desc', const: true, default: 'const1.default')
      }
    end
    let(:manifest_from_yaml) { described_class.from_yaml(sample_yaml) }
    let(:manifest_from_hash) { manifest_from(sample_hash) }
    subject { manifest_from_hash }

    it { expect(described_class).to respond_to(:from_yaml) }
    it { is_expected.to respond_to(:to_yaml) }

    it 'parses manifest from YAML with .from_yaml' do
      expect { manifest_from_yaml }.to_not raise_error
      expect(manifest_from_yaml).to be_a Mimi::Core::Manifest
      expect(manifest_from_yaml.to_h).to eq sample_hash
    end

    it 'converts manifest to YAML with #to_yaml' do
      expect { manifest_from_hash.to_yaml }.to_not raise_error
      expect(manifest_from_hash.to_yaml).to be_a String
      expect(manifest_from_hash.to_yaml).to eq sample_yaml
    end
  end # .from_yaml, #to_yaml
end
