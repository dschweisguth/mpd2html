module MPD2HTML
  module Page
    class Context
      attr_reader :page, :items

      def initialize(page, items)
        @page = page
        @items = items
      end

      def column_header(page_for_which_column_is_sorted)
        text = page_for_which_column_is_sorted.new.primary_sort_column_name
        if page.is_a? page_for_which_column_is_sorted
          "#{text} ▽"
        else
          %Q(<a href="#{page_for_which_column_is_sorted.new.basename}.html">#{text}</a>)
        end
      end

      def with_breaks(strings)
        non_empty_strings = strings.reject(&:nil?)
        non_empty_strings.
          reject(&:nil?).
          map.with_index do |string, i|
            part = string
            if i < non_empty_strings.length - 1
              part += '<br/>'
            end
            part
          end.
          join
      end

    end
  end
end
