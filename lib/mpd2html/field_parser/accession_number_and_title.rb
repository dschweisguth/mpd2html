require_relative 'base'

module MPD2HTML
  module FieldParser
    class AccessionNumberAndTitle < Base
      ACCESSION_NUMBER = %r(\d{2,4}[./]?\d{3,4}(?:[./]?\d{3,6})?|Unnumbered)
      ACCESSION_NUMBER_SUFFIX = %r([^\d\s]?)

      def self.attribute_names
        %i(accession_number title)
      end

      attr_reader *attribute_names

      private

      def take(input)
        [input.shift] + take_first_lines_matching(input, /^ {19,20}(?! )/)
      end

      def parse(lines)
        line = lines.map(&:strip).join(' ')
        match = line.match /^(#{ACCESSION_NUMBER})(#{ACCESSION_NUMBER_SUFFIX})\s+(Sheet music|Book|Program|Sheet  music):\s*(.*?)(?:\s*\(Popular Title in \w+\))?$/
        if !match
          raise ArgumentError, "No accession number or title"
        end
        @accession_number, accession_number_suffix, format, @title = *match.captures
        if @accession_number !~ /^\d{3}\.\d{3}\.\d{3,5}$/ || accession_number_suffix != ""
          warn "Invalid accession number"
        end
        if format != "Sheet music"
          warn %Q("#{format}" instead of "Sheet music")
        end
      end

    end
  end
end
