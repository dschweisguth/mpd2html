require_relative 'base'

module MPD2HTML
  module Page
    class Composers < Base
      def primary_sort_attribute
        :composers
      end

      def primary_sort_column
        2
      end

      def basename
        'johnson-collection-by-composer'
      end

    end
  end
end
