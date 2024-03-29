module MPD2HTML
  module FieldParser
    class Base
      attr_reader :parsers, :warnings

      def initialize(input)
        lines = take input
        @parsers = take_for_parsers lines
        @warnings = []
        parse lines
      end

      private

      def take_for_parsers(lines)
        []
      end

      def take_first_lines_matching(lines, pattern)
        [].tap do |first_lines|
          while lines.first =~ pattern
            first_lines << lines.shift
          end
        end
      end

      def warn(message)
        warnings << message
      end

    end
  end
end
