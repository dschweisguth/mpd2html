require_relative 'field_parser/accession_number_and_title'
require_relative 'field_parser/location'
require_relative 'field_parser/optional_field'
require_relative 'logger'

module MPD2HTML
  class Item
    attr_reader :accession_number, :title, :composers, :lyricists, :source_types, :source_names, :dates, :location

    def initialize(input)
      remaining_input = input.dup
      @warnings = []
      [FieldParser::AccessionNumberAndTitle, FieldParser::OptionalField, FieldParser::Location].each do |parser_class|
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

    private def debrief(parser)
      parser.class.attribute_names.each do |attr|
        instance_variable_set "@#{attr}", parser.send(attr)
      end
      @warnings += parser.warnings
      parser.parsers.each { |child| debrief child }
    end

    def sort_key(primary_sort_attribute)
      key = [sort_key_for_title, sort_key_for_source_names, sort_key_for_source_types, accession_number]
      case primary_sort_attribute
        when :composers
          key.unshift sort_key_for_names(composers)
        when :lyricists
          key.unshift sort_key_for_names(lyricists)
      end
      key
    end

    SOURCE_NAME_PATTERN = /['"$]?(?:(?:an?|the)\s+)?['"]?(.*)/

    private def sort_key_for_title
      sort_key_for_title_or_source_name title, /^(?:\(.*?\)\s*)?#{SOURCE_NAME_PATTERN}/
    end

    private def sort_key_for_names(names)
      if names.any?
        names.map { |name| name.downcase.match(/^\(?(.*)/).captures[0] }
      else
        ["~"]
      end
    end

    private def sort_key_for_source_names
      source_names.map { |source_name| sort_key_for_title_or_source_name(source_name, /^#{SOURCE_NAME_PATTERN}/) }
    end

    private def sort_key_for_source_types
      source_types.map { |source_type| source_type.nil? ? '~' : source_type }
    end

    private def sort_key_for_title_or_source_name(attribute, pattern)
      key = attribute.downcase.match(pattern).captures[0]
      if key.empty?
        '~'
      else
        key
      end
    end

    def ==(other)
      other.class == self.class && other.state == state
    end

    alias eql? ==

    def hash
      state.map(&:hash).inject :^
    end

    protected def state
      instance_variables.
        reject { |var| var == :@warnings }.
        map { |variable| instance_variable_get variable }
    end
  end
end
