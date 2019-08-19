require_relative 'accession_number_and_title_parser'
require_relative 'date_parser'
require_relative 'location_parser'
require_relative 'logger'
require_relative 'optional_field_parser'

module MPD2HTML
  class Item
    attr_reader :accession_number, :title, :composers, :lyricists, :source_types, :source_names, :dates, :location

    def initialize(input)
      @input = input.freeze
      @warnings = []
      remaining_input = @input.dup
      accession_number_and_title_lines = take_accession_number_and_title_lines remaining_input
      parse_with AccessionNumberAndTitleParser, accession_number_and_title_lines
      optional_field_lines, date_lines = take_optional_field_and_date_lines remaining_input
      parse_with OptionalFieldParser, optional_field_lines
      parse_with DateParser, date_lines
      parse_with LocationParser, remaining_input
      if @warnings.any?
        Logger.warn "Accepting item with warnings: #{@warnings.join '. '}.:\n#{@input.join}"
      end
    end

    private

    def take_accession_number_and_title_lines(input)
      [input.shift] + first_lines_matching(input, /^ {19,20}(?! )/)
    end

    def take_optional_field_and_date_lines(input)
      optional_field_lines = first_lines_matching input, /^ {21,22}(?! )/
      date_lines = last_lines_not_matching optional_field_lines, /\)$/
      [optional_field_lines, date_lines]
    end

    def first_lines_matching(lines, pattern)
      first_lines = []
      while lines.first =~ pattern
        first_lines << lines.shift
      end
      first_lines
    end

    def last_lines_not_matching(lines, pattern)
      last_lines = []
      while lines.any? && lines.last !~ pattern
        last_lines.unshift lines.pop
      end
      last_lines
    end

    def parse_with(parser_class, lines)
      begin
        parser = parser_class.new lines
        parser_class.attribute_names.each do |attr|
          instance_variable_set "@#{attr}", parser.send(attr)
        end
        @warnings += parser.warnings
      rescue ArgumentError => e
        Logger.error "Skipping item: #{e.message}:\n#{@input.join}"
        raise
      end
    end

  end
end
