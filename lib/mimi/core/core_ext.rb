# frozen_string_literal: true

require 'hashie'

class Hash
  unless instance_methods(false).include?(:only)
    def only(*keys)
      dup.only!(*keys)
    end

    def only!(*keys)
      if keys.size == 1 && keys.first.is_a?(Array)
        raise ArgumentError, 'Hash#only!() expects keys as list of arguments,' \
          ' not an Array as first argument'
      end
      select! { |k, _| keys.include?(k) }
      self
    end
  end

  unless instance_methods(false).include?(:except)
    def except(*keys)
      dup.except!(*keys)
    end

    def except!(*keys)
      if keys.size == 1 && keys.first.is_a?(Array)
        raise ArgumentError, 'Hash#except!() expects keys as list of arguments,' \
          ' not an Array as first argument'
      end
      reject! { |k, _| keys.include?(k) }
      self
    end
  end

  unless instance_methods(false).include?(:deep_merge)
    include Hashie::Extensions::DeepMerge
  end

  unless instance_methods(false).include?(:deep_dup)
    def deep_dup
      map do |k, v|
        v = v.respond_to?(:deep_dup) ? v.deep_dup : v.dup
        [k, v]
      end.to_h
    end
  end

  unless instance_methods(false).include?(:symbolize_keys)
    include Hashie::Extensions::KeyConversion
  end

  unless instance_methods(false).include?(:deep_symbolize_keys)
    include Hashie::Extensions::KeyConversion unless self < Hashie::Extensions::KeyConversion

    def deep_symbolize_keys
      symbolize_keys_recursively
    end

    def deep_symbolize_keys!
      symbolize_keys_recursively!
    end
  end

  unless instance_methods(false).include?(:stringify_keys)
    include Hashie::Extensions::KeyConversion
  end

  unless instance_methods(false).include?(:deep_stringify_keys)
    include Hashie::Extensions::KeyConversion unless self < Hashie::Extensions::KeyConversion

    def deep_stringify_keys
      stringify_keys_recursively
    end

    def deep_stringify_keys!
      stringify_keys_recursively!
    end
  end
end

class Array
  unless instance_methods(false).include?(:only)
    def only(*keys)
      dup.only!(*keys)
    end

    def only!(*keys)
      if keys.size == 1 && keys.first.is_a?(Array)
        raise ArgumentError, 'Array#only!() expects keys as list of arguments,' \
          ' not an Array as first argument'
      end
      select! { |k| keys.include?(k) }
      self
    end
  end

  unless instance_methods(false).include?(:except)
    def except(*keys)
      dup.except!(*keys)
    end

    def except!(*keys)
      if keys.size == 1 && keys.first.is_a?(Array)
        raise ArgumentError, 'Array#except!() expects keys as list of arguments,' \
          ' not an Array as first argument'
      end
      reject! { |k| keys.include?(k) }
      self
    end
  end

  unless instance_methods(false).include?(:deep_dup)
    def deep_dup
      map do |v|
        v.respond_to?(:deep_dup) ? v.deep_dup : v.dup
      end
    end
  end
end
