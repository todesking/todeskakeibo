require File.dirname(__FILE__)+'/'+'../../src/command/argument_parser.rb'

describe ArgumentParser,'when construct' do
  it 'should raise error when initialize with no arguments' do
    lambda{ArgumentParser.new}.should raise_error(ArgumentError)
  end
end
describe ArgumentParser,'when zero length' do
  before(:each) do
    @ap=ArgumentParser.new([])
  end
  it 'should success when parse with right argument' do
    pending
    @ap.parse([]).should be == {}
  end
  it 'should error when parse with too long arguments' do
    pending
    lambda{@ap.parse(['hoge'])}.should raise_error(ArgumentError)
  end

end
