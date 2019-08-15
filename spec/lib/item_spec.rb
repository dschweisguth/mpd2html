require_relative '../../lib/mpd2html/item'

module MPD2HTML
  describe Item do
    describe '.new' do
      before do
        allow(Logger).to receive(:error)
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
        expected_attrs = {
          accession_number: "007.009.00007",
          title: "I'd Like To Baby You",
          composers: ["Livingston, Ray"],
          lyricists: ["Evans, Ray"],
          source_types: ["Film"],
          source_names: ["Aaron Slick From Punkin Crick"],
          dates: ["1951"],
          location: "Box 1"
        }
        expect_item input, expected_attrs
      end

      it "accepts Program for Sheet Music" do
        input = [
          " 007.009.00008     Program: Life Is a Beautiful Thing",
          "                     Livingston, Ray (Composer)",
          "                     Evans, Ray (Lyricist)",
          "                     Aaron Slick From Punkin Crick [Film] (Source)",
          "                     1951",
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
          "                     1951",
          "                       NOW LOCATED: SF PALM, Johnson Sheet Music Collection Box 1 (2007/02/22)"
        ]
        expect_item input, title: "Life Is a Beautiful Thing"
      end

      it "accepts an accession number missing the first ." do
        input = [
          " 007009.12345      Sheet music: Life Is a Beautiful Thing",
          "                     Livingston, Ray (Composer)",
          "                     Evans, Ray (Lyricist)",
          "                     Aaron Slick From Punkin Crick [Film] (Source)",
          "                     1951",
          "                       NOW LOCATED: SF PALM, Johnson Sheet Music Collection Box 1 (2007/02/22)"
        ]
        expect_item input, { title: "Life Is a Beautiful Thing" }, "Invalid accession number"
      end

      it "accepts an accession number with / in place of the first ." do
        input = [
          " 007/009.12345     Sheet music: Life Is a Beautiful Thing",
          "                     Livingston, Ray (Composer)",
          "                     Evans, Ray (Lyricist)",
          "                     Aaron Slick From Punkin Crick [Film] (Source)",
          "                     1951",
          "                       NOW LOCATED: SF PALM, Johnson Sheet Music Collection Box 1 (2007/02/22)"
        ]
        expect_item input, { title: "Life Is a Beautiful Thing" }, "Invalid accession number"
      end

      it "accepts an accession number with a second part with 4 digits" do
        input = [
          " 007.0090.12345    Sheet music: Life Is a Beautiful Thing",
          "                     Livingston, Ray (Composer)",
          "                     Evans, Ray (Lyricist)",
          "                     Aaron Slick From Punkin Crick [Film] (Source)",
          "                     1951",
          "                       NOW LOCATED: SF PALM, Johnson Sheet Music Collection Box 1 (2007/02/22)"
        ]
        expect_item input, { title: "Life Is a Beautiful Thing" }, "Invalid accession number"
      end

      [3, 4, 5].each do |digits|
        it "accepts an accession number with a last part with #{digits} digits" do
          input = [
            " 007.009.#{'1' * digits} Sheet music: Life Is a Beautiful Thing",
            "                     Livingston, Ray (Composer)",
            "                     Evans, Ray (Lyricist)",
            "                     Aaron Slick From Punkin Crick [Film] (Source)",
            "                     1951",
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
          "                     1951",
          "                       NOW LOCATED: SF PALM, Johnson Sheet Music Collection Box 1 (2007/02/22)"
        ]
        expect_item input, { title: "Life Is a Beautiful Thing" }, "Invalid accession number"
      end

      it "accepts an accession number missing the second ." do
        input = [
          " 007.00912345      Sheet music: Life Is a Beautiful Thing",
          "                     Livingston, Ray (Composer)",
          "                     Evans, Ray (Lyricist)",
          "                     Aaron Slick From Punkin Crick [Film] (Source)",
          "                     1951",
          "                       NOW LOCATED: SF PALM, Johnson Sheet Music Collection Box 1 (2007/02/22)"
        ]
        expect_item input, { title: "Life Is a Beautiful Thing" }, "Invalid accession number"
      end

      it "accepts an accession number with / in place of the second ." do
        input = [
          " 007.009/12345     Sheet music: Life Is a Beautiful Thing",
          "                     Livingston, Ray (Composer)",
          "                     Evans, Ray (Lyricist)",
          "                     Aaron Slick From Punkin Crick [Film] (Source)",
          "                     1951",
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
          "                     1951",
          "                       NOW LOCATED: SF PALM, Johnson Sheet Music Collection Box 1 (2007/02/22)"
        ]
        expect_item input, { title: "Life Is a Beautiful Thing" }, "Invalid accession number"
      end

      it "accepts an Unnnumbered accession number" do
        input = [
          " Unnumbered        Sheet music: Life Is a Beautiful Thing",
          "                     Livingston, Ray (Composer)",
          "                     Evans, Ray (Lyricist)",
          "                     Aaron Slick From Punkin Crick [Film] (Source)",
          "                     1951",
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

      it "accepts an item with no composer" do
        input = [
          " 007.009.00007     Sheet music: I'd Like To Baby You",
          "                     Evans, Ray (Lyricist)",
          "                     Aaron Slick From Punkin Crick [Film] (Source)",
          "                     1951",
          "                       NOW LOCATED: SF PALM, Johnson Sheet Music Collection Box 1 (2007/02/22)"
        ]
        expect_item input, { composers: [] }, "No composer"
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
        expect_item input, { source_names: [], source_types: [] }, ["No source"]
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
        expect_item input, { source_types: ["Film"] }, "Source type contains date"
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
        expect_item input, { source_types: ["Film"] }, "Source type not terminated by ]"
      end

      it "accepts an item with more than one source" do
        input = [
          " 007.009.00007     Sheet music: I'd Like To Baby You",
          "                     Livingston, Ray (Composer)",
          "                     Evans, Ray (Lyricist)",
          "                     Aaron Slick From Punkin Crick 1 [Stage] (Source)",
          "                     Aaron Slick From Punkin Crick 2 [Film] (Source)",
          "                     1951",
          "                       NOW LOCATED: SF PALM, Johnson Sheet Music Collection Box 1 (2007/02/22)"
        ]
        expected_attrs = {
          source_types: ["Stage", "Film"],
          source_names: ["Aaron Slick From Punkin Crick 1", "Aaron Slick From Punkin Crick 2"]
        }
        expect_item input, expected_attrs
      end

      it "accepts an item with no date" do
        input = [
          " 007.009.00007     Sheet music: I'd Like To Baby You",
          "                     Livingston, Ray (Composer)",
          "                     Evans, Ray (Lyricist)",
          "                     Aaron Slick From Punkin Crick [Film] (Source)",
          "                       NOW LOCATED: SF PALM, Johnson Sheet Music Collection Box 1 (2007/02/22)"
        ]
        expect_item input, { dates: [] }, "No date"
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
        expect_item input, dates: ["c1951"]
      end

      it "accepts an item with more than one date" do
        input = [
          " 007.009.00007     Sheet music: I'd Like To Baby You",
          "                     Livingston, Ray (Composer)",
          "                     Evans, Ray (Lyricist)",
          "                     Aaron Slick From Punkin Crick [Film] (Source)",
          "                     1951",
          "                     1952",
          "                       NOW LOCATED: SF PALM, Johnson Sheet Music Collection Box 1 (2007/02/22)"
        ]
        expect_item input, dates: ["1951", "1952"]
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

      it "handles the Stacks location format" do
        input = [
          " 007.009.00007     Sheet music: I'd Like To Baby You",
          "                     Livingston, Ray (Composer)",
          "                     Evans, Ray (Lyricist)",
          "                     Aaron Slick From Punkin Crick [Film] (Source)",
          "                     1951",
          "                       NOW LOCATED: SF PALM, Stacks (2007/02/22)"
        ]
        expect(item(input).location).to eq("Stacks")
      end

      it "handles the Stacks Johnson Rare Sheet Music location format" do
        input = [
          " 007.009.00007     Sheet music: I'd Like To Baby You",
          "                     Livingston, Ray (Composer)",
          "                     Evans, Ray (Lyricist)",
          "                     Aaron Slick From Punkin Crick [Film] (Source)",
          "                     1951",
          "                       NOW LOCATED: SF PALM, Stacks Johnson Rare Sheet Music Box 1 (2007/02/22)"
        ]
        expect(item(input).location).to eq("Box 1")
      end

      it "handles the Stacks Johnson Sheet Music location format" do
        input = [
          " 007.009.00007     Sheet music: I'd Like To Baby You",
          "                     Livingston, Ray (Composer)",
          "                     Evans, Ray (Lyricist)",
          "                     Aaron Slick From Punkin Crick [Film] (Source)",
          "                     1951",
          "                       NOW LOCATED: SF PALM, Stacks Johnson Sheet Music 007.016 Box 1 (2007/02/22)"
        ]
        expect(item(input).location).to eq("Box 1")
      end

      ["Shenson Research Room", "Shenson Research Room Reference shelf"].each do |location|
        it "handles the #{location}" do
          input = [
            " 007.009.00007     Sheet music: I'd Like To Baby You",
            "                     Livingston, Ray (Composer)",
            "                     Evans, Ray (Lyricist)",
            "                     Aaron Slick From Punkin Crick [Film] (Source)",
            "                     1951",
            "                       NOW LOCATED: SF PALM, #{location} (2007/02/22)"
          ]
          expect(item(input).location).to eq(location)
        end
      end

      it "rejects an item with no location" do
        input = [
          " 007.009.00007     Sheet music: I'd Like To Baby You",
          "                     Livingston, Ray (Composer)",
          "                     Evans, Ray (Lyricist)",
          "                     Aaron Slick From Punkin Crick [Film] (Source)",
          "                     1951"
        ]
        expect_to_be_invalid input, "No location"
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
        expect_to_be_invalid input, "More than one location"
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
        expect_item input, lyricists: ["Evans, Ray"], source_names: ["$ Dollars $"]
      end

      it "warns of an unparseable line" do
        input = [
          " 007.009.00007     Sheet music: I'd Like To Baby You",
          "                     Livingston, Ray (Composer)",
          "                     Evans, Ray (Lyricist)",
          "                     Buffalo, Biff (Dramaturge)",
          "                     Aaron Slick From Punkin Crick [Film] (Source)",
          "                     1951",
          "                       NOW LOCATED: SF PALM, Johnson Sheet Music Collection Box 1 (2007/02/22)"
        ]
        expect_item input, {}, %q(Unparseable line: "Buffalo, Biff (Dramaturge)")
      end

      def expect_item(input, attrs, *warnings)
        item = item input
        attrs.each do |name, value|
          expect(item.send name).to eq(value)
        end
        expect(Logger).not_to have_received(:error)
        if warnings.any?
          expect(Logger).to have_received(:warn).with("Accepting #{item_with warnings, input}")
        else
          expect(Logger).not_to have_received(:warn)
        end
      end

      def expect_to_be_invalid(input, *warnings)
        expect { item input }.to raise_error ArgumentError, concatenated(warnings)
        expect(Logger).to have_received(:error).with("Skipping #{item_with warnings, input}")
        expect(Logger).not_to have_received(:warn)
      end

      def item(input)
        described_class.new input
      end

      def item_with(warnings, input)
        "item with warnings: #{concatenated warnings}:\n#{input.join}"
      end

      def concatenated(warnings)
        "#{warnings.join '. '}."
      end

    end
  end
end
