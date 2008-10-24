require File.join(File.dirname(__FILE__),'../../src/util/data_structure_formatter.rb')
describe DataStructureFormatter::Tree do
  before(:each) do
    @data= [1,
      [ [2, []],
        [3, [[4,[[5,[]]]],[6,[]]]] ]]
    @ac=DataStructureFormatter::Tree::Accessor.new
  end

  it '::Accessor should access data as tree' do
    @ac.value_accessor {|target| target[0] }
    @ac.child_enumerator {|target| target[1] }
    @ac.value_of(@data).should == 1
    @ac.children(@data).map{|item|@ac.value_of(item)}.should == [2,3]
  end
  it '#format should format to human-readable tree structure' do
    @ac.value_accessor {|target| target[0].to_s }
    @ac.child_enumerator {|target| target[1] }
    formatter=DataStructureFormatter::Tree::Formatter.new(@ac)
    formatter.format(@data).should be == <<'EOS'
--1
  +-2
  `-3
    +-4
    | `-5
    `-6
EOS
  end
  it '::Formatter#format_as_array should return [[tree node, formatted line]... ]' do
    @ac.value_accessor {|target| target[0].to_s }
    @ac.child_enumerator {|target| target[1] }
    formatter=DataStructureFormatter::Tree::Formatter.new(@ac)
    result=formatter.format_array(@data)
    result[0][1].should == '--1'
    result[0][0].should be @data
    result[3][1].should == '    +-4'
    result[3][0].should be @data[1][1][1][0]
  end
end

describe DataStructureFormatter::Table do
  before(:each) do
    @data=[
      {:id => 1, :name => 'hoge', :amount => 1000},
      {:id => 2, :name => 'hage', :amount => 2000},
      {:id => 3, :name => 'fugafuga', :amount => 3000}
    ]
    @ac=DataStructureFormatter::Table::Accessor.new
    @ac.row_enumerator {|data| data }
    @ac.column_enumerator {|row|
      [
        row[:id],
        row[:name],
        row[:amount]
      ]
    }
    @formatter=DataStructureFormatter::Table::Formatter.new @ac,['id','name','amount']
  end

  it 'should access as table' do
    rows=@ac.rows(@data)
    rows.to_a[0].should == {:id => 1, :name => 'hoge', :amount => 1000}
    @ac.columns(rows.to_a[0]).should == [1,'hoge',1000]
  end

  it 'should convert data to table structure' do
    @ac.convert_to_table(@data).should == [
      [1,'hoge',1000],
      [2,'hage',2000],
      [3,'fugafuga',3000]
    ]
  end

  it 'should know max length of each columns' do
    @formatter.column_widths(@ac.convert_to_table(@data)).should == [2,8,6]
  end

  it 'should render sepalate line' do
    @formatter.render_sepalate_line([0,1,2]).should == '+--+---+----+'
  end

  it 'should render header' do
    @formatter.render_header([2,8,6]).should == '| id | name     | amount |'
  end

  it 'should render a row' do
    @formatter.render_row([2,8,6],[1,'hoge',1000]).should == '|  1 | hoge     |   1000 |'
  end

  it 'should override column justify' do  
    @formatter.column_justify(2,:left)
    @formatter.column_justify(1,:right)
    @formatter.render_row([2,8,6],[1,'hoge',1000]).should == '|  1 |     hoge | 1000   |'
  end
  
  it 'should format to human readable table structure' do
    @formatter.format(@data).should == <<'EOS'
+----+----------+--------+
| id | name     | amount |
+----+----------+--------+
|  1 | hoge     |   1000 |
|  2 | hage     |   2000 |
|  3 | fugafuga |   3000 |
+----+----------+--------+
EOS
  end
end
