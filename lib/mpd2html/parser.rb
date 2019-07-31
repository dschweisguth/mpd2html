require_relative 'item'

module MPD2HTML
  class Parser
    class DuplicateAttributeError < RuntimeError; end

    def initialize
      @item_count = 0
      @invalid_item_count = 0
    end

    def items(files)
      files.map { |file| items_for file }.flatten.tap do
        if @invalid_item_count > 0
          warn "Skipped #{@invalid_item_count} invalid items of #{@item_count} items"
        end
      end
    end

    private def items_for(file)
      IO.readlines(file).
        reject { |line| line =~ /^\s*$/ }.
        reject { |line| line =~ /^Browse List/ }.
        reject { |line| line =~ /^\s*Accession/ }.
        slice_before(/^\s*\d+\.\d+\.\d+/).
        map { |lines| item(lines) }.compact
    end

    def item(lines)
      @item_count += 1
      attrs =
        begin
          lines.
            slice_before(/^(?:\s|\s{21}|\s{23})\b/).
            map { |broken_lines| broken_lines.map(&:strip).join ' ' }.
            each_with_object({}) do |line, attrs|
              case line
                when /(\d{3}\.\d{3}\.\d{5})\s+Sheet music:\s*(.*?)(?:\s*\(Popular Title in English\))?\s*$/
                  set attrs, :accession_number, $1
                  set attrs, :title, $2
                when /\s*(.*?)\s*\((?:Composer|Company)\)/
                  set attrs, :composer, $1
                when /\s*(.*?)\s*\(Lyricist\)/
                  attrs[:lyricist] = $1
                when /\s*(.*?)\s*\[([^\]]+)\]\s*\(Source\)/
                  attrs[:source_name] = $1
                  attrs[:source_type] = $2
                when /^\s*(\d{4})\s*$/
                  attrs[:date] = $1
                when %r(NOW LOCATED: SF PALM, Johnson Sheet Music Collection\s*(.*?)\s*\(\d{4}/\d{2}/\d{2}\)\s*$)
                  attrs[:location] = $1
              end
            end
        rescue DuplicateAttributeError
          nil
        end
      if attrs && Item::REQUIRED_ATTRIBUTES.all? { |attr| attrs.has_key? attr }
        Item.new(**attrs)
      else
        @invalid_item_count += 1
        warn "Skipping invalid item:"
        warn lines
        nil
      end
    end

    private def set(attrs, key, value)
      if attrs[key]
        raise DuplicateAttributeError
      end
      attrs[key] = value
    end

  end
end
