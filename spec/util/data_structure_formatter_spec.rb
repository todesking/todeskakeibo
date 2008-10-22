require File.join(File.dirname(__FILE__),'../../src/util/data_structure_formatter.rb')
describe DataStructureFormatter::Tree,'with tree data' do
  before(:each) do
    @data= [1,
      [ [2, []],
        [3, [[4,[[5,[]]]],[6,[]]]] ]]
    @ac=DataStructureFormatter::Tree::Accessor.new
  end
  it 'should access tree data structure' do
    @ac.value_accessor {|target| target[0] }
    @ac.child_enumerator {|target| target[1] }
    @ac.value_of(@data).should == 1
    @ac.children(@data).map{|item|@ac.value_of(item)}.should == [2,3]
  end
  it 'should print human-readable tree structure' do
    @ac.value_accessor {|target| target[0].to_s }
    @ac.child_enumerator {|target| target[1] }
    formatter=DataStructureFormatter::Tree::Formatter.new(@ac)
    formatter.format(@data).should be == <<'EOS'
--1
  +-2
  L-3
    +-4
    | L-5
    L-6
EOS
  end
end
