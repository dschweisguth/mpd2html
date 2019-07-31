module MPD2HTML
  describe ParserItem do
    describe '#item' do
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
          composer: "Livingston, Ray",
          lyricist: "Evans, Ray",
          source_type: "Film",
          source_name: "Aaron Slick From Punkin Crick",
          date: "1951",
          location: "Box 1"
        )
        expect(item item).to eq(expected_item)
      end

      it "removes '(Popular Title in English)'" do
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

      it "rejects an item with a repeated field" do
        item = [
          " 007.009.00007     Sheet music: I'd Like To Baby You",
          "                     Livingston, Ray (Composer)",
          "                     Livingston, Ray (Composer)",
          "                     Evans, Ray (Lyricist)",
          "                     Aaron Slick From Punkin Crick [Film] (Source)",
          "                     1951",
          "                       NOW LOCATED: SF PALM, Johnson Sheet Music Collection Box 1 (2007/02/22)"
        ]
        parser = ParserItem.new item
        allow(parser).to receive(:warn)
        expect(parser.item).to be_nil
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
        expect(item(item).composer).to eq("Livingston, Ray")
      end

      it "allows an item without a date" do
        item = [
          " 007.009.00007     Sheet music: I'd Like To Baby You",
          "                     Livingston, Ray (Composer)",
          "                     Evans, Ray (Lyricist)",
          "                     Aaron Slick From Punkin Crick [Film] (Source)",
          "                       NOW LOCATED: SF PALM, Johnson Sheet Music Collection Box 1 (2007/02/22)"
        ]
        expect(item(item).date).to be_nil
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

      it "skips and logs an invalid item" do
        invalid_item = [
          " 007.009.0000      Sheet music: I'd Like To Baby You",
          "                     Livingston, Ray (Composer)",
          "                     Evans, Ray (Lyricist)",
          "                     Aaron Slick From Punkin Crick [Film] (Source)",
          "                     1951",
          "                       NOW LOCATED: SF PALM, Johnson Sheet Music Collection Box 1 (2007/02/22)"
        ]

        parser = ParserItem.new invalid_item
        allow(parser).to receive(:warn)
        expect(parser.item).to eq(nil)
        expect(parser).to have_received(:warn).with("Skipping invalid item:")
        expect(parser).to have_received(:warn).with(invalid_item)
      end

      def item(item)
        ParserItem.new(item).item
      end

    end
  end
end
