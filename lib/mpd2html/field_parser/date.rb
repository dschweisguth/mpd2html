require_relative 'base'

module MPD2HTML
  module FieldParser
    class Date < Base
      def self.attribute_names
        %i(dates)
      end

      attr_reader *attribute_names

      private

      def take(input)
        take_last_lines_matching input, /(?:[^)\n]|\(\?\)|^\s*\(\d{4}\))$/
      end

      def parse(lines)
        @dates = lines.map(&:strip)
        if @dates.empty?
          warn "No date"
        end
      end

      def take_last_lines_matching(lines, pattern)
        [].tap do |last_lines|
          while lines.last =~ pattern
            last_lines.unshift lines.pop
          end
        end
      end

    end
  end
end
