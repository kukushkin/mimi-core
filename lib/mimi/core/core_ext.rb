# frozen_string_literal: true

class Hash
  unless instance_methods(false).include?(:only)
    #
    # Returns a Hash with only given keys, if present
    #
    # @param *keys [*] list of keys
    # @return [Hash] a new Hash
    #
    # @example
    #   h = { a: 1, b: 2, :c 3 }
    #   h.only(:a, :b, :d) # => { a: 1, b: 2 }
    #
    def only(*keys)
      dup.only!(*keys)
    end

    # Modifies the Hash keeping only given keys, if present
    #
    # @param *keys [*] list of keys
    # @return [Hash] self
    #
    # @example
    #   h = { a: 1, b: 2, :c 3 }
    #   h.only!(:a, :b, :d)
    #   h # => { a: 1, b: 2 }
    #
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
    #
    # Returns a Hash with given keys excluded, if present
    #
    # @param *keys [*] list of keys
    # @return [Hash] a new Hash
    #
    # @example
    #   h = { a: 1, b: 2, :c 3 }
    #   h.except(:a, :b, :d) # => { c: 3 }
    #
    def except(*keys)
      dup.except!(*keys)
    end

    # Modifies the Hash excluding given keys, if present
    #
    # @param *keys [*] list of keys
    # @return [Hash] self
    #
    # @example
    #   h = { a: 1, b: 2, :c 3 }
    #   h.except!(:a, :b, :d)
    #   h # => { c: 3 }
    #
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
    #
    # Deep merges self (left) Hash with another Hash
    #
    # On keys existing in both Hashes:
    # * merges Hash values by merging left Hash with the right Hash
    # * merges Array values by union operator
    # * for other values overwrites left Hash value with the right Hash value
    #
    # @param right [Hash] the right (other) Hash
    # @return [Hash] self
    #
    def deep_merge!(right)
      right.each do |k ,v|
        unless self.key?(k)
          self[k] = v
          next
        end
        if self[k].is_a?(Hash) && v.is_a?(Hash)
          self[k].deep_merge!(v)
        elsif self[k].is_a?(Array) && v.is_a?(Array)
          self[k] = self[k] | v
        else
          # unmergeable values, overwrite
          self[k] = v
        end
      end
      self
    end

    # @see #deep_merge!
    #
    # @param right [Hash] the right (other) Hash
    # @return [Hash] a new Hash
    #
    def deep_merge(right)
      deep_dup.deep_merge!(right)
    end
  end

  unless instance_methods(false).include?(:deep_dup)
    #
    # Duplicates a Hash with all nested values
    #
    # @return [Hash] a new Hash
    #
    def deep_dup
      map do |k, v|
        v = v.respond_to?(:deep_dup) ? v.deep_dup : v.dup
        [k, v]
      end.to_h
    end
  end

  unless instance_methods(false).include?(:symbolize_keys)
    #
    # Symbolizes Hash keys
    #
    # @return [Hash] a new Hash
    #
    def symbolize_keys
      map do |k, v|
        k = k.respond_to?(:to_sym) ? k.to_sym : k
        [k, v]
      end.to_h
    end

    # Modifies the Hash symbolizing its keys
    #
    # @return [Hash] self
    #
    def symbolize_keys!
      replace(symbolize_keys)
    end
  end

  unless instance_methods(false).include?(:deep_symbolize_keys)
    #
    # Symbolizes Hash keys including all nested Hashes
    #
    # @return [Hash] a new Hash
    #
    def deep_symbolize_keys
      map do |k, v|
        k = k.respond_to?(:to_sym) ? k.to_sym : k
        v = v.respond_to?(:deep_symbolize_keys) ? v.deep_symbolize_keys : v
        [k, v]
      end.to_h
    end

    # Modifies the Hash symbolizing its keys including all nested Hashes
    #
    # @return [Hash] self
    #
    def deep_symbolize_keys!
      replace(deep_symbolize_keys)
    end
  end

  unless instance_methods(false).include?(:stringify_keys)
    #
    # Stringifies Hash keys
    #
    # @return [Hash] a new Hash
    #
    def stringify_keys
      map do |k, v|
        k = k.respond_to?(:to_s) ? k.to_s : k
        [k, v]
      end.to_h
    end

    # Modifies the Hash stringifying its keys
    #
    # @return [Hash] self
    #
    def stringify_keys!
      replace(stringify_keys)
    end
  end

  unless instance_methods(false).include?(:deep_stringify_keys)
    #
    # Stringifies Hash keys including all nested Hashes
    #
    # @return [Hash] a new Hash
    #
    def deep_stringify_keys
      map do |k, v|
        k = k.respond_to?(:to_s) ? k.to_s : k
        v = v.respond_to?(:deep_stringify_keys) ? v.deep_stringify_keys : v
        [k, v]
      end.to_h
    end

    # Modifies the Hash stringifying its keys including all nested Hashes
    #
    # @return [Hash] self
    #
    def deep_stringify_keys!
      replace(deep_stringify_keys)
    end
  end
end

class Array
  unless instance_methods(false).include?(:only)
    #
    # Returns an Array with only selected values, if present
    #
    # @param *values [*] list of values
    # @return [Array] a new Array
    #
    # @example
    #   a = [:a, :b, :c]
    #   a.only(:a, :b, :d) # => [:a, :b]
    #
    def only(*values)
      dup.only!(*values)
    end

    # Modifies the Array keeping only given values, if present
    #
    # @param *values [*] list of values
    # @return [Array] self
    #
    # @example
    #   a = [:a, :b, :c]
    #   a.only!(:a, :b, :d)
    #   a # => [:a, :b]
    #
    def only!(*values)
      if values.size == 1 && values.first.is_a?(Array)
        raise ArgumentError, 'Array#only!() expects values as list of arguments,' \
          ' not an Array as first argument'
      end
      select! { |k| values.include?(k) }
      self
    end
  end

  unless instance_methods(false).include?(:except)
    #
    # Returns an Array with given values excluded, if present
    #
    # @param *values [*] list of values
    # @return [Array] a new Array
    #
    # @example
    #   a = [:a, :b, :c]
    #   a.except(:a, :b, :d) # => [:c]
    #
    def except(*keys)
      dup.except!(*keys)
    end

    # Modifies the Array excluding given values, if present
    #
    # @param *values [*] list of values
    # @return [Array] self
    #
    # @example
    #   a = [:a, :b, :c]
    #   a.except!(:a, :b, :d)
    #   a # => [:c]
    #
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
    #
    # Duplicates an Array with all nested values
    #
    # @return [Hash] a new Hash
    #
    def deep_dup
      map do |v|
        v.respond_to?(:deep_dup) ? v.deep_dup : v.dup
      end
    end
  end
end
