require 'spec_helper'

class Refinement
  describe Method do

    let(:klass)           { Class.new }
    let(:method)          { :my_method }
    let(:unrefined_block) { -> { 'unrefined' } }
    let(:refined_block)   { -> { 'refined' } }

    describe '#use' do
      
      subject { described_class.new(klass, method, &refined_block).use }
      
      context 'when the method is not already defined' do
        it 'defines it' do
          subject
          klass.new.send(method).should == refined_block.call
        end
      end
      
      context 'when the method is already defined' do
        before { klass.send :define_method, method, &proc{ 'unrefined' } }
        it 'defines it' do
          subject
          klass.new.send(method).should == refined_block.call
        end
      end

    end

    describe '#unuse' do

      let(:instance) { described_class.new(klass, method, &refined_block) }

      
      subject { instance.unuse }
      
      context 'when the method is not already defined' do
        
        before{ instance.use }
        
        it 'restores the previous behaviour' do
          subject
          expect{ klass.new.send(method) }.to raise_error NoMethodError
        end
      end
      
      context 'when the method is already defined' do
        
        before do
          klass.send :define_method, method, &unrefined_block
          instance.use
        end
        
        it 'restores the previous behaviour' do
          subject
          klass.new.send(method).should == unrefined_block.call
        end
      end

    end

  end
end