module HammerCLI::Output


  class MetaData

    attr_accessor :total, :subtotal, :page, :per_page, :search, :sort_by, :sort_order, :pagination_verbosity

    def initialize(options={})
      @total = options[:total].to_i if options[:total]
      @subtotal = options[:subtotal].to_i if options[:subtotal]
      @page = options[:page].to_i if options[:page]
      @per_page = options[:per_page].to_i if options[:per_page]
      @search = options[:search]
      @sort_by = options[:sort_by]
      @sort_order = options[:sort_order]
      @pagination_verbosity = options[:pagination_verbosity] || HammerCLI::V_VERBOSE
    end

    def pagination_set?
      !(@total.nil? || @subtotal.nil? || @page.nil? || @per_page.nil?)
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
