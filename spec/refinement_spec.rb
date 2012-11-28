require 'spec_helper'

describe Refinement do
  describe '.refine' do
    # it "adds a refinement to" do
    #   Refinement.should_receive :asd
    # end
  end
  describe '.new' do
    let(:args) { [String, :puts_inspect, Proc.new{ puts self.inspect }] }
    it 'creates a Refinement::Method' do
      described_class::Method.should_receive(:new).with(*args)
      described_class.refine(*args[0..-2], &args[2])
    end
  end
end