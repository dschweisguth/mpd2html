require 'erubis'
require 'fileutils'
require_relative 'options'
require_relative 'page_type'
require_relative 'parser'

module MPD2HTML
  class MPD2HTML
    def run
      options = Options.new
      options.parse!
      Logger.verbose = options.verbose
      items = Parser.new.items options.files
      PageType::ALL.each do |page_type|
        write_html page_type, sort(page_type, items), options.output_dir
      end
      FileUtils.cp Dir.glob("#{File.dirname __FILE__}/../../assets/*"), options.output_dir
    end

    private

    def sort(page_type, items)
      items.sort_by { |item| item.sort_key page_type.primary_sort_attribute }
    end

    def write_html(page_type, items, output_dir)
      FileUtils.mkdir_p output_dir
      IO.write "#{output_dir}/#{page_type.basename}.html", page(page_type, items)
    end

    def page(page_type, items)
      template = IO.read File.expand_path("#{File.dirname __FILE__}/../../template/template.html.erb")
      Erubis::Eruby.new(template).evaluate TemplateContext.new(page_type, items)
    end

    class TemplateContext
      attr_reader :page_type, :items

      def initialize(page_type, items)
        @page_type = page_type
        @items = items
      end

      def column_header(text, page_type_for_which_column_is_sorted)
        if page_type == page_type_for_which_column_is_sorted
          "#{text} ▽"
        else
          "<a href=#{page_type_for_which_column_is_sorted.basename}.html>#{text}</a>"
        end
      end

    end

  end
end
