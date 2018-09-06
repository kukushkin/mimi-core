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
    def symbolize_keys
      map do |k, v|
        k = k.respond_to?(:to_sym) ? k.to_sym : k
        [k, v]
      end.to_h
    end

    def symbolize_keys!
      replace(symbolize_keys)
    end
  end

  unless instance_methods(false).include?(:deep_symbolize_keys)
    def deep_symbolize_keys
      map do |k, v|
        k = k.respond_to?(:to_sym) ? k.to_sym : k
        v = v.respond_to?(:deep_symbolize_keys) ? v.deep_symbolize_keys : v
        [k, v]
      end.to_h
    end

    def deep_symbolize_keys!
      replace(deep_symbolize_keys)
    end
  end

  unless instance_methods(false).include?(:stringify_keys)
    def stringify_keys
      map do |k, v|
        k = k.respond_to?(:to_s) ? k.to_s : k
        [k, v]
      end.to_h
    end

    def stringify_keys!
      replace(stringify_keys)
    end
  end

  unless instance_methods(false).include?(:deep_stringify_keys)
    def deep_stringify_keys
      map do |k, v|
        k = k.respond_to?(:to_s) ? k.to_s : k
        v = v.respond_to?(:deep_stringify_keys) ? v.deep_stringify_keys : v
        [k, v]
      end.to_h
    end

    def deep_stringify_keys!
      replace(deep_stringify_keys)
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
