module MPD2HTML
  describe Parser do
    let(:parser) { described_class.new }

    let(:invalid_entry) do
      <<~EOT.split(/(?<=\n)/)
        Browse List                                                          Page: 1

         Accession         Object Title                                                

         007.009.0000      Sheet music: I'd Like To Baby You
                             Livingston, Ray (Composer)
                             Evans, Ray (Lyricist)
                             Aaron Slick From Punkin Crick [Film] (Source)
                             1951
                               NOW LOCATED: SF PALM, Johnson Sheet Music Collection Box
                           1 (2007/02/22)
      EOT
    end

    describe '#items' do
      it "does not warn at all if there are no invalid entries" do
        allow(parser).to receive(:warn)
        parser.items []
        expect(parser).not_to have_received(:warn)
      end

      it "warns of invalid entries" do
        filename = 'filename'
        allow(IO).to receive(:readlines).with(filename).and_return(invalid_entry)
        allow(parser).to receive(:warn)
        expect(parser.items([filename])).to eq([])
        expect(parser).to have_received(:warn).with("Skipped 1 invalid entries of 1 entries")
      end

    end

    describe '#item' do
      it "parses a valid entry" do
        entry = <<~EOT.split(/(?<=\n)/)
          Browse List                                                          Page: 1
  
           Accession         Object Title                                                
  
           007.009.00007     Sheet music: I'd Like To Baby You
                               Livingston, Ray (Composer)
                               Evans, Ray (Lyricist)
                               Aaron Slick From Punkin Crick [Film] (Source)
                               1951
                                 NOW LOCATED: SF PALM, Johnson Sheet Music Collection Box
                             1 (2007/02/22)
        EOT
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
        expect(parser.item entry).to eq(expected_item)
      end

      it "allows an entry without a date" do
        entry = <<~EOT.split(/(?<=\n)/)
          Browse List                                                          Page: 1
  
           Accession         Object Title                                                
  
           007.009.00007     Sheet music: I'd Like To Baby You
                               Livingston, Ray (Composer)
                               Evans, Ray (Lyricist)
                               Aaron Slick From Punkin Crick [Film] (Source)
                                 NOW LOCATED: SF PALM, Johnson Sheet Music Collection Box
                             1 (2007/02/22)
        EOT
        expect(parser.item(entry).date).to be_nil
      end

      it "skips and logs an invalid entry" do
        allow(parser).to receive(:warn)
        expect(parser.item invalid_entry).to eq(nil)
        expect(parser).to have_received(:warn).with("Skipping invalid entry:")
        expect(parser).to have_received(:warn).with(invalid_entry)
      end

    end

  end
end
