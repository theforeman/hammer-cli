require File.join(File.dirname(__FILE__), '../test_helper')

describe HammerCLI::Output::RecordCollection do
  let(:data) { [1, 2, 3] }
  let(:meta) { { :total => 6, :page => 2, :per_page => 3, :subtotal => 5,
          :search => 'name~=xx', :sort_by => 'name', :sort_order => 'ASC' } }
  let(:set) { HammerCLI::Output::RecordCollection.new(data, meta) }

  it "should keep records and its meta data" do
    set.must_equal data
    set.meta.total.must_equal 6
    set.meta.subtotal.must_equal 5
    set.meta.total.must_equal 6
    set.meta.page.must_equal 2
    set.meta.per_page.must_equal 3
    set.meta.search.must_equal 'name~=xx'
    set.meta.sort_by.must_equal 'name'
    set.meta.sort_order.must_equal 'ASC'
  end

  it "should wrap the data into list" do
    record = { :key => :value, :key2 => :value }
    rs = HammerCLI::Output::RecordCollection.new(record)
    rs.must_be_kind_of Array
  end

  it "sould accept MetaData as option" do
    metadata = HammerCLI::Output::MetaData.new(meta)
    set = HammerCLI::Output::RecordCollection.new(data, :meta => metadata)
    set.meta.must_equal metadata
    set.meta.total.must_equal 6
  end

end
