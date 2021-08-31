require_relative 'base'

module MPD2HTML
  module Page
    class Lyricists < Base
      def basename
        'johnson-collection-by-lyricist'
      end

      def primary_sort_column_index
        3
      end

      def primary_sort_column_name
        "Lyricist(s)"
      end

      def primary_sort_attribute
        :lyricists
      end

    end
  end
end
