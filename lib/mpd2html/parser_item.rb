require_relative 'item'

module MPD2HTML
  class ParserItem
    ACCESSION_NUMBER = /\d{3}\.\d{3}\.\d{5}/

    class DuplicateAttributeError < RuntimeError; end

    def initialize(lines)
      @lines = lines
      @accession_number = nil
      @title = nil
      @composers = []
      @lyricists = []
      @source_name = nil
      @source_type = nil
      @date = nil
    end

    def item
      valid =
        begin
          @lines.
            slice_before(/^(?: | {21}| {23})\b/).
            map { |broken_lines| broken_lines.map(&:strip).join ' ' }.
            each &method(:set_attributes_from)
          true
        rescue DuplicateAttributeError
          false
        end
      item =
        if valid
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
            valid = false
            nil
          end
        end
      if valid
        item
      else
        warn "Skipping invalid item:"
        warn @lines
        nil
      end
    end

    private

    def set_attributes_from(line)
      case line
        when /^(#{ACCESSION_NUMBER})\s+Sheet music:\s*(.*?)(?:\s*\(Popular Title in English\))?\s*$/
          self.accession_number = $1
          self.title = $2
        when /^(.*?)\s*\((?:Composer|Company)\)\s*$/
          @composers << $1
        when /^(.*?)\s*\(Lyricist\)\s*$/
          @lyricists << $1
        when /^(.*?)\s*\[([^\]}]+?)(?:\s*-\s*\d{4})?(?:[\]}])\s*\(Source\)\s*$/
          self.source_name = $1
          self.source_type = $2
        when /^(c?\d{4})\s*$/
          self.date = $1
        when %r(^NOW LOCATED: SF PALM, Johnson Sheet Music Collection\s*(.*?)\s*\(\d{4}/\d{2}/\d{2}\)\s*$)
          self.location = $1
      end
    end

    def accession_number=(accession_number)
      set_scalar_attribute :accession_number, accession_number
    end

    def title=(title)
      set_scalar_attribute :title, title
    end

    def source_name=(source_name)
      set_scalar_attribute :source_name, source_name
    end

    def source_type=(source_type)
      set_scalar_attribute :source_type, source_type
    end

    def date=(date)
      set_scalar_attribute :date, date
    end

    def location=(location)
      set_scalar_attribute :location, location
    end

    def set_scalar_attribute(name, value)
      instance_variable_name = "@#{name}"
      if instance_variable_get instance_variable_name
        raise DuplicateAttributeError
      end
      instance_variable_set instance_variable_name, value
    end

  end
end
