require 'refinement/method'

module Refinement

  class << self
    def refinements
      @refinements ||= []
    end

    def refine(klass, method, visibility = :public, &block)
      refinements << Method.new(klass, method, visibility, &block)
    end

    def use
      refinements.each(&:use)
    end

    def unuse
      refinements.each(&:unuse)
    end

    def using
      begin
        refinements.each(&:use)
        yield
      ensure
        refinements.each(&:unuse)
      end
    end
  end

end