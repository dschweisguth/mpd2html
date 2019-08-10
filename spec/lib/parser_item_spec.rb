require_relative '../../lib/mpd2html/parser_item'

module MPD2HTML
  describe ParserItem do
    describe '#item' do
      before do
        allow(Logger).to receive(:warn)
      end

      it "parses a valid item" do
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
        expect(item(input).title).to eq("Life Is a Beautiful Thing")
        expect(Logger).to have_received(:warn).with(%Q(Accepting item with warnings: Accepting "Program" for "Sheet music".:\n#{input}))
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
        expect(item(input).title).to eq("Life Is a Beautiful Thing")
      end

      [3, 4, 5, 6].each do |digits|
        it "allows an accession number with a last part with #{digits} digits" do
          input = [
            " 007.009.#{'1' * digits} Sheet music: Life Is a Beautiful Thing",
            "                     Livingston, Ray (Composer)",
            "                     Evans, Ray (Lyricist)",
            "                     Aaron Slick From Punkin Crick [Film] (Source)",
            "                       NOW LOCATED: SF PALM, Johnson Sheet Music Collection Box 1 (2007/02/22)"
          ]
          expect(item(input).title).to eq("Life Is a Beautiful Thing")
        end
      end

      it "allows and ignores a J after the accession number" do
        input = [
          " 007.009.00008J    Sheet music: Life Is a Beautiful Thing",
          "                     Livingston, Ray (Composer)",
          "                     Evans, Ray (Lyricist)",
          "                     Aaron Slick From Punkin Crick [Film] (Source)",
          "                       NOW LOCATED: SF PALM, Johnson Sheet Music Collection Box 1 (2007/02/22)"
        ]
        expect(item(input).title).to eq("Life Is a Beautiful Thing")
      end

      it "rejects an item with no accession number or title" do
        input = [
          "                     Livingston, Ray (Composer)",
          "                     Evans, Ray (Lyricist)",
          "                     Aaron Slick From Punkin Crick [Film] (Source)",
          "                     1951",
          "                       NOW LOCATED: SF PALM, Johnson Sheet Music Collection Box 1 (2007/02/22)"
        ]
        expect_to_be_invalid input
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
        expect_to_be_invalid input
      end

      it "treats Company as Composer" do
        input = [
          " 007.009.00007     Sheet music: I'd Like To Baby You",
          "                     Livingston, Ray (Company)",
          "                     Evans, Ray (Lyricist)",
          "                     Aaron Slick From Punkin Crick [Film] (Source)",
          "                     1951",
          "                       NOW LOCATED: SF PALM, Johnson Sheet Music Collection Box 1 (2007/02/22)"
        ]
        expect(item(input).composers).to eq(["Livingston, Ray"])
      end

      it "allows multiple composers" do
        input = [
          " 007.009.00007     Sheet music: I'd Like To Baby You",
          "                     Livingston, Jay (Composer)",
          "                     Livingston, Ray (Composer)",
          "                     Evans, Ray (Lyricist)",
          "                     Aaron Slick From Punkin Crick [Film] (Source)",
          "                     1951",
          "                       NOW LOCATED: SF PALM, Johnson Sheet Music Collection Box 1 (2007/02/22)"
        ]
        expect(item(input).composers).to eq(["Livingston, Jay", "Livingston, Ray"])
      end

      it "rejects an item with no composer" do
        input = [
          " 007.009.00007     Sheet music: I'd Like To Baby You",
          "                     Evans, Ray (Lyricist)",
          "                     Aaron Slick From Punkin Crick [Film] (Source)",
          "                     1951",
          "                       NOW LOCATED: SF PALM, Johnson Sheet Music Collection Box 1 (2007/02/22)"
        ]
        expect_to_be_invalid input
      end

      it "allows an item with no lyricist" do
        input = [
          " 007.009.00007     Sheet music: I'd Like To Baby You",
          "                     Livingston, Ray (Composer)",
          "                     Aaron Slick From Punkin Crick [Film] (Source)",
          "                     1951",
          "                       NOW LOCATED: SF PALM, Johnson Sheet Music Collection Box 1 (2007/02/22)"
        ]
        expect(item(input).lyricists).to eq([])
      end

      it "allows multiple lyricists" do
        input = [
          " 007.009.00007     Sheet music: I'd Like To Baby You",
          "                     Livingston, Ray (Composer)",
          "                     Evans, Jay (Lyricist)",
          "                     Evans, Ray (Lyricist)",
          "                     Aaron Slick From Punkin Crick [Film] (Source)",
          "                     1951",
          "                       NOW LOCATED: SF PALM, Johnson Sheet Music Collection Box 1 (2007/02/22)"
        ]
        expect(item(input).lyricists).to eq(["Evans, Jay", "Evans, Ray"])
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
        input = [
          " 007.009.00007     Sheet music: I'd Like To Baby You",
          "                     Livingston, Ray (Composer)",
          "                     Evans, Ray (Lyricist)",
          "                     Aaron Slick From Punkin Crick [Film - 1951] (Source)",
          "                     1951",
          "                       NOW LOCATED: SF PALM, Johnson Sheet Music Collection Box 1 (2007/02/22)"
        ]
        expect(item(input).source_type).to eq("Film")
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
        expect(item(input).source_type).to eq("Film")
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

      it "allows an item with no date" do
        input = [
          " 007.009.00007     Sheet music: I'd Like To Baby You",
          "                     Livingston, Ray (Composer)",
          "                     Evans, Ray (Lyricist)",
          "                     Aaron Slick From Punkin Crick [Film] (Source)",
          "                       NOW LOCATED: SF PALM, Johnson Sheet Music Collection Box 1 (2007/02/22)"
        ]
        expect(item(input).date).to be_nil
      end

      it "allows a date beginning with c" do
        input = [
          " 007.009.00007     Sheet music: I'd Like To Baby You",
          "                     Livingston, Ray (Composer)",
          "                     Evans, Ray (Lyricist)",
          "                     Aaron Slick From Punkin Crick [Film] (Source)",
          "                     c1951",
          "                       NOW LOCATED: SF PALM, Johnson Sheet Music Collection Box 1 (2007/02/22)"
        ]
        expect(item(input).date).to eq("c1951")
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
        item = item input
        expect(item.lyricists).to eq(["Evans, Ray"])
        expect(item.source_name).to eq("$ Dollars $")
      end

      it "skips and logs an invalid item" do
        input = [
          " 07.009.00001      Sheet music: I'd Like To Baby You",
          "                     Livingston, Ray (Composer)",
          "                     Evans, Ray (Lyricist)",
          "                     Aaron Slick From Punkin Crick [Film] (Source)",
          "                     1951",
          "                       NOW LOCATED: SF PALM, Johnson Sheet Music Collection Box 1 (2007/02/22)"
        ]

        expect_to_be_invalid input, "Skipping item:\n#{input}"
      end

      def item(item)
        described_class.new(item).item
      end

      def expect_to_be_invalid(input, *messages)
        expect(item(input)).to be_nil
        messages.each do |message|
          expect(Logger).to have_received(:warn).with(message)
        end
      end

    end
  end
end
