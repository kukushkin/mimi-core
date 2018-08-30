# require 'active_support'
# require 'active_support/core_ext'
require 'hashie'

class Hash
  unless instance_methods(false).include?(:only)
    def only(*keys)
      dup.only!(*keys)
    end

    def only!(*keys)
      select! { |k, _| keys.include?(k) }
      self
    end
  end

  unless instance_methods(false).include?(:except)
    def except(*keys)
      dup.except!(*keys)
    end

    def except!(*keys)
      reject! { |k, _| keys.include?(k) }
      self
    end
  end

  unless instance_methods(false).include?(:deep_merge)
    include Hashie::Extensions::DeepMerge
  end
end

class Array
  unless instance_methods(false).include?(:only)
    def only(*keys)
      dup.only!(*keys)
    end

    def only!(*keys)
      select! { |k| keys.include?(k) }
      self
    end
  end

  unless instance_methods(false).include?(:except)
    def except(*keys)
      dup.except!(*keys)
    end

    def except!(*keys)
      reject! { |k| keys.include?(k) }
      self
    end
  end
end
