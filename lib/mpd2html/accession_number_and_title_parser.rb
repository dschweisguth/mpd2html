require_relative 'attribute_parser'

module MPD2HTML
  class AccessionNumberAndTitleParser < AttributeParser
    ACCESSION_NUMBER = %r(\d{3}[./]?\d{3,4}[./]?\d{3,6}|Unnumbered)

    def self.attribute_names
      %i(accession_number title)
    end

    attr_reader *attribute_names

    def initialize(input)
      super()
      line = input.map(&:strip).join(' ')
      match = line.match /^(#{ACCESSION_NUMBER})([^\d\s]?)\s+(Sheet music|Program):\s*(.*?)(?:\s*\(Popular Title in \w+\))?$/
      if !match
        raise ArgumentError, "No accession number or title"
      end
      @accession_number, accession_number_suffix, format, @title = *match.captures
      if @accession_number !~ /^\d{3}\.\d{3}\.\d{3,5}$/ || accession_number_suffix != ""
        warn "Invalid accession number"
      end
      if format == 'Program'
        warn %Q("Program" instead of "Sheet music")
      end
    end

  end
end
