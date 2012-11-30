require 'set'
require 'refinement/method'

module Refinement

  class << self
    def refinements
      @refinements ||= []
    end

    def refine(klass, method, &block)
      refinements << Method.new(klass, method, block)
    end

    def use
      return refinements.each(&:use) unless block_given?
      
      begin
        refinements.each(&:use)
        yield
      ensure
        refinements.each(&:unuse)
      end
    end

    def unuse
      refinements.each(&:unuse)
    end
  end

end