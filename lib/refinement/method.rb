module Refinement
  class Method

    attr_reader :klass, :name, :block

    def initialize(klass, name, block)
      @klass, @name, @block = klass, name, block
    end

    def use
      if visibility = visibility(name)
        @klass.send :alias_method, unrefined_name, name
        @klass.send :define_method, name, &@block
        @klass.send visibility, name
      else
        @klass.send :define_method, name, &@block
      end
    end

    def unuse
      if unrefined_visibility = visibility(unrefined_name)
        @klass.send :alias_method, name, unrefined_name
        @klass.send :undef_method, unrefined_name
      end
    end

    # def in_use?
    #   !visibility(unrefined_name).nil?
    # end

    private
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