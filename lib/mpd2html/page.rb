require 'erubis'
require 'fileutils'

module MPD2HTML
  class Page
    attr_reader :primary_sort_attribute, :primary_sort_column, :basename

    def initialize(primary_sort_attribute, primary_sort_column, basename)
      @primary_sort_attribute = primary_sort_attribute
      @primary_sort_column = primary_sort_column
      @basename = basename
    end

    def render(items, output_dir)
      write html(sort(items)), output_dir
    end

    private

    def sort(items)
      items.sort_by { |item| item.sort_key primary_sort_attribute }
    end

    def html(items)
      template = IO.read File.expand_path("#{File.dirname __FILE__}/../../template/template.html.erb")
      Erubis::Eruby.new(template).evaluate Context.new(self, items)
    end

    def write(html, output_dir)
      FileUtils.mkdir_p output_dir
      IO.write "#{output_dir}/#{basename}.html", html
    end

    class Context
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

    TITLE = Page.new :title, 1, 'johnson-collection'
    COMPOSERS = Page.new :composers, 2, 'johnson-collection-by-composer'
    ALL = [TITLE, COMPOSERS]

  end
end
