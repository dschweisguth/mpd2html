require_relative 'parser_item'

module MPD2HTML
  class Parser
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

    private

    def items_for(file)
      IO.readlines(file).
        reject { |line| [/^\s*$/, /^Browse List/, /^\s*Accession/].any? { |re| re.match? line } }.
        slice_before(/^\s*\d+\.\d+\.\d+/).
        map do |lines|
          @item_count += 1
          ParserItem.new(lines).item.tap do |the_item|
            if the_item.nil?
              @invalid_item_count += 1
            end
          end
        end.
        compact
    end

  end
end
