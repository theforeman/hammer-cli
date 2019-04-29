require File.join(File.dirname(__FILE__), '../test_helper')


describe HammerCLI::Options::Normalizers do

  describe 'abstract' do

    let(:formatter) { HammerCLI::Options::Normalizers::AbstractNormalizer.new }

    it "should raise exception on format" do
      proc { formatter.format(nil) }.must_raise NotImplementedError
    end

  end

  describe 'default' do

    let(:formatter) { HammerCLI::Options::Normalizers::Default.new }

    it "should not change any value" do
      formatter.format('value').must_equal 'value'
    end

    it "should not change nil value" do
      formatter.format(nil).must_be_nil
      end

    it "has empty description" do
      formatter.description.must_equal ''
    end

    it "has empty completion" do
      formatter.complete('test').must_equal []
    end
  end

  describe 'list' do

    let(:formatter) { HammerCLI::Options::Normalizers::List.new }

    it "should return empty array on nil" do
      formatter.format(nil).must_equal []
    end

    it "should return empty array on empty string" do
      formatter.format("").must_equal []
    end

    it "should parse a string" do
      formatter.format("a").must_equal ['a']
    end

    it "should parse a number" do
      formatter.format("2").must_equal [2]
    end

    it "should parse a comma separated string" do
      formatter.format("a,b,c").must_equal ['a', 'b', 'c']
    end

    it "should parse a comma separated string with values including comma" do
      formatter.format('a,b,"c,d"').must_equal ['a', 'b', 'c,d']
    end

    it "should parse a comma separated string with values including comma (doublequotes)" do
      formatter.format("a,b,'c,d'").must_equal ['a', 'b', 'c,d']
    end

    it "should parse a comma separated string containig double quotes" do
      formatter.format('a,b,\"c\"').must_equal ['a', 'b', '"c"']
    end

    it "should catch quoting errors" do
      proc { formatter.format('1,"3,4""s') }.must_raise ArgumentError
    end

    it "should accept and parse JSON" do
      value = {'name' => 'bla', 'value' => 1}
      formatter.format(value.to_json).must_equal([value])
    end
  end

  describe 'list_nested' do
    let(:params_raw) do
      [
        {name: 'name', expected_type: :string, validator: 'string', description: ''},
        {name: 'value', expected_type: :string, validator: 'string', description: ''}
      ]
    end
    let(:params) do
      [
        ApipieBindings::Param.new(params_raw.first),
        ApipieBindings::Param.new(params_raw.last)
      ]
    end
    let(:param) do
      ApipieBindings::Param.new({
        name: 'array', expected_type: :array, validator: 'nested', description: '',
        params: params_raw
      })
    end
    let(:formatter) { HammerCLI::Options::Normalizers::ListNested.new(param.params) }

    it "should accept and parse JSON" do
      formatter.format("{\"name\":\"bla\", \"value\":1}").must_equal(
        JSON.parse("{\"name\":\"bla\", \"value\":1}")
      )
    end

    it "should parse simple input" do
      formatter.format("name=test\\,value=1,name=other\\,value=2").must_equal(
        [{'name' => 'test', 'value' => '1'}, {'name' => 'other', 'value' => '2'}]
      )
    end

    it "should parse unexpected input" do
      formatter.format("name=test\\,value=1,name=other\\,value=2,unexp=doe").must_equal(
        [
          {'name' => 'test', 'value' => '1'}, {'name' => 'other', 'value' => '2'},
          {'unexp' => 'doe'}
        ]
      )
    end

    it "should accept arrays" do
      formatter.format("name=test\\,value=1,name=other\\,value=[1\\,2\\,3]").must_equal(
        [{'name' => 'test', 'value' => '1'}, {'name' => 'other', 'value' => ['1', '2', '3']}]
      )
    end

    it "should accept hashes" do
      formatter.format(
        "name=test\\,value={key=key1\\,value=1},name=other\\,value={key=key2\\,value=2}"
      ).must_equal(
        [
          {'name' => 'test', 'value' => {'key' => 'key1', 'value' => '1'}},
          {'name' => 'other', 'value' => {'key' => 'key2', 'value' => '2'}},
        ]
      )
    end

    it "should accept combined input" do
      formatter.format(
        "name=foo\\,value=1\\,adds=[1\\,2\\,3]\\,cpu={name=ddd\\,type=abc}," \
        "name=bar\\,value=2\\,adds=[2\\,2\\,2]\\,cpu={name=ccc\\,type=cba}"
      ).must_equal(
        [
          {'name' => 'foo', 'value' => '1', 'adds' => ['1','2','3'], 'cpu' => {'name' => 'ddd', 'type' => 'abc'}},
          {'name' => 'bar', 'value' => '2', 'adds' => ['2','2','2'], 'cpu' => {'name' => 'ccc', 'type' => 'cba'}}
        ]
      )
    end
  end

  describe 'key_value_list' do

    let(:formatter) { HammerCLI::Options::Normalizers::KeyValueList.new }

    it "should return empty array on nil" do
      formatter.format(nil).must_equal({})
    end

    it "should return empty array on empty string" do
      formatter.format("").must_equal({})
    end

    it "should parse a string" do
      proc { formatter.format("a") }.must_raise ArgumentError
    end

    describe 'key=value format' do
      it "should parse a comma separated string" do
        formatter.format("a=1,b=2,c=3").must_equal({'a' => '1', 'b' => '2', 'c' => '3'})
      end

      it "should parse a comma separated string with spaces" do
        formatter.format("a= 1 , b = 2 ,c =3").must_equal({'a' => '1', 'b' => '2', 'c' => '3'})
      end

      it "should parse a comma separated string with spaces using single quotes" do
        formatter.format("a= ' 1 ' , b =' 2',c ='3'").must_equal({'a' => ' 1 ', 'b' => ' 2', 'c' => '3'})
      end

      it "should parse a comma separated string with spaces using double quotes" do
        formatter.format("a= \" 1 \" , b =\" 2\",c =\"3\"").must_equal({'a' => ' 1 ', 'b' => ' 2', 'c' => '3'})
      end

      it "should deal with equal sign in value" do
        formatter.format("a=1,b='2=2',c=3").must_equal({'a' => '1', 'b' => '2=2', 'c' => '3'})
      end

      it "should parse arrays" do
        formatter.format("a=1,b=[1,2,3],c=3").must_equal({'a' => '1', 'b' => ['1', '2', '3'], 'c' => '3'})
      end

      it "should parse arrays with spaces" do
        formatter.format("a=1,b=[1, 2, 3],c=3").must_equal({'a' => '1', 'b' => ['1', '2', '3'], 'c' => '3'})
      end

      it "should parse arrays with spaces using by single quotes" do
        formatter.format("a=1,b=['1 1', ' 2 ', ' 3 3'],c=3").must_equal({'a' => '1', 'b' => ['1 1', ' 2 ', ' 3 3'], 'c' => '3'})
      end

      it "should parse arrays with spaces using by double quotes" do
        formatter.format("a=1,b=[\"1 1\", \" 2 \", \" 3 3\"],c=3").must_equal({'a' => '1', 'b' => ['1 1', ' 2 ', ' 3 3'], 'c' => '3'})
      end

      it "should parse array with one item" do
        formatter.format("a=1,b=[abc],c=3").must_equal({'a' => '1', 'b' => ['abc'], 'c' => '3'})
      end

      it "should parse empty array" do
        formatter.format("a=1,b=[],c=3").must_equal({'a' => '1', 'b' => [], 'c' => '3'})
      end

      it "should parse hash with one item" do
        formatter.format("a=1,b={key=abc,value=abc},c=3").must_equal(
          {'a' => '1', 'b' => {'key' => 'abc', 'value' => 'abc'}, 'c' => '3'}
        )
      end

      it "should parse empty hash" do
        formatter.format("a=1,b={},c=3").must_equal({'a' => '1', 'b' => {}, 'c' => '3'})
      end

      it "should parse a comma separated string 2" do
        proc { formatter.format("a=1,b,c=3") }.must_raise ArgumentError
      end
    end

    describe 'json format' do
      it 'parses arrays' do
        formatter.format('["a", "b", 1]').must_equal(['a', 'b', 1])
      end

      it 'parses objects' do
        formatter.format('{"a": ["b", 1]}').must_equal({'a' => ['b', 1]})
      end
    end
  end

  describe 'number' do
    let(:formatter) { HammerCLI::Options::Normalizers::Number.new }

    it "should return number on numeric values" do
      formatter.format("1").must_equal 1
    end

    it "should raise ArgumentError on non-numeric values" do
      proc { formatter.format("a") }.must_raise ArgumentError
    end
  end

  describe 'bool' do

    let(:formatter) { HammerCLI::Options::Normalizers::Bool.new }

    it "should return true on true" do
      formatter.format("true").must_equal(true)
      formatter.format("TRUE").must_equal(true)
    end

    it "should return true on t" do
      formatter.format("t").must_equal(true)
      formatter.format("T").must_equal(true)
    end

    it "should return true on yes" do
      formatter.format("yes").must_equal(true)
      formatter.format("YES").must_equal(true)
    end

    it "should return true on y" do
      formatter.format("y").must_equal(true)
      formatter.format("Y").must_equal(true)
    end

    it "should return true on 1" do
      formatter.format("1").must_equal(true)
    end

    it "should return false on false" do
      formatter.format("false").must_equal(false)
      formatter.format("FALSE").must_equal(false)
    end

    it "should return false on f" do
      formatter.format("f").must_equal(false)
      formatter.format("F").must_equal(false)
    end

    it "should return false on no" do
      formatter.format("no").must_equal(false)
      formatter.format("NO").must_equal(false)
    end

    it "should return false on n" do
      formatter.format("n").must_equal(false)
      formatter.format("N").must_equal(false)
    end

    it "should return false on 0" do
      formatter.format("0").must_equal(false)
    end

    it "should raise exception on nil" do
      proc { formatter.format(nil) }.must_raise ArgumentError
    end

    it "should raise exception on other values" do
      proc { formatter.format('unknown') }.must_raise ArgumentError
    end
  end

  describe 'json input' do
    let(:formatter) { HammerCLI::Options::Normalizers::JSONInput.new }

    it "should return a hash on valid json file" do
      file = File.join(File.dirname(__FILE__), '../fixtures/json_input/valid.json')
      formatter.format(file).must_equal({ "units" => [ { "name" => "zip", "version" => "10.0" },
                                        { "name" => "zap", "version" => "9.0" }] })
    end

    it "should raise exception on invalid json file contents" do
      file = File.join(File.dirname(__FILE__), '../fixtures/json_input/invalid.json')
      proc { formatter.format(file) }.must_raise ArgumentError
    end

    it "should return a hash on valid json string" do
      json_string = '{ "units":[{ "name":"zip", "version":"10.0" }, { "name":"zap", "version":"9.0" }] }'
      formatter.format(json_string).must_equal({ "units" => [ { "name" => "zip", "version" => "10.0" },
                                                              { "name" => "zap", "version" => "9.0" }] })
    end

    it "should raise exception on invalid json string" do
      json_string = "{ units:[{ name:zip, version:10.0 }, { name:zap, version:9.0 }] }"
      proc { formatter.format(json_string) }.must_raise ArgumentError
    end

  end

  describe 'enum' do

    let(:formatter) { HammerCLI::Options::Normalizers::Enum.new ['a', 'b'] }

    it "should return return value when in the list" do
      formatter.format("a").must_equal("a")
    end

    it "should rise argument error when the value is nil" do
      proc { formatter.format(nil) }.must_raise ArgumentError
    end

    it "should rise argument error when the value is not in the list" do
      proc { formatter.format("c") }.must_raise ArgumentError
    end

    it "should list allowed values in description" do
      formatter.description.must_equal("Possible value(s): 'a', 'b'")
    end

  end

  describe 'enumlist' do

    let (:formatter) { HammerCLI::Options::Normalizers::EnumList.new ['1', '2', 'a', 'b'] }

    it "should return array of values when the values are allowed" do
      formatter.format("a,b,1").must_equal(['a', 'b', '1'])
    end

    it "should raise argument error when any of the values isn't in the list" do
      proc { formatter.format("c,d") }.must_raise ArgumentError
      proc { formatter.format('1,x') }.must_raise ArgumentError
    end

    it "should remove duplicate values" do
      formatter.format("a,a,a,a,a").must_equal ['a']
    end

    it "should not change order of the values" do
      formatter.format("a,b,2,1").must_equal ['a', 'b', '2', '1']
    end

    it "should return empty array on nil" do
      formatter.format(nil).must_equal []
    end

    it "should return empty array on empty string" do
      formatter.format("").must_equal []
    end

    it "should list allowed values in description" do
      formatter.description.must_equal("Any combination (comma separated list) of ''1', '2', 'a', 'b''")
    end

  end

  describe 'datetime' do

    let(:formatter) { HammerCLI::Options::Normalizers::DateTime.new }

    it "should raise argument error when the value is nil" do
      proc { formatter.format(nil) }.must_raise ArgumentError
    end

    it "should raise argument error when the value is not a date" do
      proc { formatter.format("not a date") }.must_raise ArgumentError
    end

    it "should accept and parse iso8601" do
      formatter.format("1986-01-01T08:30:20").must_equal("1986-01-01T08:30:20+00:00")
    end

    it "should accept and parse YYYY-MM-DD HH:MM:SS" do
      formatter.format("1986-01-01 08:30:20").must_equal("1986-01-01T08:30:20+00:00")
    end

    it "should accept and parse YYYY/MM/DD HH:MM:SS" do
      formatter.format("1986/01/01 08:30:20").must_equal("1986-01-01T08:30:20+00:00")
    end

  end

end
