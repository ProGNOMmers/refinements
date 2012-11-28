class Refinement
  class Method

    def initialize(klass, name, block)
      @klass, @name, @block = klass, name, block
    end

    def use
      case visibility = visibility(name)
      when nil
        @klass.send :define_method, name, &@block
      else
        @klass.send :alias_method, unrefined_name, name
        @klass.send :define_method, name, &@block
        @klass.send visibility, name
      end
    end

    def unuse
      @klass.send :undef_method, name
      if unrefined_visibility = visibility(unrefined_name)
        @klass.send :alias_method, name, unrefined_name
        @klass.send :undef_method, unrefined_name
      end
    end

    private
    def name
      @name
    end

    def unrefined_name
      :"unrefined_#{name}"
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