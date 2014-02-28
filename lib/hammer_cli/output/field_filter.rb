module HammerCLI::Output

  class FieldFilter

    def initialize(field_classes=[])
      @field_classes = field_classes
    end

    def filter(fields)
      fields = fields.clone
      @field_classes.each do |cls|
        fields.reject! do |f|
          f.is_a? cls
        end
      end
      fields
    end

  end

end
