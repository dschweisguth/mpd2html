require_relative '../../lib/mpd2html/parser'

module MPD2HTML
  describe Parser do
    describe '#items' do
      before do
        allow(Logger).to receive(:error)
        allow(Logger).to receive(:warn)
      end

      it "parses input without warnings" do
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
        expect(Logger).not_to have_received(:error)
        expect(Logger).to have_received(:warn).once
        expect(Logger).to have_received(:warn).with("Converted 1 items")
      end

      it "sorts by title" do
        input = [
          " 007.009.00007     Sheet music: I'd Like To Cradle You",
          "                       NOW LOCATED: SF PALM, Johnson Sheet Music Collection Box 1 (2007/02/22)",
          " 007.009.00008     Sheet music: I'd Like To Baby You",
          "                       NOW LOCATED: SF PALM, Johnson Sheet Music Collection Box 1 (2007/02/22)"
        ]
        expect(items(input).map(&:title)).to eq(["I'd Like To Baby You", "I'd Like To Cradle You"])
      end

      it "ignores case when sorting" do
        input = [
          " 007.009.00007     Sheet music: Zulu warriors",
          "                       NOW LOCATED: SF PALM, Johnson Sheet Music Collection Box 1 (2007/02/22)",
          " 007.009.00008     Sheet music: The abominable snow monster",
          "                       NOW LOCATED: SF PALM, Johnson Sheet Music Collection Box 1 (2007/02/22)"
        ]
        expect(items(input).map(&:title)).to eq(["The abominable snow monster", "Zulu warriors"])
      end

      it "ignores initial parentheses when sorting" do
        input = [
          " 007.009.00007     Sheet music: ('Round her neck) She wore a yellow ribbon",
          "                       NOW LOCATED: SF PALM, Johnson Sheet Music Collection Box 1 (2007/02/22)",
          " 007.009.00008     Sheet music: (A penny for your thoughts) Junior Miss",
          "                       NOW LOCATED: SF PALM, Johnson Sheet Music Collection Box 1 (2007/02/22)"
        ]
        expect(items(input).map(&:title)).to eq(["(A penny for your thoughts) Junior Miss", "('Round her neck) She wore a yellow ribbon"])
      end

      it "ignores initial articles when sorting" do
        input = [
          " 007.009.00007     Sheet music: A C",
          "                       NOW LOCATED: SF PALM, Johnson Sheet Music Collection Box 1 (2007/02/22)",
          " 007.009.00008     Sheet music: An A",
          "                       NOW LOCATED: SF PALM, Johnson Sheet Music Collection Box 1 (2007/02/22)",
          " 007.009.00009     Sheet music: The B",
          "                       NOW LOCATED: SF PALM, Johnson Sheet Music Collection Box 1 (2007/02/22)"
        ]
        expect(items(input).map(&:title)).to eq(["An A", "The B", "A C"])
      end

      it "considers initial articles which are actually part of words when sorting" do
        input = [
          " 007.009.00007     Sheet music: Theme and Variations",
          "                       NOW LOCATED: SF PALM, Johnson Sheet Music Collection Box 1 (2007/02/22)",
          " 007.009.00008     Sheet music: Azure Sky",
          "                       NOW LOCATED: SF PALM, Johnson Sheet Music Collection Box 1 (2007/02/22)",
          " 007.009.00009     Sheet music: Anxiety Blues",
          "                       NOW LOCATED: SF PALM, Johnson Sheet Music Collection Box 1 (2007/02/22)"
        ]
        expect(items(input).map(&:title)).to eq(["Anxiety Blues", "Azure Sky", "Theme and Variations"])
      end

      it "ignores initial quotes when sorting" do
        input = [
          " 007.009.00007     Sheet music: Something Else Someone Said",
          "                       NOW LOCATED: SF PALM, Johnson Sheet Music Collection Box 1 (2007/02/22)",
          " 007.009.00008     Sheet music: \"Something Someone Said\"",
          "                       NOW LOCATED: SF PALM, Johnson Sheet Music Collection Box 1 (2007/02/22)"
        ]
        expect(items(input).map(&:title)).to eq(["Something Else Someone Said", "\"Something Someone Said\""])
      end

      it "ignores initial articles after initial quotes when sorting" do
        input = [
          " 007.009.00007     Sheet music: \"The Lily Watkins Tune\"",
          "                       NOW LOCATED: SF PALM, Johnson Sheet Music Collection Box 1 (2007/02/22)",
          " 007.009.00008     Sheet music: \"The Goo Goo Doll Song\"",
          "                       NOW LOCATED: SF PALM, Johnson Sheet Music Collection Box 1 (2007/02/22)"
        ]
        expect(items(input).map(&:title)).to eq(["\"The Goo Goo Doll Song\"", "\"The Lily Watkins Tune\""])
      end

      it "ignores initial quotes after initial articles when sorting" do
        input = [
          " 007.009.00007     Sheet music: The \"Lily Watkins\" Tune",
          "                       NOW LOCATED: SF PALM, Johnson Sheet Music Collection Box 1 (2007/02/22)",
          " 007.009.00008     Sheet music: The \"Goo Goo Doll\" Song",
          "                       NOW LOCATED: SF PALM, Johnson Sheet Music Collection Box 1 (2007/02/22)"
        ]
        expect(items(input).map(&:title)).to eq(["The \"Goo Goo Doll\" Song", "The \"Lily Watkins\" Tune"])
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
        expect(items input).to eq([])
        expect(Logger).to have_received(:error).with("Skipped 1 invalid items of 1 items")
      end

      it "logs total items" do
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
        expect(Logger).to have_received(:warn).with("Converted 1 items")
      end

      def items(input)
        filename = 'filename'
        allow(IO).to receive(:readlines).with(filename).and_return(input)
        described_class.new.items [filename]
      end

    end
  end
end
