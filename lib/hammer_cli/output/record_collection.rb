module HammerCLI::Output


  class MetaData

    attr_accessor :total, :subtotal, :page, :per_page, :search, :sort_by, :sort_order

    def initialize(options={})
      @total = options[:total]
      @subtotal = options[:subtotal]
      @page = options[:page]
      @per_page = options[:per_page]
      @search = options[:search]
      @sort_by = options[:sort_by]
      @sort_order = options[:sort_order]
    end

  end


  class RecordCollection < Array

    attr_accessor :meta

    def initialize(data, options={})
      super [data].flatten(1)
      if options.has_key?(:meta) && options[:meta].class <= MetaData
        @meta = options[:meta]
      else
        @meta = MetaData.new(options)
      end
    end

  end
end
