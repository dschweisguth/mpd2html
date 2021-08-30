require_relative 'base'

module MPD2HTML
  module Page
    class Composers < Base
      def basename
        'johnson-collection-by-composer'
      end

      def primary_sort_column_index
        2
      end

      def primary_sort_column_name
        "Composer(s)"
      end

      def primary_sort_attribute
        :composers
      end

    end
  end
end
