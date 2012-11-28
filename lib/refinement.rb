require 'refinement/method'

class Refinement

  class << self
    def refinements
      @refinements ||= []
    end

    def refine(klass, method, &block)
      refinements << new(klass, method, block)
    end

    def use
      refinements.each(&:use)
    end

    def unuse
      refinements.each(&:unuse)
    end
  end

  def initialize(klass, method_name, block)
    @method = Method.new(klass, method_name, block)
  end

  def use
    @method.use
  end

  def unuse
    @method.unuse
  end

end