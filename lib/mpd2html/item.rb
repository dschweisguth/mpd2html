require_relative 'accession_number_and_title_parser'
require_relative 'location_parser'
require_relative 'logger'
require_relative 'optional_field_parser'

module MPD2HTML
  class Item
    attr_reader :accession_number, :title, :composers, :lyricists, :source_types, :source_names, :dates, :location

    def initialize(input)
      remaining_input = input.dup
      @warnings = []
      [AccessionNumberAndTitleParser, OptionalFieldParser, LocationParser].each do |parser_class|
        begin
          debrief parser_class.new(remaining_input)
        rescue ArgumentError => e
          Logger.error "Skipping item: #{e.message}:\n#{input.join}"
          raise
        end
      end
      if @warnings.any?
        Logger.warn "Accepting item with warnings: #{@warnings.join '. '}.:\n#{input.join}"
      end
    end

    def debrief(parser)
      parser.class.attribute_names.each do |attr|
        instance_variable_set "@#{attr}", parser.send(attr)
      end
      @warnings += parser.warnings
      parser.parsers.each { |child| debrief child }
    end

    def sort_key
      title.downcase.match(/^(?:\(.*?\)\s*)?['"$]?(?:(?:an?|the)\s+)?['"]?(.*)/).captures[0]
    end

  end
end
