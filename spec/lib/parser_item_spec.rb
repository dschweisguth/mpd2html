require_relative '../../lib/mpd2html/parser_item'

module MPD2HTML
  describe ParserItem do
    describe '#item' do
      before do
        allow(Logger).to receive(:warn)
      end

      it "parses an item without warnings" do
        input = [
          " 007.009.00007     Sheet music: I'd Like To Baby You",
          "                     Livingston, Ray (Composer)",
          "                     Evans, Ray (Lyricist)",
          "                     Aaron Slick From Punkin Crick [Film] (Source)",
          "                     1951",
          "                       NOW LOCATED: SF PALM, Johnson Sheet Music Collection Box 1 (2007/02/22)"
        ]
        expected_item = Item.new(
          accession_number: "007.009.00007",
          title: "I'd Like To Baby You",
          composers: ["Livingston, Ray"],
          lyricists: ["Evans, Ray"],
          source_type: "Film",
          source_name: "Aaron Slick From Punkin Crick",
          date: "1951",
          location: "Box 1"
        )
        expect(item input).to eq(expected_item)
      end

      it "accepts Program for Sheet Music" do
        input = [
          " 007.009.00008     Program: Life Is a Beautiful Thing",
          "                     Livingston, Ray (Composer)",
          "                     Evans, Ray (Lyricist)",
          "                     Aaron Slick From Punkin Crick [Film] (Source)",
          "                       NOW LOCATED: SF PALM, Johnson Sheet Music Collection Box 1 (2007/02/22)"
        ]
        expect_item input, { title: "Life Is a Beautiful Thing" }, %q("Program" instead of "Sheet music")
      end

      it "removes '(Popular Title in Language)' from the title" do
        input = [
          " 007.009.00008     Sheet music: Life Is a Beautiful Thing (Popular Title in",
          "                   English)",
          "                     Livingston, Ray (Composer)",
          "                     Evans, Ray (Lyricist)",
          "                     Aaron Slick From Punkin Crick [Film] (Source)",
          "                       NOW LOCATED: SF PALM, Johnson Sheet Music Collection Box 1 (2007/02/22)"
        ]
        expect_item input, title: "Life Is a Beautiful Thing"
      end

      [3, 4, 5].each do |digits|
        it "accepts an accession number with a last part with #{digits} digits" do
          input = [
            " 007.009.#{'1' * digits} Sheet music: Life Is a Beautiful Thing",
            "                     Livingston, Ray (Composer)",
            "                     Evans, Ray (Lyricist)",
            "                     Aaron Slick From Punkin Crick [Film] (Source)",
            "                       NOW LOCATED: SF PALM, Johnson Sheet Music Collection Box 1 (2007/02/22)"
          ]
          expect_item input, title: "Life Is a Beautiful Thing"
        end
      end

      it "accepts an accession number with a last part with 6 digits" do
        input = [
          " 007.009.123456    Sheet music: Life Is a Beautiful Thing",
          "                     Livingston, Ray (Composer)",
          "                     Evans, Ray (Lyricist)",
          "                     Aaron Slick From Punkin Crick [Film] (Source)",
          "                       NOW LOCATED: SF PALM, Johnson Sheet Music Collection Box 1 (2007/02/22)"
        ]
        expect_item input, { title: "Life Is a Beautiful Thing" }, "Invalid accession number"
      end

      it "accepts and ignores a J after the accession number" do
        input = [
          " 007.009.00008J    Sheet music: Life Is a Beautiful Thing",
          "                     Livingston, Ray (Composer)",
          "                     Evans, Ray (Lyricist)",
          "                     Aaron Slick From Punkin Crick [Film] (Source)",
          "                       NOW LOCATED: SF PALM, Johnson Sheet Music Collection Box 1 (2007/02/22)"
        ]
        expect_item input, { title: "Life Is a Beautiful Thing" }, "Invalid accession number"
      end

      it "rejects an item with no accession number or title" do
        input = [
          "                     Livingston, Ray (Composer)",
          "                     Evans, Ray (Lyricist)",
          "                     Aaron Slick From Punkin Crick [Film] (Source)",
          "                     1951",
          "                       NOW LOCATED: SF PALM, Johnson Sheet Music Collection Box 1 (2007/02/22)"
        ]
        expect_to_be_invalid input, "No accession number or title"
      end

      it "rejects an item with more than one accession number and title" do
        input = [
          " 007.009.00007     Sheet music: I'd Like To Baby You",
          " 007.009.00007     Sheet music: I'd Like To Baby You",
          "                     Livingston, Ray (Composer)",
          "                     Evans, Ray (Lyricist)",
          "                     Aaron Slick From Punkin Crick [Film] (Source)",
          "                     1951",
          "                       NOW LOCATED: SF PALM, Johnson Sheet Music Collection Box 1 (2007/02/22)"
        ]
        expect_to_be_invalid input, "More than one accession number and title"
      end

      it "accepts Company for Composer" do
        input = [
          " 007.009.00007     Sheet music: I'd Like To Baby You",
          "                     Livingston, Ray (Company)",
          "                     Evans, Ray (Lyricist)",
          "                     Aaron Slick From Punkin Crick [Film] (Source)",
          "                     1951",
          "                       NOW LOCATED: SF PALM, Johnson Sheet Music Collection Box 1 (2007/02/22)"
        ]
        expect_item input, { composers: ["Livingston, Ray"] }, %Q("Company" instead of "Composer")
      end

      it "accepts multiple composers" do
        input = [
          " 007.009.00007     Sheet music: I'd Like To Baby You",
          "                     Livingston, Jay (Composer)",
          "                     Livingston, Ray (Composer)",
          "                     Evans, Ray (Lyricist)",
          "                     Aaron Slick From Punkin Crick [Film] (Source)",
          "                     1951",
          "                       NOW LOCATED: SF PALM, Johnson Sheet Music Collection Box 1 (2007/02/22)"
        ]
        expect_item input, composers: ["Livingston, Jay", "Livingston, Ray"]
      end

      it "rejects an item with no composer" do
        input = [
          " 007.009.00007     Sheet music: I'd Like To Baby You",
          "                     Evans, Ray (Lyricist)",
          "                     Aaron Slick From Punkin Crick [Film] (Source)",
          "                     1951",
          "                       NOW LOCATED: SF PALM, Johnson Sheet Music Collection Box 1 (2007/02/22)"
        ]
        expect_to_be_invalid input, "No composer"
      end

      it "accepts an item with no lyricist" do
        input = [
          " 007.009.00007     Sheet music: I'd Like To Baby You",
          "                     Livingston, Ray (Composer)",
          "                     Aaron Slick From Punkin Crick [Film] (Source)",
          "                     1951",
          "                       NOW LOCATED: SF PALM, Johnson Sheet Music Collection Box 1 (2007/02/22)"
        ]
        expect_item input, { lyricists: [] }, "No lyricist"
      end

      it "accepts multiple lyricists" do
        input = [
          " 007.009.00007     Sheet music: I'd Like To Baby You",
          "                     Livingston, Ray (Composer)",
          "                     Evans, Jay (Lyricist)",
          "                     Evans, Ray (Lyricist)",
          "                     Aaron Slick From Punkin Crick [Film] (Source)",
          "                     1951",
          "                       NOW LOCATED: SF PALM, Johnson Sheet Music Collection Box 1 (2007/02/22)"
        ]
        expect_item input, lyricists: ["Evans, Jay", "Evans, Ray"]
      end

      it "handles Composer & Lyricist" do
        input = [
          " 007.009.00007     Sheet music: I'd Like To Baby You",
          "                     Livingston, Ray (Composer & Lyricist)",
          "                     Aaron Slick From Punkin Crick [Film] (Source)",
          "                     1951",
          "                       NOW LOCATED: SF PALM, Johnson Sheet Music Collection Box 1 (2007/02/22)"
        ]
        expect_item input, composers: ["Livingston, Ray"], lyricists: ["Livingston, Ray"]
      end

      it "accepts an item with no source" do
        input = [
          " 007.009.00007     Sheet music: I'd Like To Baby You",
          "                     Livingston, Ray (Composer)",
          "                     Evans, Ray (Lyricist)",
          "                     1951",
          "                       NOW LOCATED: SF PALM, Johnson Sheet Music Collection Box 1 (2007/02/22)"
        ]
        expect_item input, { source_name: nil, source_type: nil }, "No source"
      end

      it "ignores a date in the source type" do
        input = [
          " 007.009.00007     Sheet music: I'd Like To Baby You",
          "                     Livingston, Ray (Composer)",
          "                     Evans, Ray (Lyricist)",
          "                     Aaron Slick From Punkin Crick [Film - 1951] (Source)",
          "                     1951",
          "                       NOW LOCATED: SF PALM, Johnson Sheet Music Collection Box 1 (2007/02/22)"
        ]
        expect_item input, source_type: "Film"
      end

      it "recognizes a source type terminated by }" do
        input = [
          " 007.009.00007     Sheet music: I'd Like To Baby You",
          "                     Livingston, Ray (Composer)",
          "                     Evans, Ray (Lyricist)",
          "                     Aaron Slick From Punkin Crick [Film} (Source)",
          "                     1951",
          "                       NOW LOCATED: SF PALM, Johnson Sheet Music Collection Box 1 (2007/02/22)"
        ]
        expect_item input, source_type: "Film"
      end

      it "rejects an item with more than one source" do
        input = [
          " 007.009.00007     Sheet music: I'd Like To Baby You",
          "                     Livingston, Ray (Composer)",
          "                     Evans, Ray (Lyricist)",
          "                     Aaron Slick From Punkin Crick [Film] (Source)",
          "                     Aaron Slick From Punkin Crick [Film] (Source)",
          "                     1951",
          "                       NOW LOCATED: SF PALM, Johnson Sheet Music Collection Box 1 (2007/02/22)"
        ]
        expect_to_be_invalid input
      end

      it "accepts an item with no date" do
        input = [
          " 007.009.00007     Sheet music: I'd Like To Baby You",
          "                     Livingston, Ray (Composer)",
          "                     Evans, Ray (Lyricist)",
          "                     Aaron Slick From Punkin Crick [Film] (Source)",
          "                       NOW LOCATED: SF PALM, Johnson Sheet Music Collection Box 1 (2007/02/22)"
        ]
        expect_item input, date: nil
      end

      it "accepts a date beginning with c" do
        input = [
          " 007.009.00007     Sheet music: I'd Like To Baby You",
          "                     Livingston, Ray (Composer)",
          "                     Evans, Ray (Lyricist)",
          "                     Aaron Slick From Punkin Crick [Film] (Source)",
          "                     c1951",
          "                       NOW LOCATED: SF PALM, Johnson Sheet Music Collection Box 1 (2007/02/22)"
        ]
        expect_item input, date: "c1951"
      end

      it "rejects an item with more than one date" do
        input = [
          " 007.009.00007     Sheet music: I'd Like To Baby You",
          "                     Livingston, Ray (Composer)",
          "                     Evans, Ray (Lyricist)",
          "                     Aaron Slick From Punkin Crick [Film] (Source)",
          "                     1951",
          "                     1951",
          "                       NOW LOCATED: SF PALM, Johnson Sheet Music Collection Box 1 (2007/02/22)"
        ]
        expect_to_be_invalid input
      end

      it "handles a continued location" do
        input = [
          " 007.009.00007     Sheet music: I'd Like To Baby You",
          "                     Livingston, Ray (Composer)",
          "                     Evans, Ray (Lyricist)",
          "                     Aaron Slick From Punkin Crick [Film] (Source)",
          "                     1951",
          "                       NOW LOCATED: SF PALM, Johnson Sheet Music Collection Box",
          "                   1 (2007/02/22)"
        ]
        expect(item(input).location).to eq("Box 1")
      end

      it "rejects an item with no location" do
        input = [
          " 007.009.00007     Sheet music: I'd Like To Baby You",
          "                     Livingston, Ray (Composer)",
          "                     Evans, Ray (Lyricist)",
          "                     Aaron Slick From Punkin Crick [Film] (Source)",
          "                     1951"
        ]
        expect_to_be_invalid input
      end

      it "rejects an item with more than one location" do
        input = [
          " 007.009.00007     Sheet music: I'd Like To Baby You",
          "                     Livingston, Ray (Composer)",
          "                     Evans, Ray (Lyricist)",
          "                     Aaron Slick From Punkin Crick [Film] (Source)",
          "                     1951",
          "                       NOW LOCATED: SF PALM, Johnson Sheet Music Collection Box 1 (2007/02/22)",
          "                       NOW LOCATED: SF PALM, Johnson Sheet Music Collection Box 1 (2007/02/22)"
        ]
        expect_to_be_invalid input
      end

      it "handles fields beginning with non-word characters" do
        input = [
          " 007.009.00007     Sheet music: I'd Like To Baby You",
          "                     Livingston, Ray (Composer)",
          "                     Evans, Ray (Lyricist)",
          "                     $ Dollars $ [Film] (Source)",
          "                     1951",
          "                       NOW LOCATED: SF PALM, Johnson Sheet Music Collection Box 1 (2007/02/22)"
        ]
        expect_item input, lyricists: ["Evans, Ray"], source_name: "$ Dollars $"
      end

      def expect_item(input, attrs, *warnings)
        item = item input
        attrs.each do |name, value|
          expect(item.send name).to eq(value)
        end
        if warnings.any?
          expect(Logger).to have_received(:warn).with("Accepting item with warnings: #{warnings.join '. '}.:\n#{input.join}")
        else
          expect(Logger).not_to have_received(:warn)
        end
      end

      def expect_to_be_invalid(input, *warnings)
        expect(item(input)).to be_nil
        if warnings.any?
          expect(Logger).to have_received(:warn).with("Skipping item with warnings: #{warnings.join '. '}.:\n#{input.join}")
        else
          expect(Logger).to have_received(:warn).with("Skipping item:\n#{input.join}")
        end
      end

      def item(item)
        described_class.new(item).item
      end

    end
  end
end
