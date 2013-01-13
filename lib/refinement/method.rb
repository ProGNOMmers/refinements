class Refinement
  class Method

    attr_reader :klass, :name, :visibility, :block

    def initialize(klass, name, visibility = nil, &block)
      @klass, @name, @block = klass, name, block
      @visibility ||= :public
    end

    def use
      if visibility = visibility(name)
        @klass.send :alias_method, unrefined_name, name
        @klass.send :define_method, name, &@block
        @klass.send visibility, name
      else
        @klass.send :define_method, name, &@block
        @klass.send @visibility, name
      end
    end

    def unuse
      if exists?(unrefined_name)
        @klass.send :alias_method, name, unrefined_name
        @klass.send :remove_method, unrefined_name
      else
        @klass.send :remove_method, name if exists?(name)
      end
    end

    private
    def unrefined_name
      :"__unrefined_#{name}_#{object_id}"
    end

    def exists?(name)
      @klass.method_defined?(name) || @klass.private_method_defined?(name)
    end

    def visibility(name)
      if @klass.public_method_defined? name
        :public
      elsif @klass.protected_method_defined? name
        :protected
      elsif @klass.private_method_defined? name
        :private
      end
    end

  end
end
