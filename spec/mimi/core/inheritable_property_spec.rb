require 'spec_helper'

describe 'Mimi::Core::InheritableProperty' do
  let(:hvar_default) do
    { a: :a }
  end

  let(:base_class) do
    Class.new do
      include Mimi::Core::InheritableProperty
    end
  end

  let(:class_a) do
    dd = hvar_default # NOTE: somehow hvar_default is not visible in the class block
    Class.new(base_class) do
      inheritable_property :var1
      inheritable_property :var2, default: :default
      inheritable_property :hvar, type: :hash, default: dd
    end
  end

  let(:class_b) do
    Class.new(class_a) do
    end
  end

  let(:class_c) do
    Class.new(class_b) do
    end
  end

  context 'module' do
    it 'is a module' do
      expect(defined?(Mimi::Core::InheritableProperty)).to_not be nil
      expect(Mimi::Core::InheritableProperty).to be_a Module
    end

    it 'exposes .inheritable_property method' do
      expect(base_class).to respond_to(:inheritable_property)
    end
  end # module

  context 'simple value without a default' do
    it 'defines A.var1 method' do
      expect(class_a).to respond_to(:var1)
    end

    it 'responds with nil if unset' do
      expect(class_a.var1).to be nil
    end

    it 'defines B.var1 method' do
      expect(class_b).to respond_to(:var1)
    end

    it 'allows setting a new value' do
      expect { class_a.var1 :test }.to_not raise_error
      expect { class_b.var1 :test }.to_not raise_error
    end

    it 'responds with set value' do
      class_a.var1 :test
      expect(class_a.var1).to eq :test
    end

    it 'is inherited in the subclass' do
      class_a.var1 :test
      expect(class_b.var1).to eq :test
    end

    it 'if set in subclass, does NOT change value in base class' do
      class_b.var1 :test
      expect(class_a.var1).to be nil
    end

    it 'responds with a value set in the current class' do
      class_a.var1 :var1_a
      class_b.var1 :var1_b
      expect(class_a.var1).to be :var1_a
      expect(class_b.var1).to be :var1_b
      expect(class_c.var1).to be :var1_b
    end
  end # simple value without a default

  context 'simple value with a default' do
    let(:class_p) do
      Class.new(base_class) do
        inheritable_property :var_proc, default: -> { :default_proc }
      end
    end

    it 'defines A.var2 method' do
      expect(class_a).to respond_to(:var2)
    end

    it 'responds with a default value if unset' do
      expect(class_a.var2).to eq :default
    end

    it 'allows setting a new value' do
      expect { class_a.var2 :test }.to_not raise_error
      expect { class_b.var2 :test }.to_not raise_error
    end

    it 'responds with set value' do
      class_a.var2 :test
      expect(class_a.var2).to eq :test
    end

    it 'is inherited in the subclass' do
      class_a.var2 :test
      expect(class_b.var2).to eq :test
    end

    it 'if set in subclass, does NOT change value in base class' do
      class_b.var2 :test
      expect(class_a.var2).to be :default
    end

    it 'allows specifying a Proc as default' do
      expect { class_p }.to_not raise_error
      expect(class_p).to respond_to(:var_proc)
      expect(class_p.var_proc).to eq :default_proc
    end
  end # simple value with a default

  context 'hash value' do
    it 'defines A.hvar method' do
      expect(class_a).to respond_to(:hvar)
    end

    it 'responds with a default value if unset' do
      expect(class_a.hvar).to eq hvar_default
    end

    it 'allows setting a new value' do
      expect { class_a.hvar a: 1 }.to_not raise_error
      expect { class_b.hvar b: 2 }.to_not raise_error
    end

    it 'responds with set value' do
      class_a.hvar a: 1
      expect(class_a.hvar).to eq(a: 1)
    end

    it 'is inherited in the subclass' do
      class_a.hvar a: 1
      expect(class_b.hvar).to eq(a: 1)
    end

    it 'if set in subclass, does NOT change value in base class' do
      class_b.hvar a: 1
      expect(class_a.hvar).to eq(hvar_default)
    end

    it 'deep merges inherited values in subclasses' do
      class_a.hvar a: { b: 1 }
      class_b.hvar a: { c: 2 }, d: 3
      expect(class_a.hvar).to eq(a: { b: 1 })
      expect(class_b.hvar).to eq(a: { b: 1, c: 2 }, d: 3)
      expect(class_c.hvar).to eq(a: { b: 1, c: 2 }, d: 3)
    end
  end # hash value
end # Mimi::Core::InheritableProperty
