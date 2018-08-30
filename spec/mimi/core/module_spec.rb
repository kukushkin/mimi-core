require 'spec_helper'

describe 'A module that includes Mimi::Core::Module' do
  let(:sample_module) do
    Module.new do
      include Mimi::Core::Module
    end
  end

  subject { sample_module }

  it { is_expected.to respond_to(:configure) }
  it { is_expected.to respond_to(:start) }
  it { is_expected.to respond_to(:started?) }
  it { is_expected.to respond_to(:stop) }
  it { is_expected.to respond_to(:manifest) }
  it { is_expected.to respond_to(:options) }
end
