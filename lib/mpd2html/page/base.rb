require 'erubis'
require 'fileutils'

module MPD2HTML
  module Page
    class Base
      def render(items, output_dir)
        write html(sort(items)), output_dir
      end

      def is_canonical?
        false
      end

      private

      def sort(items)
        items.sort_by { |item| item.sort_key primary_sort_attribute }
      end

      def html(items)
        template = IO.read File.expand_path("#{File.dirname __FILE__}/../../../template/template.html.erb")
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
          if page.is_a? page_for_which_column_is_sorted
            "#{text} ▽"
          else
            "<a href=#{page_for_which_column_is_sorted.new.basename}.html>#{text}</a>"
          end
        end

      end

    end
  end
end
