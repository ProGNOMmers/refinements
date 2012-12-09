require 'spec_helper'

describe Refinement do
  
  let(:klass)      { Class.new }
  let(:method)     { :my_method }
  let(:visibility) { :public }
  let(:block)      { -> { 'refined' } }
  let(:refinement) { described_class.refine(klass, method, visibility, &block) }

  before do
    described_class.refinements.should be_empty
    expect{ klass.new.send(method) }.to raise_error NoMethodError
  end

  describe '.refine' do
  
    subject { refinement }

    it "adds a new instance of #{described_class}::Method to .refinements" do
      described_class.refinements.
        should_receive(:<<).
        with(kind_of(described_class::Method))
      subject
    end

    it "instances a new #{described_class}::Method" do
      described_class::Method.
        should_receive(:new).
        with(klass, method, visibility, &block).
        and_call_original
      subject
    end

  end

  describe '.use' do
  
    subject { described_class.use }

    before do 
      refinement
      subject
    end

    it 'applies the refinements' do
      klass.new.send(method).should == block.call
    end
  
    it 'does not define the method for the klass' do
      expect{ klass.send(method) }.to raise_error NoMethodError
    end
  
  end

  describe '.using' do
  
    subject { described_class.using{ klass.new.send(method) } }
    
    before { refinement }
    
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

      subject { described_class.using{ raise StandardError } }

      it 'reverts the refinements' do
        begin
          subject
        rescue StandardError
        end
        expect{ klass.new.send(method) }.to raise_error NoMethodError
      end
    end

    context 'when the block returns' do

      subject { described_class.using{ return } }

      it 'reverts the refinements' do
        begin
          subject
        rescue LocalJumpError
        end
        expect{ klass.new.send(method) }.to raise_error NoMethodError
      end

    end

  end

  describe 'benchmarks' do

    example 'using {} a refined method which was undefined' do
      if klass.method_defined?(method) or klass.private_method_defined?(method)
        raise "#{klass}.new.#{method} should not be defined"
      end
      
      described_class.refine(klass, method){}

      Benchmark.bmbm do |x|
        x.report('using {}')        { described_class.using {} }
        x.report('10_000 using {}') { 10_000.times { described_class.using {} } }
      end
    end

  end

  after do
    described_class.unuse
    described_class.refinements.clear
  end
  
end