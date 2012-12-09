require 'spec_helper'

module Refinement
  describe Method do

    let(:klass)  { Class.new }
    let(:method) { :my_method }
    let(:block)  { -> { 'refined' } }

    describe '#use' do
      
      subject { described_class.new(klass, method, &block).use }
      
      context 'when the method is not already defined' do
        it 'defines it' do
          subject
          klass.new.send(method).should == block.call
        end
      end
      
      context 'when the method is already defined' do
        before { klass.send :define_method, method, &proc{ 'unrefined' } }
        it 'defines it' do
          subject
          klass.new.send(method).should == block.call
        end
      end
    end

  end
end