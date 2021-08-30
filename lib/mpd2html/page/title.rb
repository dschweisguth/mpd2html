require_relative 'base'

module MPD2HTML
  module Page
    class Title < Base
      def is_canonical?
        true
      end

      def primary_sort_attribute
        :title
      end

      def primary_sort_column
        1
      end

      def basename
        'johnson-collection'
      end

    end
  end
end
