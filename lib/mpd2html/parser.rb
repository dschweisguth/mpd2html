require_relative 'logger'
require_relative 'parser_item'

module MPD2HTML
  class Parser
    def initialize
      @item_count = 0
      @invalid_item_count = 0
    end

    def items(files)
      files.map(&method(:items_for)).flatten.tap do
        if @invalid_item_count > 0
          Logger.warn "Skipped #{@invalid_item_count} invalid items of #{@item_count} items"
        end
      end
    end

    private

    def items_for(file)
      IO.readlines(file).
        reject { |line| [/^\s*$/, /^Browse List/, /^\s*Accession/].any? { |re| re.match? line } }.
        slice_before(/^\s*#{ParserItem::ACCESSION_NUMBER}[^\d\s+]?\b/).
        each_with_object([]) do |lines, items|
          @item_count += 1
          item = ParserItem.new(lines).item
          if item
            items << item
          else
            @invalid_item_count += 1
          end
        end
    end

  end
end
