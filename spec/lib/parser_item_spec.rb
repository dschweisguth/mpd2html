require_relative '../../lib/mpd2html/parser_item'

module MPD2HTML
  describe ParserItem do
    describe '#item' do
      before do
        allow(Logger).to receive(:warn)
      end

      it "parses a valid item" do
        item = [
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
        expect(item item).to eq(expected_item)
      end

      it "accepts Program for Sheet Music" do
        item = [
          " 007.009.00008     Program: Life Is a Beautiful Thing",
          "                     Livingston, Ray (Composer)",
          "                     Evans, Ray (Lyricist)",
          "                     Aaron Slick From Punkin Crick [Film] (Source)",
          "                       NOW LOCATED: SF PALM, Johnson Sheet Music Collection Box 1 (2007/02/22)"
        ]
        expect(item(item).title).to eq("Life Is a Beautiful Thing")
        expect(Logger).to have_received(:warn).with(%Q(Accepting "Program" for "Sheet music":\n#{item}))
      end

      it "removes '(Popular Title in Language)' from the title" do
        item = [
          " 007.009.00008     Sheet music: Life Is a Beautiful Thing (Popular Title in",
          "                   English)",
          "                     Livingston, Ray (Composer)",
          "                     Evans, Ray (Lyricist)",
          "                     Aaron Slick From Punkin Crick [Film] (Source)",
          "                       NOW LOCATED: SF PALM, Johnson Sheet Music Collection Box 1 (2007/02/22)"
        ]
        expect(item(item).title).to eq("Life Is a Beautiful Thing")
      end

      [3, 4, 5, 6].each do |digits|
        it "allows an accession number with a last part with #{digits} digits" do
          item = [
            " 007.009.#{'1' * digits} Sheet music: Life Is a Beautiful Thing",
            "                     Livingston, Ray (Composer)",
            "                     Evans, Ray (Lyricist)",
            "                     Aaron Slick From Punkin Crick [Film] (Source)",
            "                       NOW LOCATED: SF PALM, Johnson Sheet Music Collection Box 1 (2007/02/22)"
          ]
          expect(item(item).title).to eq("Life Is a Beautiful Thing")
        end
      end

      it "allows and ignores a J after the accession number" do
        item = [
          " 007.009.00008J    Sheet music: Life Is a Beautiful Thing",
          "                     Livingston, Ray (Composer)",
          "                     Evans, Ray (Lyricist)",
          "                     Aaron Slick From Punkin Crick [Film] (Source)",
          "                       NOW LOCATED: SF PALM, Johnson Sheet Music Collection Box 1 (2007/02/22)"
        ]
        expect(item(item).title).to eq("Life Is a Beautiful Thing")
      end

      it "rejects an item with no accession number or title" do
        item = [
          "                     Livingston, Ray (Composer)",
          "                     Evans, Ray (Lyricist)",
          "                     Aaron Slick From Punkin Crick [Film] (Source)",
          "                     1951",
          "                       NOW LOCATED: SF PALM, Johnson Sheet Music Collection Box 1 (2007/02/22)"
        ]
        expect_to_be_invalid item
      end

      it "rejects an item with more than one accession number and title" do
        item = [
          " 007.009.00007     Sheet music: I'd Like To Baby You",
          " 007.009.00007     Sheet music: I'd Like To Baby You",
          "                     Livingston, Ray (Composer)",
          "                     Evans, Ray (Lyricist)",
          "                     Aaron Slick From Punkin Crick [Film] (Source)",
          "                     1951",
          "                       NOW LOCATED: SF PALM, Johnson Sheet Music Collection Box 1 (2007/02/22)"
        ]
        expect_to_be_invalid item
      end

      it "treats Company as Composer" do
        item = [
          " 007.009.00007     Sheet music: I'd Like To Baby You",
          "                     Livingston, Ray (Company)",
          "                     Evans, Ray (Lyricist)",
          "                     Aaron Slick From Punkin Crick [Film] (Source)",
          "                     1951",
          "                       NOW LOCATED: SF PALM, Johnson Sheet Music Collection Box 1 (2007/02/22)"
        ]
        expect(item(item).composers).to eq(["Livingston, Ray"])
      end

      it "allows multiple composers" do
        item = [
          " 007.009.00007     Sheet music: I'd Like To Baby You",
          "                     Livingston, Jay (Composer)",
          "                     Livingston, Ray (Composer)",
          "                     Evans, Ray (Lyricist)",
          "                     Aaron Slick From Punkin Crick [Film] (Source)",
          "                     1951",
          "                       NOW LOCATED: SF PALM, Johnson Sheet Music Collection Box 1 (2007/02/22)"
        ]
        expect(item(item).composers).to eq(["Livingston, Jay", "Livingston, Ray"])
      end

      it "rejects an item with no composer" do
        item = [
          " 007.009.00007     Sheet music: I'd Like To Baby You",
          "                     Evans, Ray (Lyricist)",
          "                     Aaron Slick From Punkin Crick [Film] (Source)",
          "                     1951",
          "                       NOW LOCATED: SF PALM, Johnson Sheet Music Collection Box 1 (2007/02/22)"
        ]
        expect_to_be_invalid item
      end

      it "allows an item with no lyricist" do
        item = [
          " 007.009.00007     Sheet music: I'd Like To Baby You",
          "                     Livingston, Ray (Composer)",
          "                     Aaron Slick From Punkin Crick [Film] (Source)",
          "                     1951",
          "                       NOW LOCATED: SF PALM, Johnson Sheet Music Collection Box 1 (2007/02/22)"
        ]
        expect(item(item).lyricists).to eq([])
      end

      it "allows multiple lyricists" do
        item = [
          " 007.009.00007     Sheet music: I'd Like To Baby You",
          "                     Livingston, Ray (Composer)",
          "                     Evans, Jay (Lyricist)",
          "                     Evans, Ray (Lyricist)",
          "                     Aaron Slick From Punkin Crick [Film] (Source)",
          "                     1951",
          "                       NOW LOCATED: SF PALM, Johnson Sheet Music Collection Box 1 (2007/02/22)"
        ]
        expect(item(item).lyricists).to eq(["Evans, Jay", "Evans, Ray"])
      end

      it "handles Composer & Lyricist" do
        input = [
          " 007.009.00007     Sheet music: I'd Like To Baby You",
          "                     Livingston, Ray (Composer & Lyricist)",
          "                     Aaron Slick From Punkin Crick [Film] (Source)",
          "                     1951",
          "                       NOW LOCATED: SF PALM, Johnson Sheet Music Collection Box 1 (2007/02/22)"
        ]
        item = item input
        expect(item.composers).to eq(["Livingston, Ray"])
        expect(item.lyricists).to eq(["Livingston, Ray"])
      end

      it "allows an item with no source" do
        input = [
          " 007.009.00007     Sheet music: I'd Like To Baby You",
          "                     Livingston, Ray (Composer)",
          "                     Evans, Ray (Lyricist)",
          "                     1951",
          "                       NOW LOCATED: SF PALM, Johnson Sheet Music Collection Box 1 (2007/02/22)"
        ]
        item = item input
        expect(item.source_name).to be_nil
        expect(item.source_type).to be_nil
      end

      it "ignores a date in the source type" do
        item = [
          " 007.009.00007     Sheet music: I'd Like To Baby You",
          "                     Livingston, Ray (Composer)",
          "                     Evans, Ray (Lyricist)",
          "                     Aaron Slick From Punkin Crick [Film - 1951] (Source)",
          "                     1951",
          "                       NOW LOCATED: SF PALM, Johnson Sheet Music Collection Box 1 (2007/02/22)"
        ]
        expect(item(item).source_type).to eq("Film")
      end

      it "recognizes a source type terminated by }" do
        item = [
          " 007.009.00007     Sheet music: I'd Like To Baby You",
          "                     Livingston, Ray (Composer)",
          "                     Evans, Ray (Lyricist)",
          "                     Aaron Slick From Punkin Crick [Film} (Source)",
          "                     1951",
          "                       NOW LOCATED: SF PALM, Johnson Sheet Music Collection Box 1 (2007/02/22)"
        ]
        expect(item(item).source_type).to eq("Film")
      end

      it "rejects an item with more than one source" do
        item = [
          " 007.009.00007     Sheet music: I'd Like To Baby You",
          "                     Livingston, Ray (Composer)",
          "                     Evans, Ray (Lyricist)",
          "                     Aaron Slick From Punkin Crick [Film] (Source)",
          "                     Aaron Slick From Punkin Crick [Film] (Source)",
          "                     1951",
          "                       NOW LOCATED: SF PALM, Johnson Sheet Music Collection Box 1 (2007/02/22)"
        ]
        expect_to_be_invalid item
      end

      it "allows an item with no date" do
        item = [
          " 007.009.00007     Sheet music: I'd Like To Baby You",
          "                     Livingston, Ray (Composer)",
          "                     Evans, Ray (Lyricist)",
          "                     Aaron Slick From Punkin Crick [Film] (Source)",
          "                       NOW LOCATED: SF PALM, Johnson Sheet Music Collection Box 1 (2007/02/22)"
        ]
        expect(item(item).date).to be_nil
      end

      it "allows a date beginning with c" do
        item = [
          " 007.009.00007     Sheet music: I'd Like To Baby You",
          "                     Livingston, Ray (Composer)",
          "                     Evans, Ray (Lyricist)",
          "                     Aaron Slick From Punkin Crick [Film] (Source)",
          "                     c1951",
          "                       NOW LOCATED: SF PALM, Johnson Sheet Music Collection Box 1 (2007/02/22)"
        ]
        expect(item(item).date).to eq("c1951")
      end

      it "rejects an item with more than one date" do
        item = [
          " 007.009.00007     Sheet music: I'd Like To Baby You",
          "                     Livingston, Ray (Composer)",
          "                     Evans, Ray (Lyricist)",
          "                     Aaron Slick From Punkin Crick [Film] (Source)",
          "                     1951",
          "                     1951",
          "                       NOW LOCATED: SF PALM, Johnson Sheet Music Collection Box 1 (2007/02/22)"
        ]
        expect_to_be_invalid item
      end

      it "handles a continued location" do
        item = [
          " 007.009.00007     Sheet music: I'd Like To Baby You",
          "                     Livingston, Ray (Composer)",
          "                     Evans, Ray (Lyricist)",
          "                     Aaron Slick From Punkin Crick [Film] (Source)",
          "                     1951",
          "                       NOW LOCATED: SF PALM, Johnson Sheet Music Collection Box",
          "                   1 (2007/02/22)"
        ]
        expect(item(item).location).to eq("Box 1")
      end

      it "rejects an item with no location" do
        item = [
          " 007.009.00007     Sheet music: I'd Like To Baby You",
          "                     Livingston, Ray (Composer)",
          "                     Evans, Ray (Lyricist)",
          "                     Aaron Slick From Punkin Crick [Film] (Source)",
          "                     1951"
        ]
        expect_to_be_invalid item
      end

      it "rejects an item with more than one location" do
        item = [
          " 007.009.00007     Sheet music: I'd Like To Baby You",
          "                     Livingston, Ray (Composer)",
          "                     Evans, Ray (Lyricist)",
          "                     Aaron Slick From Punkin Crick [Film] (Source)",
          "                     1951",
          "                       NOW LOCATED: SF PALM, Johnson Sheet Music Collection Box 1 (2007/02/22)",
          "                       NOW LOCATED: SF PALM, Johnson Sheet Music Collection Box 1 (2007/02/22)"
        ]
        expect_to_be_invalid item
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
        item = item input
        expect(item.lyricists).to eq(["Evans, Ray"])
        expect(item.source_name).to eq("$ Dollars $")
      end

      it "skips and logs an invalid item" do
        invalid_item = [
          " 07.009.00001      Sheet music: I'd Like To Baby You",
          "                     Livingston, Ray (Composer)",
          "                     Evans, Ray (Lyricist)",
          "                     Aaron Slick From Punkin Crick [Film] (Source)",
          "                     1951",
          "                       NOW LOCATED: SF PALM, Johnson Sheet Music Collection Box 1 (2007/02/22)"
        ]

        expect(item(invalid_item)).to be_nil
        expect(Logger).to have_received(:warn).with("Skipping invalid item:\n#{invalid_item}")
      end

      def item(item)
        described_class.new(item).item
      end

      def expect_to_be_invalid(item)
        parser = described_class.new item
        allow(parser).to receive(:warn)
        expect(parser.item).to be_nil
      end

    end
  end
end
