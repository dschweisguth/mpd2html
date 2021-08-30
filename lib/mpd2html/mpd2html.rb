require 'erubis'
require 'fileutils'
require_relative 'options'
require_relative 'page'
require_relative 'parser'

module MPD2HTML
  class MPD2HTML
    def run
      options = Options.new
      options.parse!
      Logger.verbose = options.verbose
      items = Parser.new.items options.files
      Page::ALL.each do |page|
        write_html page, sort(page, items), options.output_dir
      end
      FileUtils.cp Dir.glob("#{File.dirname __FILE__}/../../assets/*"), options.output_dir
    end

    private

    def sort(page, items)
      items.sort_by { |item| item.sort_key page.primary_sort_attribute }
    end

    def write_html(page, items, output_dir)
      FileUtils.mkdir_p output_dir
      IO.write "#{output_dir}/#{page.basename}.html", html(page, items)
    end

    def html(page, items)
      template = IO.read File.expand_path("#{File.dirname __FILE__}/../../template/template.html.erb")
      Erubis::Eruby.new(template).evaluate TemplateContext.new(page, items)
    end

    class TemplateContext
      attr_reader :page, :items

      def initialize(page, items)
        @page = page
        @items = items
      end

      def column_header(text, page_for_which_column_is_sorted)
        if page == page_for_which_column_is_sorted
          "#{text} ▽"
        else
          "<a href=#{page_for_which_column_is_sorted.basename}.html>#{text}</a>"
        end
      end

    end

  end
end
