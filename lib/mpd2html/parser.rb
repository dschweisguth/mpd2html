require_relative 'accession_number_and_title_parser'
require_relative 'item'
require_relative 'logger'

module MPD2HTML
  class Parser
    def initialize
      @item_count = 0
      @invalid_item_count = 0
    end

    def items(files)
      files.map(&method(:items_for)).flatten.tap do
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
        slice_before(/^ #{AccessionNumberAndTitleParser::ACCESSION_NUMBER}#{AccessionNumberAndTitleParser::ACCESSION_NUMBER_SUFFIX}\b/).
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
