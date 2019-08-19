require_relative 'field_parser'

module MPD2HTML
  class DateParser < FieldParser
    def self.attribute_names
      %i(dates)
    end

    attr_reader *attribute_names

    def initialize(input)
      super()
      lines = take_last_lines_matching input, /(?:[^)\n]|\(\?\)|^\s*\(\d{4}\))$/
      @dates = lines.map(&:strip)
      if @dates.empty?
        warn "No date"
      end
    end

    private

    def take_last_lines_matching(lines, pattern)
      last_lines = []
      while lines.last =~ pattern
        last_lines.unshift lines.pop
      end
      last_lines
    end

  end
end
