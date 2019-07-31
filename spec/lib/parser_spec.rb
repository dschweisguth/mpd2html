module MPD2HTML
  describe Parser do
    describe '#items' do
      let(:parser) do
        described_class.new.tap do |parser|
          allow(parser).to receive(:warn)
        end
      end

      it "parses valid input" do
        input = <<~EOT.split(/(?<=\n)/)
          Browse List                                                          Page: 1
           007.009.00007     Sheet music: I'd Like To Baby You
                               Livingston, Ray (Composer)
                               Evans, Ray (Lyricist)
                               Aaron Slick From Punkin Crick [Film] (Source)
                               1951
                                 NOW LOCATED: SF PALM, Johnson Sheet Music Collection Box 1 (2007/02/22)
        EOT
        items = items input
        expect(items.length).to eq(1)
        expect(items[0]).not_to be_nil
        expect(parser).not_to have_received(:warn)
      end

      it "ignores blank lines and headers" do
        input = <<~EOT.split(/(?<=\n)/)
          Browse List                                                          Page: 1
  
           Accession         Object Title                                                
  
           007.009.00007     Sheet music: I'd Like To Baby You
                               Livingston, Ray (Composer)
                               Evans, Ray (Lyricist)
                               Aaron Slick From Punkin Crick [Film] (Source)
                               1951
                                 NOW LOCATED: SF PALM, Johnson Sheet Music Collection Box 1 (2007/02/22)
        EOT
        items = items input
        expect(items.length).to eq(1)
        expect(items[0]).not_to be_nil
      end

      it "warns of invalid items" do
        invalid_item = <<~EOT.split(/(?<=\n)/)
          Browse List                                                          Page: 1
           007.009.0000      Sheet music: I'd Like To Baby You
                               Livingston, Ray (Composer)
                               Evans, Ray (Lyricist)
                               Aaron Slick From Punkin Crick [Film] (Source)
                               1951
                                 NOW LOCATED: SF PALM, Johnson Sheet Music Collection Box 1 (2007/02/22)
        EOT
        allow(ParserItem).to receive(:new).and_return(double item: nil)
        expect(items invalid_item).to eq([])
        expect(parser).to have_received(:warn).with("Skipped 1 invalid items of 1 items")
      end

      def items(input)
        filename = 'filename'
        allow(IO).to receive(:readlines).with(filename).and_return(input)
        parser.items [filename]
      end

    end
  end
end
