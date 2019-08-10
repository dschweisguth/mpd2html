require_relative 'item'
require_relative 'logger'

module MPD2HTML
  class ParserItem
    ACCESSION_NUMBER = /\d{3}\.\d{3}\.\d{3,6}/

    class DuplicateAttributeError < RuntimeError; end

    def initialize(input)
      @input = input
      @composers = []
      @lyricists = []
      @warnings = []
    end

    def item
      attributes_are_valid = set_attributes
      item =
        if attributes_are_valid
          item_from_attributes
        end
      log_warnings item
      item
    end

    private

    def set_attributes
      @attributes_are_valid = true
      @input.
        slice_before(/^(?: | {21}| {23})(?! )/).
        map { |broken_lines| broken_lines.map(&:strip).join ' ' }.
        each &method(:set_attributes_from)
      if !@accession_number
        @warnings << "No accession number or title"
      end
      if @composers.empty?
        @warnings << "No composer"
      end
      if @lyricists.empty?
        @warnings << "No lyricist"
      end
      if !@source_name
        @warnings << "No source"
      end
      @attributes_are_valid
    end

    def set_attributes_from(line)
      case line
        when /^(#{ACCESSION_NUMBER})([^\d\s]?)\s+(Sheet music|Program):\s*(.*?)(?:\s*\(Popular Title in \w+\))?$/
          set_accession_number_and_title(*Regexp.last_match.captures)
        when /^(.*?)\s*\((Composer|Company)\)$/
          add_composer(*Regexp.last_match.captures)
        when /^(.*?)\s*\(Lyricist\)$/
          @lyricists << $1
        when /^(.*?)\s*\(Composer & Lyricist\)$/
          @composers << $1
          @lyricists << $1
        when /^(.*?)\s*\[([^\]}]+?)((?:\s*-\s*\d{4})?)([\]}])\s*\(Source\)$/
          set_source_name_and_type(*Regexp.last_match.captures)
        when /^(c?\d{4})$/
          set_scalar_attribute :date, $1
        when %r(^NOW LOCATED: SF PALM, Johnson Sheet Music Collection\s*(.*?)\s*\(\d{4}/\d{2}/\d{2}\)$)
          set_scalar_attribute :location, $1
      end
    end

    def set_accession_number_and_title(accession_number, accession_number_suffix, format, title)
      if accession_number !~ /^\d{3}\.\d{3}\.\d{3,5}$/ || accession_number_suffix != ""
        @warnings << "Invalid accession number"
      end
      if format == 'Program'
        @warnings << %Q("Program" instead of "Sheet music")
      end
      if @accession_number
        @warnings << "More than one accession number and title"
        @attributes_are_valid = false
        return
      end
      @accession_number = accession_number
      @title = title
    end

    def add_composer(composer, field_name)
      if field_name != "Composer"
        @warnings << %Q("#{field_name}" instead of "Composer")
      end
      @composers << composer
    end

    def set_source_name_and_type(source_name, source_type, date_in_source_type, source_type_terminator)
      if date_in_source_type != ""
        @warnings << "Source type contains date"
      end
      if source_type_terminator != ']'
        @warnings << "Source type not terminated by ]"
      end
      if @source_name
        @warnings << "More than one source"
        @attributes_are_valid = false
        return
      end
      @source_name = source_name
      @source_type = source_type
    end

    def set_scalar_attribute(name, value)
      instance_variable_name = "@#{name}"
      if instance_variable_get instance_variable_name
        @attributes_are_valid = false
        return
      end
      instance_variable_set instance_variable_name, value
    end

    def item_from_attributes
      begin
        Item.new(
          accession_number: @accession_number,
          title: @title,
          composers: @composers,
          lyricists: @lyricists,
          source_type: @source_type,
          source_name: @source_name,
          date: @date,
          location: @location
        )
      rescue ArgumentError
        nil
      end
    end

    def log_warnings(item)
      if item
        if @warnings.any?
          Logger.warn "Accepting item with warnings: #{@warnings.join '. '}.:\n#{@input.join}"
        end
      else
        if @warnings.any?
          Logger.warn "Skipping item with warnings: #{@warnings.join '. '}.:\n#{@input.join}"
        else
          Logger.warn "Skipping item:\n#{@input.join}" # TODO Dave eliminate
        end
      end
    end

  end
end
