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

        before { klass.send :define_method, method, &unrefined_block }

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

    context 'benchmarks' do

      let(:instance) { described_class.new(klass, method, &proc{}) }

      describe '#use' do

        context 'a refined method which was undefined' do
          example ' ' do
            if klass.method_defined?(method)
              raise "#{klass}.new.#{method} should not be defined"
            end

            example_group = example.metadata[:example_group]
            context       = example_group[:description_args].first
            describe      = example_group[:example_group][:description_args].first
            
            Benchmark.bmbm do |x|
              x.report("#{describe} #{context}")             { instance.use }
              x.report("#{describe} #{context} 1_000 times") { 1_000.times { instance.use } }
            end
          end
        end

        context 'a refined method which was defined' do

          before { klass.send :define_method, method, &unrefined_block }

          example ' ' do
            unless klass.method_defined?(method)
              raise "#{klass}.new.#{method} should be defined"
            end
            
            example_group = example.metadata[:example_group]
            context       = example_group[:description_args].first
            describe      = example_group[:example_group][:description_args].first

            Benchmark.bmbm do |x|
              x.report("#{describe} #{context}")             { instance.use }
              x.report("#{describe} #{context} 1_000 times") { 1_000.times { instance.use } }
            end
          end

        end

      end

    end

  end
end