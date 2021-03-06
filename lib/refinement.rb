require 'refinement/method'

class Refinement

  class << self
    def refinements
      @refinements ||= []
    end

    def refine(klass, method, visibility = nil, &block)
      refinements << Method.new(klass, method, visibility, &block)
    end

    def use
      refinements.each(&:use)
    end

    def unuse
      refinements.each(&:unuse)
    end

    def using
      refinements.each(&:use)
      yield
    ensure
      refinements.each(&:unuse)
    end
  end

end