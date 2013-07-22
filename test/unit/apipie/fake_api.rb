  module FakeApi
    module Resources
      class Architecture
        def initialize(attrs=nil)
        end
        def self.doc
          {
            "name"=>"Architecture",
            "methods"=>[
              {
                "name"=>"some_action",
                "examples"=>[],
                "errors"=>[],
                "params"=>[]
              }
            ]
          }
        end
      end
      class CamelCaseName
        def initialize(attrs=nil)
        end

        def self.doc
          {
            "name"=>"CamelCaseName",
            "methods"=>[]
          }
        end
      end
      class Documented
        def initialize(attrs=nil)
        end

        def self.doc
          {
            "name"=>"Documented",
            "api_url"=>"/api",
            "version"=>"v2",
            "short_description"=>nil,
            "full_description"=>nil,
            "doc_url"=>"/apidoc/v2/documented",
            "methods"=>[
              {
                "name"=>"index",
                "examples"=>[],
                "errors"=>[],
                "params"=>
                 [{"allow_nil"=>false,
                   "name"=>"se_arch_val-ue",
                   "full_name"=>"se_arch_val-ue_full_name",
                   "validator"=>"Must be String",
                   "description"=>"<p>filter results</p>",
                   "expected_type"=>"string",
                   "required"=>false}],
                "full_description"=>""},
              {

                "name"=>"create",
                "examples"=>[],
                "errors"=>[],
                "params"=>
                 [{"allow_nil"=>false,
                   "name"=>"documented",
                   "full_name"=>"documented",
                   "validator"=>"Must be a Hash",
                   "description"=>"",
                   "expected_type"=>"hash",
                   "required"=>true,
                   "params"=>
                    [{"name"=>"name",
                      "allow_nil"=>false,
                      "full_name"=>"documented[name]",
                      "validator"=>"Must be String",
                      "expected_type"=>"string",
                      "description"=>"",
                      "required"=>false},
                     {"name"=>"provider",
                      "allow_nil"=>false,
                      "full_name"=>"documented[provider]",
                      "validator"=>"Must be String",
                      "expected_type"=>"string",
                      "description"=>
                       "<p>Providers include Libvirt, Ovirt, EC2, Vmware, Openstack, Rackspace</p>",
                      "required"=>false},
                     {"name"=>"array_param",
                      "allow_nil"=>false,
                      "full_name"=>"documented[array_param]",
                      "validator"=>"Must be Array",
                      "expected_type"=>"string",
                      "description"=>"",
                      "required"=>true},]
                    }],
                "full_description"=>""
              }
            ]
          }
        end
      end
    end
  end
