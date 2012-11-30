require 'spec_helper'

describe Refinement do
  
  let(:method) { :my_method }
  let(:args)   { [ Object, method, proc{} ] }

  describe '.refine' do

    subject { described_class.refine(*args[0..-2], &args[2]) }

    it "adds a Refinement to .refinements" do
      described_class.refinements.should_receive(:<<).with(kind_of(described_class::Method))
      subject
    end

    it 'instances a new a Refinement::Method' do
      described_class::Method.should_receive(:new).with(*args)
      subject
    end

    after { described_class.refinements.clear }
  end

  describe 'benchmarks' do

    example 'use {} a refined method which was undefined' do
      if Object.method_defined?(method) or Object.private_method_defined?(method)
        raise "Object.new.#{method} should not be defined"
      end
      
      described_class.refine(Object, method){}

      Benchmark.bmbm do |x|
        x.report('use {}') { described_class.use {} }
        x.report('10_000 use {}') { 10_000.times { described_class.use {} } }
      end

    end

  end
  
end