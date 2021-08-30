require_relative 'field_parser/accession_number_and_title'
require_relative 'item'
require_relative 'logger'

module MPD2HTML
  class Parser
    def initialize
      @item_count = 0
      @invalid_item_count = 0
    end

    def items(files)
      files.
        flat_map(&method(:items_for)).
        uniq.
        tap do
          if @invalid_item_count > 0
            Logger.error "Skipped #{@invalid_item_count} invalid items of #{@item_count} items"
          else
            Logger.warn "Converted #{@item_count} items"
          end
        end
    end

    private

    def items_for(file)
      IO.readlines(file).
        reject { |line| [/^\s*$/, /^Browse List/, /^\s*Accession/].any? { |re| re.match? line } }.
        slice_before(/^ #{FieldParser::AccessionNumberAndTitle::ACCESSION_NUMBER}#{FieldParser::AccessionNumberAndTitle::ACCESSION_NUMBER_SUFFIX}\b/).
        each_with_object([]) do |lines, items|
          @item_count += 1
          begin
            items << Item.new(lines)
          rescue ArgumentError
            @invalid_item_count += 1
          end
        end
    end

  end
end
