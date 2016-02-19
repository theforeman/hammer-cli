module HammerCLI
  module Testing
    module DataHelpers
      def load_json(file_path, test_file_context=nil)
        unless test_file_context.nil?
          file_path = File.join(File.dirname(test_file_context), file_path)
        end
        JSON.parse(File.read(file_path))
      end

      def load_yaml(file_path, test_file_context=nil)
        unless test_file_context.nil?
          file_path = File.join(File.dirname(test_file_context), file_path)
        end
        YAML.load(File.read(file_path))
      end
    end
  end
end
