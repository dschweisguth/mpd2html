require_relative 'field_parser'

module MPD2HTML
  class DateParser < FieldParser
    def self.attribute_names
      %i(dates)
    end

    attr_reader *attribute_names

    def initialize(input)
      super()
      @dates = input.map(&:strip)
      if @dates.empty?
        warn "No date"
      end
    end

  end
end
