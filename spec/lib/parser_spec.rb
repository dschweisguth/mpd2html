require_relative '../../lib/mpd2html/parser'

module MPD2HTML
  describe Parser do
    describe '#items' do
      before do
        allow(Logger).to receive(:warn)
      end

      it "parses valid input" do
        input = [
          " 007.009.00007     Sheet music: I'd Like To Baby You",
          "                     Livingston, Ray (Composer)",
          "                     Evans, Ray (Lyricist)",
          "                     Aaron Slick From Punkin Crick [Film] (Source)",
          "                     1951",
          "                       NOW LOCATED: SF PALM, Johnson Sheet Music Collection Box 1 (2007/02/22)"
        ]
        items = items input
        expect(items.length).to eq(1)
        expect(items[0]).not_to be_nil
        expect(Logger).not_to have_received(:warn)
      end

      it "ignores blank lines and headers" do
        input = [
          "Browse List                                                          Page: 1",
          "",
          " Accession         Object Title",
          "",
          " 007.009.00007     Sheet music: I'd Like To Baby You",
          "                     Livingston, Ray (Composer)",
          "                     Evans, Ray (Lyricist)",
          "                     Aaron Slick From Punkin Crick [Film] (Source)",
          "                     1951",
          "                       NOW LOCATED: SF PALM, Johnson Sheet Music Collection Box 1 (2007/02/22)"
        ]
        items = items input
        expect(items.length).to eq(1)
        expect(items[0]).not_to be_nil
      end

      it "warns of invalid items" do
        input = [
          " 007.009.00007     Shoot music: I'd Like To Baby You",
          "                     Livingston, Ray (Composer)",
          "                     Evans, Ray (Lyricist)",
          "                     Aaron Slick From Punkin Crick [Film] (Source)",
          "                     1951",
          "                       NOW LOCATED: SF PALM, Johnson Sheet Music Collection Box 1 (2007/02/22)"
        ]
        # allow(ParserItem).to receive(:new).and_return(double item: nil)
        expect(items input).to eq([])
        expect(Logger).to have_received(:warn).with("Skipped 1 invalid items of 1 items")
      end

      def items(input)
        filename = 'filename'
        allow(IO).to receive(:readlines).with(filename).and_return(input)
        described_class.new.items [filename]
      end

    end
  end
end
