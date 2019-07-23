describe MPD2HTML::Parser do
  describe '#item' do
    it "skips and logs an invalid entry" do
      parser = described_class.new
      entry = <<~EOT.split(/(?<=\n)/)
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
      allow(parser).to receive(:warn)
      expect(parser.item entry).to eq(nil)
      expect(parser).to have_received(:warn).with "Skipping invalid entry:"
      expect(parser).to have_received(:warn).with entry
    end
  end
end
