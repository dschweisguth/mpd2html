require_relative 'attribute_parser'

module MPD2HTML
  class LocationParser < AttributeParser
    def self.attribute_names
      %i(location)
    end

    attr_reader *attribute_names

    LOCATION_PATTERNS = [
      %r(^NOW LOCATED: SF PALM, Johnson Sheet Music Collection\s*(.*?)\s*\(\d{4}/\d{2}/\d{2}\)$),
      %r(^NOW LOCATED: SF PALM, (Shenson Research Room(?: Reference shelf)?)\s*\(\d{4}/\d{2}/\d{2}\)$),
      %r(^NOW LOCATED: SF PALM, Shenson Research Room Johnson Rare Sheet Music\s*(.*?)\s*\(\d{4}/\d{2}/\d{2}\)$),
      %r(^NOW LOCATED: SF PALM, (Stacks)\s*\(\d{4}/\d{2}/\d{2}\)$),
      %r(^NOW LOCATED: SF PALM, Stacks Johnson Rare Sheet Music\s*(.*?)\s*\(\d{4}/\d{2}/\d{2}\)$),
      %r(^NOW LOCATED: SF PALM, Stacks Johnson Sheet Music\s*\d+\.\d+\s*(.*?)\s*\(\d{4}/\d{2}/\d{2}\)$)
    ]

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
