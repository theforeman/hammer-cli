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

describe HammerCLI::Output::MetaData do

  let(:meta) { HammerCLI::Output::MetaData.new(:total => "6", :page => "2", :per_page => "3", :subtotal => "5") }

  it "converts numeric metadata to numbers" do
    meta.total.must_equal 6
    meta.page.must_equal 2
    meta.per_page.must_equal 3
    meta.subtotal.must_equal 5
  end

  describe "pagination_set?" do
    let(:pagination_data) { { :total => 6, :page => 2, :per_page => 3, :subtotal => 5 } }

    it "can tell if pagination data are set" do
      meta.pagination_set?.must_equal true
    end

    it "can tell if pagination data are not set" do
      pagination_data.keys.each do |key|
        meta = HammerCLI::Output::MetaData.new(pagination_data.clone.reject { |k| k == key })
        meta.pagination_set?.must_equal false
      end
    end
  end
end
