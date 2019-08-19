require_relative 'attribute_parser'

module MPD2HTML
  class LocationParser < AttributeParser
    def self.attribute_names
      %i(location)
    end

    attr_reader *attribute_names

    LOCATION_PATTERNS = [
      %r((Shenson Research Room(?: Reference shelf)?)),
      %r((Stacks)),
      %r(Johnson Sheet Music Collection\s*(.*?)),
      %r(Shenson Research Room Johnson Rare Sheet Music\s*(.*?)),
      %r(Stacks Johnson Rare Sheet Music\s*(.*?)),
      %r(Stacks Johnson Sheet Music\s*\d+\.\d+\s*(.*?))
    ].map { |location| %r(^NOW LOCATED: SF PALM, #{location}\s*\(\d{4}/\d{2}/\d{2}\)$) }

    def initialize(input)
      super()
      line = input.map(&:strip).join ' '
      LOCATION_PATTERNS.each do |pattern|
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
