require_relative 'base'

module MPD2HTML
  module FieldParser
    class Location < Base
      def self.attribute_names
        %i(location)
      end

      attr_reader *attribute_names

      PATTERNS = [
        %r((Fort Docs, Regular)),
        %r((SF PALM, Book Truck)),
        %r((SF PALM, Cataloged)),
        %r((SF PALM, Cataloging Shelf)),
        %r((SF PALM, Collection processing)),
        %r((SF PALM, NR)),
        %r((SF PALM, Shenson Research Room(?: Reference(?: [sS]helf)?)?)),
        %r((SF PALM, Shenson Research Room Rererence)),
        %r((SF PALM, Stacks Musical Theater Vocal Scores and Selections)),
        %r((SF PALM, Stacks(?: Sheet Music Reference Collection)?)),
        %r((SF PALM, Stacks Vocal Selections)),
        %r((SF PALM, Stacks Vocal Scores / Selection shelf)),
        %r((SF PALM, Stacks Vocal scores / selections shelf)),
        %r(SF PALM, Johnson Sheet Music Collection\s*(.*?)),
        %r(SF PALM, Shenson Research Room Johnson Rare Sheet Music\s*(.*?)),
        %r(SF PALM, Stacks Johnson Anth\.\s*(.*?)),
        %r(SF PALM, Stacks Johnson Book\s*(.*?)),
        %r(SF PALM, Stacks Johnson Rare Sheet Music\s*(.*?)),
        %r(SF PALM, Stacks Johnson Sheet Music\s*\d+\.\d+\s*(.*?))
      ].map { |location| %r(^NOW LOCATED: #{location}\s*\(\d{4}/\d{2}/\d{2}\)$) }

      private

      def take(input)
        input.dup.tap { input.clear }
      end

      def parse(lines)
        line = lines.map(&:strip).join ' '
        PATTERNS.each do |pattern|
          match = pattern.match line
          if match
            @location = match.captures.first
            break
          end
        end
        if !@location
          raise ArgumentError, "No location"
        end
      end

    end
  end
end
