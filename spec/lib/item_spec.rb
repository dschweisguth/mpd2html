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

      it "handles a continued accession/title line" do
        input = [
          " 007.009.00008     Sheet music: I'd Like To Baby",
          "                   You",
          "                     Livingston, Ray (Composer)",
          "                     Evans, Ray (Lyricist)",
          "                     Aaron Slick From Punkin Crick [Film] (Source)",
          "                     1951",
          "                       NOW LOCATED: SF PALM, Johnson Sheet Music Collection Box 1 (2007/02/22)"
        ]
        expect_item input, title: "I'd Like To Baby You"
      end

      it "handles a continued accession/title line beginning with a non-word character" do
        input = [
          " 007.009.00007     Sheet music: I'd Like To Baby You",
          "                   (Popular Title in English)",
          "                     Livingston, Ray (Composer)",
          "                     Evans, Ray (Lyricist)",
          "                     Aaron Slick From Punkin Crick [Film] (Source)",
          "                     1951",
          "                       NOW LOCATED: SF PALM, Johnson Sheet Music Collection Box 1 (2007/02/22)"
        ]
        expect_item input, title: "I'd Like To Baby You"
      end

      it "handles a continued accession/title line beginning with an extra space" do
        input = [
          " 007.009.00008     Sheet music: I'd Like To Baby You",
          "                    [for some reason brackets are preceded by an extra space]",
          "                     Livingston, Ray (Composer)",
          "                     Evans, Ray (Lyricist)",
          "                     Aaron Slick From Punkin Crick [Film] (Source)",
          "                     1951",
          "                       NOW LOCATED: SF PALM, Johnson Sheet Music Collection Box 1 (2007/02/22)"
        ]
        expect_item input, title: "I'd Like To Baby You [for some reason brackets are preceded by an extra space]"
      end

      it "accepts an accession number missing the first ." do
        input = [
          " 007009.12345      Sheet music: I'd Like To Baby You",
          "                     Livingston, Ray (Composer)",
          "                     Evans, Ray (Lyricist)",
          "                     Aaron Slick From Punkin Crick [Film] (Source)",
          "                     1951",
          "                       NOW LOCATED: SF PALM, Johnson Sheet Music Collection Box 1 (2007/02/22)"
        ]
        expect_item input, { title: "I'd Like To Baby You" }, "Invalid accession number"
      end

      it "accepts an accession number with a first part with 2 digits" do
        input = [
          " 07.009.12345      Sheet music: I'd Like To Baby You",
          "                     Livingston, Ray (Composer)",
          "                     Evans, Ray (Lyricist)",
          "                     Aaron Slick From Punkin Crick [Film] (Source)",
          "                     1951",
          "                       NOW LOCATED: SF PALM, Johnson Sheet Music Collection Box 1 (2007/02/22)"
        ]
        expect_item input, { title: "I'd Like To Baby You" }, "Invalid accession number"
      end

      it "accepts an accession number with a first part with 4 digits" do
        input = [
          " 0007.009.12345    Sheet music: I'd Like To Baby You",
          "                     Livingston, Ray (Composer)",
          "                     Evans, Ray (Lyricist)",
          "                     Aaron Slick From Punkin Crick [Film] (Source)",
          "                     1951",
          "                       NOW LOCATED: SF PALM, Johnson Sheet Music Collection Box 1 (2007/02/22)"
        ]
        expect_item input, { title: "I'd Like To Baby You" }, "Invalid accession number"
      end

      it "accepts an accession number with / in place of the first ." do
        input = [
          " 007/009.12345     Sheet music: I'd Like To Baby You",
          "                     Livingston, Ray (Composer)",
          "                     Evans, Ray (Lyricist)",
          "                     Aaron Slick From Punkin Crick [Film] (Source)",
          "                     1951",
          "                       NOW LOCATED: SF PALM, Johnson Sheet Music Collection Box 1 (2007/02/22)"
        ]
        expect_item input, { title: "I'd Like To Baby You" }, "Invalid accession number"
      end

      it "accepts an accession number with a second part with 4 digits" do
        input = [
          " 007.0090.12345    Sheet music: I'd Like To Baby You",
          "                     Livingston, Ray (Composer)",
          "                     Evans, Ray (Lyricist)",
          "                     Aaron Slick From Punkin Crick [Film] (Source)",
          "                     1951",
          "                       NOW LOCATED: SF PALM, Johnson Sheet Music Collection Box 1 (2007/02/22)"
        ]
        expect_item input, { title: "I'd Like To Baby You" }, "Invalid accession number"
      end

      [3, 4, 5].each do |digits|
        it "accepts an accession number with a last part with #{digits} digits" do
          input = [
            " 007.009.#{'1' * digits} Sheet music: I'd Like To Baby You",
            "                     Livingston, Ray (Composer)",
            "                     Evans, Ray (Lyricist)",
            "                     Aaron Slick From Punkin Crick [Film] (Source)",
            "                     1951",
            "                       NOW LOCATED: SF PALM, Johnson Sheet Music Collection Box 1 (2007/02/22)"
          ]
          expect_item input, title: "I'd Like To Baby You"
        end
      end

      it "accepts an accession number with a last part with 6 digits" do
        input = [
          " 007.009.123456    Sheet music: I'd Like To Baby You",
          "                     Livingston, Ray (Composer)",
          "                     Evans, Ray (Lyricist)",
          "                     Aaron Slick From Punkin Crick [Film] (Source)",
          "                     1951",
          "                       NOW LOCATED: SF PALM, Johnson Sheet Music Collection Box 1 (2007/02/22)"
        ]
        expect_item input, { title: "I'd Like To Baby You" }, "Invalid accession number"
      end

      it "accepts an accession number missing the second ." do
        input = [
          " 007.00912345      Sheet music: I'd Like To Baby You",
          "                     Livingston, Ray (Composer)",
          "                     Evans, Ray (Lyricist)",
          "                     Aaron Slick From Punkin Crick [Film] (Source)",
          "                     1951",
          "                       NOW LOCATED: SF PALM, Johnson Sheet Music Collection Box 1 (2007/02/22)"
        ]
        expect_item input, { title: "I'd Like To Baby You" }, "Invalid accession number"
      end

      it "accepts an accession number with / in place of the second ." do
        input = [
          " 007.009/12345     Sheet music: I'd Like To Baby You",
          "                     Livingston, Ray (Composer)",
          "                     Evans, Ray (Lyricist)",
          "                     Aaron Slick From Punkin Crick [Film] (Source)",
          "                     1951",
          "                       NOW LOCATED: SF PALM, Johnson Sheet Music Collection Box 1 (2007/02/22)"
        ]
        expect_item input, { title: "I'd Like To Baby You" }, "Invalid accession number"
      end

      it "accepts an accession number missing a last part" do
        input = [
          " 007.009           Sheet music: I'd Like To Baby You",
          "                     Livingston, Ray (Composer)",
          "                     Evans, Ray (Lyricist)",
          "                     Aaron Slick From Punkin Crick [Film] (Source)",
          "                     1951",
          "                       NOW LOCATED: SF PALM, Johnson Sheet Music Collection Box 1 (2007/02/22)"
        ]
        expect_item input, { title: "I'd Like To Baby You" }, "Invalid accession number"
      end

      it "accepts and ignores a J after the accession number" do
        input = [
          " 007.009.00008J    Sheet music: I'd Like To Baby You",
          "                     Livingston, Ray (Composer)",
          "                     Evans, Ray (Lyricist)",
          "                     Aaron Slick From Punkin Crick [Film] (Source)",
          "                     1951",
          "                       NOW LOCATED: SF PALM, Johnson Sheet Music Collection Box 1 (2007/02/22)"
        ]
        expect_item input, { title: "I'd Like To Baby You" }, "Invalid accession number"
      end

      it "accepts an Unnumbered accession number" do
        input = [
          " Unnumbered        Sheet music: I'd Like To Baby You",
          "                     Livingston, Ray (Composer)",
          "                     Evans, Ray (Lyricist)",
          "                     Aaron Slick From Punkin Crick [Film] (Source)",
          "                     1951",
          "                       NOW LOCATED: SF PALM, Johnson Sheet Music Collection Box 1 (2007/02/22)"
        ]
        expect_item input, { title: "I'd Like To Baby You" }, "Invalid accession number"
      end

      ["Book", "Program", "Sheet  music"].each do |format|
        it "accepts #{format} for Sheet Music" do
          input = [
            " 007.009.00008     #{format}: I'd Like To Baby You",
            "                     Livingston, Ray (Composer)",
            "                     Evans, Ray (Lyricist)",
            "                     Aaron Slick From Punkin Crick [Film] (Source)",
            "                     1951",
            "                       NOW LOCATED: SF PALM, Johnson Sheet Music Collection Box 1 (2007/02/22)"
          ]
          expect_item input, { title: "I'd Like To Baby You" }, %Q("#{format}" instead of "Sheet music")
        end
      end

      it "removes '(Popular Title in Language)' from the title" do
        input = [
          " 007.009.00008     Sheet music: I'd Like To Baby You (Popular Title in English)",
          "                     Livingston, Ray (Composer)",
          "                     Evans, Ray (Lyricist)",
          "                     Aaron Slick From Punkin Crick [Film] (Source)",
          "                     1951",
          "                       NOW LOCATED: SF PALM, Johnson Sheet Music Collection Box 1 (2007/02/22)"
        ]
        expect_item input, title: "I'd Like To Baby You"
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

      it "handles a continued optional field" do
        input = [
          " 007.009.00007     Sheet music: I'd Like To Baby You",
          "                     Livingston, Ray (Composer)",
          "                     Evans, Ray (Lyricist)",
          "                     Aaron Slick From Punkin Crick [Film] (Source)",
          "                     1951",
          "                       NOW LOCATED: SF PALM, Johnson Sheet Music Collection Box 1 (2007/02/22)"
        ]
        expect_item input, source_names: ["Aaron Slick From Punkin Crick"], source_types: ["Film"]
      end

      it "handles a continued optional field with an extra space" do
        input = [
          " 007.009.00007     Sheet music: I'd Like To Baby You",
          "                     Livingston, Ray (Composer)",
          "                     Evans, Ray (Lyricist)",
          "                     Aaron Slick From Punkin Crick",
          "                      [Film] (Source)",
          "                     1951",
          "                       NOW LOCATED: SF PALM, Johnson Sheet Music Collection Box 1 (2007/02/22)"
        ]
        expect_item input, source_names: ["Aaron Slick From Punkin Crick"], source_types: ["Film"]
      end

      %w(Company Music).each do |field_name|
        it "accepts #{field_name} for Composer" do
          input = [
            " 007.009.00007     Sheet music: I'd Like To Baby You",
            "                     Livingston, Ray (#{field_name})",
            "                     Evans, Ray (Lyricist)",
            "                     Aaron Slick From Punkin Crick [Film] (Source)",
            "                     1951",
            "                       NOW LOCATED: SF PALM, Johnson Sheet Music Collection Box 1 (2007/02/22)"
          ]
          expect_item input, { composers: ["Livingston, Ray"] }, %Q("#{field_name}" instead of "Composer")
        end
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

      it "accepts multiple composers" do
        input = [
          " 007.009.00007     Sheet music: I'd Like To Baby You",
          "                     Livingston, Ray (Composer)",
          "                     Livingston, Jay (Composer)",
          "                     Evans, Ray (Lyricist)",
          "                     Aaron Slick From Punkin Crick [Film] (Source)",
          "                     1951",
          "                       NOW LOCATED: SF PALM, Johnson Sheet Music Collection Box 1 (2007/02/22)"
        ]
        expect_item input, composers: ["Livingston, Ray", "Livingston, Jay"]
      end

      it "handles multiple composers in one line" do
        input = [
          " 007.009.00007     Sheet music: I'd Like To Baby You",
          "                     Livingston, Ray / Livingston, Jay (Composer)",
          "                     Evans, Ray (Lyricist)",
          "                     Aaron Slick From Punkin Crick [Film] (Source)",
          "                     1951",
          "                       NOW LOCATED: SF PALM, Johnson Sheet Music Collection Box 1 (2007/02/22)"
        ]
        expect_item input, composers: ["Livingston, Ray", "Livingston, Jay"]
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

      LANGUAGES = %w(American English French German Italian Portuguese Spanish Svensk Swedish)

      (
        LANGUAGES +
        LANGUAGES.
          product(%w(lyric Lyric lyrics Lyrics Lyricist text Text words Words version Version)).
          map { |language, job_description| "#{language} #{job_description}" } +
        ["Additional lyrics", "Additional Lyrics", "Translation"]
      ).each do |job_description|
          it "accepts #{job_description} for Lyricist" do
            input = [
              " 007.009.00007     Sheet music: I'd Like To Baby You",
              "                     Livingston, Ray (Composer)",
              "                     Evans, Ray (#{job_description})",
              "                     Aaron Slick From Punkin Crick [Film] (Source)",
              "                     1951",
              "                       NOW LOCATED: SF PALM, Johnson Sheet Music Collection Box 1 (2007/02/22)"
            ]
            expect_item input, { lyricists: ["Evans, Ray"] }
          end
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

      it "handles multiple lyricists in one line" do
        input = [
          " 007.009.00007     Sheet music: I'd Like To Baby You",
          "                     Livingston, Ray (Composer)",
          "                     Evans, Ray / Evans, Jay (Lyricist)",
          "                     Aaron Slick From Punkin Crick [Film] (Source)",
          "                     1951",
          "                       NOW LOCATED: SF PALM, Johnson Sheet Music Collection Box 1 (2007/02/22)"
        ]
        expect_item input, lyricists: ["Evans, Ray", "Evans, Jay"]
      end

      [
        "Composer & Lyricist",
        "Composer and Lyricist",
        "French Words & Music",
        "French Words and Music",
        "Lyric & Music",
        "Lyric and Music",
        "Lyrics & Music",
        "Lyrics and Music",
        "Music & Lyric",
        "Music and Lyric",
        "Music & Lyrics",
        "Music and Lyrics",
        "Words & Music",
        "Words and Music",
        "Written & Composed",
        "Written and Composed"
      ].each do |job_description|
        it "handles #{job_description}" do
          input = [
            " 007.009.00007     Sheet music: I'd Like To Baby You",
            "                     Livingston, Ray (#{job_description})",
            "                     Aaron Slick From Punkin Crick [Film] (Source)",
            "                     1951",
            "                       NOW LOCATED: SF PALM, Johnson Sheet Music Collection Box 1 (2007/02/22)"
          ]
          expect_item input, composers: ["Livingston, Ray"], lyricists: ["Livingston, Ray"]
        end
      end

      it "handles multiple Composer-&-Lyricists in one line" do
        input = [
          " 007.009.00007     Sheet music: I'd Like To Baby You",
          "                     Livingston, Ray / Livingston, Jay (Composer & Lyricist)",
          "                     Aaron Slick From Punkin Crick [Film] (Source)",
          "                     1951",
          "                       NOW LOCATED: SF PALM, Johnson Sheet Music Collection Box 1 (2007/02/22)"
        ]
        expect_item input,
          composers: ["Livingston, Ray", "Livingston, Jay"], lyricists: ["Livingston, Ray", "Livingston, Jay"]
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

      it "handles a source type initiated by {" do
        input = [
          " 007.009.00007     Sheet music: I'd Like To Baby You",
          "                     Livingston, Ray (Composer)",
          "                     Evans, Ray (Lyricist)",
          "                     Aaron Slick From Punkin Crick {Film] (Source)",
          "                     1951",
          "                       NOW LOCATED: SF PALM, Johnson Sheet Music Collection Box 1 (2007/02/22)"
        ]
        expect_item input, { source_types: ["Film"] }, "Source type not initiated by ["
      end

      it "handles a source type initiated by ]" do
        input = [
          " 007.009.00007     Sheet music: I'd Like To Baby You",
          "                     Livingston, Ray (Composer)",
          "                     Evans, Ray (Lyricist)",
          "                     Aaron Slick From Punkin Crick ]Film] (Source)",
          "                     1951",
          "                       NOW LOCATED: SF PALM, Johnson Sheet Music Collection Box 1 (2007/02/22)"
        ]
        expect_item input, { source_types: ["Film"] }, "Source type not initiated by ["
      end

      it "handles a source type initiated with an extra ]" do
        input = [
          " 007.009.00007     Sheet music: I'd Like To Baby You",
          "                     Livingston, Ray (Composer)",
          "                     Evans, Ray (Lyricist)",
          "                     Aaron Slick From Punkin Crick []Film] (Source)",
          "                     1951",
          "                       NOW LOCATED: SF PALM, Johnson Sheet Music Collection Box 1 (2007/02/22)"
        ]
        expect_item input, { source_types: ["Film"] }, "Source type not initiated by ["
      end

      it "handles a source type terminated by }" do
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

      it "handles a source type terminated by [" do
        input = [
          " 007.009.00007     Sheet music: I'd Like To Baby You",
          "                     Livingston, Ray (Composer)",
          "                     Evans, Ray (Lyricist)",
          "                     Aaron Slick From Punkin Crick [Film[ (Source)",
          "                     1951",
          "                       NOW LOCATED: SF PALM, Johnson Sheet Music Collection Box 1 (2007/02/22)"
        ]
        expect_item input, { source_types: ["Film"] }, "Source type not terminated by ]"
      end

      it "handles a source type followed by ." do
        input = [
          " 007.009.00007     Sheet music: I'd Like To Baby You",
          "                     Livingston, Ray (Composer)",
          "                     Evans, Ray (Lyricist)",
          "                     Aaron Slick From Punkin Crick [Film]. (Source)",
          "                     1951",
          "                       NOW LOCATED: SF PALM, Johnson Sheet Music Collection Box 1 (2007/02/22)"
        ]
        expect_item input, { source_types: ["Film"] }
      end

      it "handles a missing source type" do
        input = [
          " 007.009.00007     Sheet music: I'd Like To Baby You",
          "                     Livingston, Ray (Composer)",
          "                     Evans, Ray (Lyricist)",
          "                     Aaron Slick From Punkin Crick (Source)",
          "                     1951",
          "                       NOW LOCATED: SF PALM, Johnson Sheet Music Collection Box 1 (2007/02/22)"
        ]
        expect_item input, { source_names: ["Aaron Slick From Punkin Crick"], source_types: [nil] }, "No source type"
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

      ['Arranged by', 'Arranger', 'Artist', 'Author', 'Director', 'Performer', 'Photographer'].each do |field_name|
        it "ignores #{field_name}" do
          input = [
            " 007.009.00007     Sheet music: I'd Like To Baby You",
            "                     Livingston, Ray (Composer)",
            "                     Evans, Ray (Lyricist)",
            "                     Buffalo, Biff (#{field_name})",
            "                     Aaron Slick From Punkin Crick [Film] (Source)",
            "                     1951",
            "                       NOW LOCATED: SF PALM, Johnson Sheet Music Collection Box 1 (2007/02/22)"
          ]
          expect_item input, {}
        end
      end

      it "handles an optional field beginning with a non-word character" do
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

      # TODO Dave how much of each of these locations should be included in the output?
      [
        "SF PALM, Stacks Johnson Anth. Box 1",
        "SF PALM, Stacks Johnson Book Box 1",
        "SF PALM, Stacks Johnson Rare Sheet Music Box 1",
        "SF PALM, Stacks Johnson Sheet Music 007.016 Box 1",
        "SF PALM, Shenson Research Room Johnson Rare Sheet Music Box 1",
      ].each do |location|
        it "handles a #{location} location" do
          input = [
            " 007.009.00007     Sheet music: I'd Like To Baby You",
            "                     Livingston, Ray (Composer)",
            "                     Evans, Ray (Lyricist)",
            "                     Aaron Slick From Punkin Crick [Film] (Source)",
            "                     1951",
            "                       NOW LOCATED: #{location} (2007/02/22)"
          ]
          expect(item(input).location).to eq("Box 1")
        end
      end

      [
        "Fort Docs, Regular",
        "SF PALM, Book Truck",
        "SF PALM, Cataloged",
        "SF PALM, Cataloging Shelf",
        "SF PALM, Collection processing",
        "SF PALM, NR",
        "SF PALM, Shenson Research Room",
        "SF PALM, Shenson Research Room Reference",
        "SF PALM, Shenson Research Room Reference shelf",
        "SF PALM, Shenson Research Room Reference Shelf",
        "SF PALM, Shenson Research Room Rererence",
        "SF PALM, Stacks Musical Theater Vocal Scores and Selections",
        "SF PALM, Stacks",
        "SF PALM, Stacks Sheet Music Reference Collection",
        "SF PALM, Stacks Vocal Selections",
        "SF PALM, Stacks Vocal Scores / Selection shelf",
        "SF PALM, Stacks Vocal scores / selections shelf"
      ].each do |location|
        it "handles a #{location} location" do
          input = [
            " 007.009.00007     Sheet music: I'd Like To Baby You",
            "                     Livingston, Ray (Composer)",
            "                     Evans, Ray (Lyricist)",
            "                     Aaron Slick From Punkin Crick [Film] (Source)",
            "                     1951",
            "                       NOW LOCATED: #{location} (2007/02/22)"
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

      it "doesn't hang if there are no optional attributes or dates" do
        input = [
          " 007.009.00007     Sheet music: I'd Like To Baby You",
          "                       NOW LOCATED: SF PALM, Johnson Sheet Music Collection Box 1 (2007/02/22)"
        ]
        expect_item input, {}, "No composer", "No lyricist", "No source", "No date"
      end

      def expect_item(input, attrs, *warnings)
        item = item input
        attrs.each do |name, value|
          expect(item.send name).to eq(value)
        end
        expect(Logger).not_to have_received(:error)
        if warnings.any?
          expect(Logger).to have_received(:warn).
            with("Accepting item with warnings: #{warnings.join '. '}.:\n#{input.join}")
        else
          expect(Logger).not_to have_received(:warn)
        end
      end

      def expect_to_be_invalid(input, warning)
        expect { item input }.to raise_error ArgumentError, warning
        expect(Logger).to have_received(:error).with("Skipping item: #{warning}:\n#{input.join}")
        expect(Logger).not_to have_received(:warn)
      end

      def item(input)
        described_class.new input
      end

    end
  end
end
