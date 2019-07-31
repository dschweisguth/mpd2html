require_relative 'item'

module MPD2HTML
  class ParserItem
    class DuplicateAttributeError < RuntimeError; end

    def initialize(lines)
      @lines = lines
      @attrs = {}
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
      if valid && Item::REQUIRED_ATTRIBUTES.all? { |attr| @attrs.has_key? attr }
        Item.new **@attrs
      else
        warn "Skipping invalid item:"
        warn @lines
        nil
      end
    end

    private

    def set_attributes_from(line)
      case line
        when /^(\d{3}\.\d{3}\.\d{5})\s+Sheet music:\s*(.*?)(?:\s*\(Popular Title in English\))?\s*$/
          set :accession_number, $1
          set :title, $2
        when /^(.*?)\s*\((?:Composer|Company)\)\s*$/
          set :composer, $1
        when /^(.*?)\s*\(Lyricist\)\s*$/
          set :lyricist, $1
        when /^(.*?)\s*\[([^\]]+)\]\s*\(Source\)\s*$/
          set :source_name, $1
          set :source_type, $2
        when /^(\d{4})\s*$/
          set :date, $1
        when %r(^NOW LOCATED: SF PALM, Johnson Sheet Music Collection\s*(.*?)\s*\(\d{4}/\d{2}/\d{2}\)\s*$)
          set :location, $1
      end
    end

    def set(key, value)
      if @attrs[key]
        raise DuplicateAttributeError
      end
      @attrs[key] = value
    end

  end
end
