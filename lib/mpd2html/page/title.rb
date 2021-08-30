require_relative 'base'

module MPD2HTML
  module Page
    class Title < Base
      def basename
        'johnson-collection'
      end

      def is_canonical?
        true
      end

      def primary_sort_column_index
        1
      end

      def primary_sort_column_name
        "Title"
      end

      def primary_sort_attribute
        :title
      end

    end
  end
end
