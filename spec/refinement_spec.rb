require 'spec_helper'

describe Refinement do
  
  let(:klass)               { Class.new }
  let(:klass_instance)      { klass.new }
  let(:method)              { :my_method }
  let(:block)               { proc{} }
  let(:args)                { [ klass, method, block ] }
  let(:refinement)          { described_class.refine(*args[0..-2], &args[2]) }

  before do 
    expect{ klass.new.send(method) }.to raise_error NoMethodError
  end

  describe '.refine' do
    subject { refinement }

    it "adds a new #{described_class}::Method to .refinements" do
      described_class.refinements.should_receive(:<<).with(kind_of(described_class::Method))
      subject
    end

    it "instances a new a #{described_class}::Method" do
      described_class::Method.should_receive(:new).with(*args)
      subject
    end

  end

  describe '.use' do
    before { refinement }
    context 'without a block' do
      before { subject }
      subject { described_class.use }

      it 'applies the refinements' do
        klass.new.send(method).should be_nil
      end
      it 'does not define the method for the klass' do
        expect{ klass.send(method) }.to raise_error NoMethodError
      end
    end

    context 'with a block' do
      subject { described_class.use{ klass.new.send(method) } }
      it 'makes refinements available inside the block' do
        expect{ subject }.to_not raise_error NoMethodError
      end

      context 'when the block is executed with success' do
        it 'reverts the refinements' do
          subject
          expect{ klass.new.send(method) }.to raise_error NoMethodError
        end
      end

      context 'when the block throws an exception' do
        subject { described_class.use{ raise Exception } }
        it 'reverts the refinements' do
          begin
            subject
          rescue Exception
          end
          expect{ klass.new.send(method) }.to raise_error NoMethodError
        end
      end

      context 'when the block returns' do
        subject { described_class.use{ return } }
        it 'reverts the refinements' do
          begin
            subject
          rescue LocalJumpError
          end
          expect{ klass.new.send(method) }.to raise_error NoMethodError
        end
      end
    end
  end

  describe 'benchmarks' do

    example 'use {} a refined method which was undefined' do
      if klass.method_defined?(method) or klass.private_method_defined?(method)
        raise "#{klass}.new.#{method} should not be defined"
      end
      
      described_class.refine(klass, method){}

      Benchmark.bmbm do |x|
        x.report('use {}') { described_class.use {} }
        x.report('10_000 use {}') { 10_000.times { described_class.use {} } }
      end

    end

  end

  after do 
    described_class.refinements.compact!
    described_class.unuse
    described_class.refinements.clear
  end
  
end