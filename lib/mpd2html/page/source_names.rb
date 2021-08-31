require_relative 'base'

module MPD2HTML
  module Page
    class SourceNames < Base
      def basename
        'johnson-collection-by-sources'
      end

      def primary_sort_column_index
        5
      end

      def primary_sort_column_name
        "Source"
      end

      def primary_sort_attribute
        :source_names
      end

    end
  end
end
