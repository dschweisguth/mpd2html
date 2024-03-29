require_relative '../../lib/mpd2html/item'

module MPD2HTML
  describe Item do
    before do
      allow(Logger).to receive(:warn)
    end

    describe '.new' do
      before do
        allow(Logger).to receive(:error)
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

      [2, 4].each do |digits|
        it "accepts an accession number with a first part with #{digits} digits" do
          input = [
            " #{'0' * digits}.009.12345 Sheet music: I'd Like To Baby You",
            "                     Livingston, Ray (Composer)",
            "                     Evans, Ray (Lyricist)",
            "                     Aaron Slick From Punkin Crick [Film] (Source)",
            "                     1951",
            "                       NOW LOCATED: SF PALM, Johnson Sheet Music Collection Box 1 (2007/02/22)"
          ]
          expect_item input, { title: "I'd Like To Baby You" }, "Invalid accession number"
        end
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

      it "removes a stray year from a composer" do
        input = [
          " 007.009.00007     Sheet music: I'd Like To Baby You",
          "                     1926 Livingston, Ray (Composer)",
          "                     Evans, Ray (Lyricist)",
          "                     Aaron Slick From Punkin Crick [Film] (Source)",
          "                     1951",
          "                       NOW LOCATED: SF PALM, Johnson Sheet Music Collection Box 1 (2007/02/22)"
        ]
        expect_item input, composers: ["Livingston, Ray"]
      end

      it "removes [Photocopy] from a composer" do
        input = [
          " 007.009.00007     Sheet music: I'd Like To Baby You",
          "                     [Photocopy] Livingston, Ray (Composer)",
          "                     Evans, Ray (Lyricist)",
          "                     Aaron Slick From Punkin Crick [Film] (Source)",
          "                     1951",
          "                       NOW LOCATED: SF PALM, Johnson Sheet Music Collection Box 1 (2007/02/22)"
        ]
        expect_item input, composers: ["Livingston, Ray"]
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

      it "removes a stray year from a lyricist" do
        input = [
          " 007.009.00007     Sheet music: I'd Like To Baby You",
          "                     Livingston, Ray (Composer)",
          "                     1926 Evans, Ray (Lyricist)",
          "                     Aaron Slick From Punkin Crick [Film] (Source)",
          "                     1951",
          "                       NOW LOCATED: SF PALM, Johnson Sheet Music Collection Box 1 (2007/02/22)"
        ]
        expect_item input, lyricists: ["Evans, Ray"]
      end

      it "ignores a lyricist ?" do
        input = [
          " 007.009.00007     Sheet music: I'd Like To Baby You",
          "                     Livingston, Ray (Composer)",
          "                     ? (Lyricist)",
          "                     Aaron Slick From Punkin Crick [Film] (Source)",
          "                     1951",
          "                       NOW LOCATED: SF PALM, Johnson Sheet Music Collection Box 1 (2007/02/22)"
        ]
        expect_item input, { lyricists: [] }, ["? lyricist", "No lyricist"]
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

      FieldParser::OptionalField::IGNORED_FIELDS.each do |field_name|
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

      it "treats a line consisting of (####) as a date" do
        input = [
          " 007.009.00007     Sheet music: I'd Like To Baby You",
          "                     Livingston, Ray (Composer)",
          "                     Evans, Ray (Lyricist)",
          "                     Aaron Slick From Punkin Crick [Film] (Source)",
          "                     (1951)",
          "                       NOW LOCATED: SF PALM, Johnson Sheet Music Collection Box 1 (2007/02/22)"
        ]
        expect_item input, dates: ["(1951)"]
      end

      it "treats a line ending in (?) as a date" do
        input = [
          " 007.009.00007     Sheet music: I'd Like To Baby You",
          "                     Livingston, Ray (Composer)",
          "                     Evans, Ray (Lyricist)",
          "                     Aaron Slick From Punkin Crick [Film] (Source)",
          "                     1951 (?)",
          "                       NOW LOCATED: SF PALM, Johnson Sheet Music Collection Box 1 (2007/02/22)"
        ]
        expect_item input, dates: ["1951 (?)"]
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

      it "doesn't hang if there are no optional fields or dates" do
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

    describe '#sort_key' do
      context "when sorting by title" do
        let(:primary_sort_attribute) { :title }

        it "sorts by title, ignoring case" do
          input = [
            " 007.009.00008     Sheet music: I'd Like To Baby You",
            "                       NOW LOCATED: SF PALM, Johnson Sheet Music Collection Box 1 (2007/02/22)"
          ]
          expect_sort_key_to_be input, "i'd like to baby you", ["~"], [], "007.009.00008"
        end

        it "ignores initial parentheses" do
          input = [
            " 007.009.00008     Sheet music: ('Round her neck) She wore a yellow ribbon",
            "                       NOW LOCATED: SF PALM, Johnson Sheet Music Collection Box 1 (2007/02/22)"
          ]
          expect_sort_key_to_be input, "she wore a yellow ribbon", ["~"], [], "007.009.00008"
        end

        %w(A An The).each do |article|
          it "ignores an initial #{article}" do
            input = [
              " 007.009.00008     Sheet music: #{article} Apple",
              "                       NOW LOCATED: SF PALM, Johnson Sheet Music Collection Box 1 (2007/02/22)"
            ]
            expect_sort_key_to_be input, "apple", ["~"], [], "007.009.00008"
          end

          %w(' ").each do |quote|
            it "ignores an initial #{quote} after an initial #{article}" do
              input = [
                " 007.009.00008     Sheet music: #{article} #{quote}Word",
                "                       NOW LOCATED: SF PALM, Johnson Sheet Music Collection Box 1 (2007/02/22)"
              ]
              expect_sort_key_to_be input, "word", ["~"], [], "007.009.00008"
            end
          end

        end

        ["Azure Sky", "Anxiety Blues", "Theme and Variations"].each do |title|
          it "considers an initial article which is actually part of a word" do
            input = [
              " 007.009.00008     Sheet music: #{title}",
              "                       NOW LOCATED: SF PALM, Johnson Sheet Music Collection Box 1 (2007/02/22)"
            ]
            expect_sort_key_to_be input, title.downcase, ["~"], [], "007.009.00008"
          end
        end

        %w(' ").each do |quote|
          it "ignores an initial #{quote}" do
            input = [
              " 007.009.00008     Sheet music: #{quote}Word",
              "                       NOW LOCATED: SF PALM, Johnson Sheet Music Collection Box 1 (2007/02/22)"
            ]
            expect_sort_key_to_be input, "word", ["~"], [], "007.009.00008"
          end

          %w(A An The).each do |article|
            it "ignores an initial #{article} after an initial #{quote}" do
              input = [
                " 007.009.00008     Sheet music: #{quote}#{article} Word",
                "                       NOW LOCATED: SF PALM, Johnson Sheet Music Collection Box 1 (2007/02/22)"
              ]
              expect_sort_key_to_be input, "word", ["~"], [], "007.009.00008"
            end
          end

        end

        it "ignores an initial $" do
          input = [
            " 007.009.00008     Sheet music: $21 A Day - Once a Month",
            "                       NOW LOCATED: SF PALM, Johnson Sheet Music Collection Box 1 (2007/02/22)"
          ]
          expect_sort_key_to_be input, "21 a day - once a month", ["~"], [], "007.009.00008"
        end

        it "sorts an empty title after any other title" do
          input = [
            " 007.009.00008     Sheet music:",
            "                       NOW LOCATED: SF PALM, Johnson Sheet Music Collection Box 1 (2007/02/22)"
          ]
          expect_sort_key_to_be input, "~", ["~"], [], "007.009.00008"
        end

        it "falls back on source names, ignoring case" do
          input = [
            " 007.009.00008     Sheet music: I'd Like To Baby You",
            "                     Aaron Slick From Punkin Crick [Film] (Source)",
            "                       NOW LOCATED: SF PALM, Johnson Sheet Music Collection Box 1 (2007/02/22)"
          ]
          expect_sort_key_to_be input, "i'd like to baby you", ["aaron slick from punkin crick"], ["Film"], "007.009.00008"
        end

        %w(A An The).each do |article|
          it "ignores an initial #{article} in a source name" do
            input = [
              " 007.009.00008     Sheet music: I'd Like To Baby You",
              "                     #{article} Aaron Slick From Punkin Crick [Film] (Source)",
              "                       NOW LOCATED: SF PALM, Johnson Sheet Music Collection Box 1 (2007/02/22)"
            ]
            expect_sort_key_to_be input, "i'd like to baby you", ["aaron slick from punkin crick"], ["Film"], "007.009.00008"
          end

          %w(' ").each do |quote|
            it "ignores an initial #{quote} after an initial #{article} in a source name" do
              input = [
                " 007.009.00008     Sheet music: I'd Like To Baby You",
                "                     #{article} #{quote}Aaron Slick From Punkin Crick [Film] (Source)",
                "                       NOW LOCATED: SF PALM, Johnson Sheet Music Collection Box 1 (2007/02/22)"
              ]
              expect_sort_key_to_be input, "i'd like to baby you", ["aaron slick from punkin crick"], ["Film"], "007.009.00008"
            end
          end

        end

        ["Azure Sky", "Anxiety Blues", "Theme and Variations"].each do |title|
          it "considers an initial article in a source name which is actually part of a word" do
            input = [
              " 007.009.00008     Sheet music: I'd Like To Baby You",
              "                     #{title} [Film] (Source)",
              "                       NOW LOCATED: SF PALM, Johnson Sheet Music Collection Box 1 (2007/02/22)"
            ]
            expect_sort_key_to_be input, "i'd like to baby you", [title.downcase], ["Film"], "007.009.00008"
          end
        end

        %w(' ").each do |quote|
          it "ignores an initial #{quote} in a source name" do
            input = [
              " 007.009.00008     Sheet music: I'd Like To Baby You",
              "                     #{quote}Aaron Slick From Punkin Crick [Film] (Source)",
              "                       NOW LOCATED: SF PALM, Johnson Sheet Music Collection Box 1 (2007/02/22)"
            ]
            expect_sort_key_to_be input, "i'd like to baby you", ["aaron slick from punkin crick"], ["Film"], "007.009.00008"
          end

          %w(A An The).each do |article|
            it "ignores an initial #{article} after an initial #{quote} in a source name" do
              input = [
                " 007.009.00008     Sheet music: I'd Like To Baby You",
                "                     #{quote}#{article} Aaron Slick From Punkin Crick [Film] (Source)",
                "                       NOW LOCATED: SF PALM, Johnson Sheet Music Collection Box 1 (2007/02/22)"
              ]
              expect_sort_key_to_be input, "i'd like to baby you", ["aaron slick from punkin crick"], ["Film"], "007.009.00008"
            end
          end

        end

        it "ignores an initial $ in a source name" do
          input = [
            " 007.009.00008     Sheet music: I'd Like To Baby You",
            "                     $Aaron Slick From Punkin Crick [Film] (Source)",
            "                       NOW LOCATED: SF PALM, Johnson Sheet Music Collection Box 1 (2007/02/22)"
          ]
          expect_sort_key_to_be input, "i'd like to baby you", ["aaron slick from punkin crick"], ["Film"], "007.009.00008"
        end

        it "sorts an empty source name after any other source name" do
          input = [
            " 007.009.00008     Sheet music: I'd Like To Baby You",
            "                     [Film] (Source)",
            "                       NOW LOCATED: SF PALM, Johnson Sheet Music Collection Box 1 (2007/02/22)"
          ]
          expect_sort_key_to_be input, "i'd like to baby you", ["~"], ["Film"], "007.009.00008"
        end

        it "falls back on source types" do
          input = [
            " 007.009.00008     Sheet music: I'd Like To Baby You",
            "                     Aaron Slick From Punkin Crick [Film] (Source)",
            "                       NOW LOCATED: SF PALM, Johnson Sheet Music Collection Box 1 (2007/02/22)"
          ]
          expect_sort_key_to_be input, "i'd like to baby you", ["aaron slick from punkin crick"], ["Film"], "007.009.00008"
        end

        it "sorts a missing source type after any other source type" do
          input = [
            " 007.009.00008     Sheet music: I'd Like To Baby You",
            "                     Aaron Slick From Punkin Crick (Source)",
            "                       NOW LOCATED: SF PALM, Johnson Sheet Music Collection Box 1 (2007/02/22)"
          ]
          expect_sort_key_to_be input, "i'd like to baby you", ["aaron slick from punkin crick"], ["~"], "007.009.00008"
        end

        it "falls back on accession number" do
          input = [
            " 007.009.00008     Sheet music: I'd Like To Baby You",
            "                     Aaron Slick From Punkin Crick [Film] (Source)",
            "                       NOW LOCATED: SF PALM, Johnson Sheet Music Collection Box 1 (2007/02/22)"
          ]
          expect_sort_key_to_be input, "i'd like to baby you", ["aaron slick from punkin crick"], ["Film"], "007.009.00008"
        end

      end

      context "when sorting by composer" do
        let(:primary_sort_attribute) { :composers }

        it "sorts by composers, ignoring case" do
          input = [
            " 007.009.00008     Sheet music: I'd Like To Baby You",
            "                     Livingston, Ray (Composer)",
            "                       NOW LOCATED: SF PALM, Johnson Sheet Music Collection Box 1 (2007/02/22)"
          ]
          expect_sort_key_to_be input, ["livingston, ray"], "i'd like to baby you", ["~"], [], "007.009.00008"
        end

        it "ignores an initial parenthesis" do
          input = [
            " 007.009.00008     Sheet music: I'd Like To Baby You",
            "                     (Old song from County Antrim) (Composer)",
            "                       NOW LOCATED: SF PALM, Johnson Sheet Music Collection Box 1 (2007/02/22)"
          ]
          expect_sort_key_to_be input, ["old song from county antrim)"], "i'd like to baby you", ["~"], [], "007.009.00008"
        end

        it "sorts missing composers after any other composers" do
          input = [
            " 007.009.00008     Sheet music: I'd Like To Baby You",
            "                       NOW LOCATED: SF PALM, Johnson Sheet Music Collection Box 1 (2007/02/22)"
          ]
          expect_sort_key_to_be input, ["~"], "i'd like to baby you", ["~"], [], "007.009.00008"
        end

        it "falls back on title, source name, source type, accession number" do
          input = [
            " 007.009.00008     Sheet music: I'd Like To Baby You",
            "                     Livingston, Ray (Composer)",
            "                     Aaron Slick From Punkin Crick [Film] (Source)",
            "                       NOW LOCATED: SF PALM, Johnson Sheet Music Collection Box 1 (2007/02/22)"
          ]
          expect_sort_key_to_be input, ["livingston, ray"],
            "i'd like to baby you", ["aaron slick from punkin crick"], ["Film"], "007.009.00008"
        end

      end

      context "when sorting by lyricist" do
        let(:primary_sort_attribute) { :lyricists }

        it "sorts by lyricists, ignoring case" do
          input = [
            " 007.009.00008     Sheet music: I'd Like To Baby You",
            "                     Livingston, Ray (Lyricist)",
            "                       NOW LOCATED: SF PALM, Johnson Sheet Music Collection Box 1 (2007/02/22)"
          ]
          expect_sort_key_to_be input, ["livingston, ray"], "i'd like to baby you", ["~"], [], "007.009.00008"
        end

        it "ignores an initial parenthesis" do
          input = [
            " 007.009.00008     Sheet music: I'd Like To Baby You",
            "                     (Traditional) (Lyricist)",
            "                       NOW LOCATED: SF PALM, Johnson Sheet Music Collection Box 1 (2007/02/22)"
          ]
          expect_sort_key_to_be input, ["traditional)"], "i'd like to baby you", ["~"], [], "007.009.00008"
        end

        it "sorts missing lyricists after any other lyricists" do
          input = [
            " 007.009.00008     Sheet music: I'd Like To Baby You",
            "                       NOW LOCATED: SF PALM, Johnson Sheet Music Collection Box 1 (2007/02/22)"
          ]
          expect_sort_key_to_be input, ["~"], "i'd like to baby you", ["~"], [], "007.009.00008"
        end

        it "falls back on title, source name, source type, accession number" do
          input = [
            " 007.009.00008     Sheet music: I'd Like To Baby You",
            "                     Livingston, Ray (Lyricist)",
            "                     Aaron Slick From Punkin Crick [Film] (Source)",
            "                       NOW LOCATED: SF PALM, Johnson Sheet Music Collection Box 1 (2007/02/22)"
          ]
          expect_sort_key_to_be input, ["livingston, ray"],
            "i'd like to baby you", ["aaron slick from punkin crick"], ["Film"], "007.009.00008"
        end

      end

      context "when sorting by source" do
        let(:primary_sort_attribute) { :source_names }

        it "sorts by source name, ignoring case" do
          input = [
            " 007.009.00008     Sheet music: I'd Like To Baby You",
            "                     Aaron Slick From Punkin Crick [Film] (Source)",
            "                       NOW LOCATED: SF PALM, Johnson Sheet Music Collection Box 1 (2007/02/22)"
          ]
          expect_sort_key_to_be input, ["aaron slick from punkin crick"], ["Film"], "i'd like to baby you", "007.009.00008"
        end

        it "sorts missing source names after any other source names" do
          input = [
            " 007.009.00008     Sheet music: I'd Like To Baby You",
            "                       NOW LOCATED: SF PALM, Johnson Sheet Music Collection Box 1 (2007/02/22)"
          ]
          expect_sort_key_to_be input, ["~"], [], "i'd like to baby you", "007.009.00008"
        end

        it "falls back on source type, title, accession number" do
          input = [
            " 007.009.00008     Sheet music: I'd Like To Baby You",
            "                     Aaron Slick From Punkin Crick [Film] (Source)",
            "                       NOW LOCATED: SF PALM, Johnson Sheet Music Collection Box 1 (2007/02/22)"
          ]
          expect_sort_key_to_be input, ["aaron slick from punkin crick"], ["Film"], "i'd like to baby you", "007.009.00008"
        end

      end

      def expect_sort_key_to_be(input, *expected_sort_keys)
        expect(Item.new(input).sort_key primary_sort_attribute  ).to eq([*expected_sort_keys])
      end

    end

    describe 'eql?' do
      it "returns true if all attributes are equal" do
        input = [
          " 007.009.00007     Sheet music: I'd Like To Baby You",
          "                     Livingston, Ray (Composer)",
          "                     Evans, Ray (Lyricist)",
          "                     Aaron Slick From Punkin Crick [Film] (Source)",
          "                     1951",
          "                       NOW LOCATED: SF PALM, Johnson Sheet Music Collection Box 1 (2007/02/22)"
        ]
        one = Item.new input
        other = Item.new input
        expect(one.eql? other).to be_truthy
      end

      it "returns false if accession numbers differ" do
        one = Item.new [
          " 007.009.00007     Sheet music: I'd Like To Baby You",
          "                     Livingston, Ray (Composer)",
          "                     Evans, Ray (Lyricist)",
          "                     Aaron Slick From Punkin Crick [Film] (Source)",
          "                     1951",
          "                       NOW LOCATED: SF PALM, Johnson Sheet Music Collection Box 1 (2007/02/22)"
        ]
        other = Item.new [
          " 007.009.00008     Sheet music: I'd Like To Baby You",
          "                     Livingston, Ray (Composer)",
          "                     Evans, Ray (Lyricist)",
          "                     Aaron Slick From Punkin Crick [Film] (Source)",
          "                     1951",
          "                       NOW LOCATED: SF PALM, Johnson Sheet Music Collection Box 1 (2007/02/22)"
        ]
        expect(one.eql? other).to be_falsy
      end

      it "returns false if titles differ" do
        one = Item.new [
          " 007.009.00007     Sheet music: I'd Like To Baby You",
          "                     Livingston, Ray (Composer)",
          "                     Evans, Ray (Lyricist)",
          "                     Aaron Slick From Punkin Crick [Film] (Source)",
          "                     1951",
          "                       NOW LOCATED: SF PALM, Johnson Sheet Music Collection Box 1 (2007/02/22)"
        ]
        other = Item.new [
          " 007.009.00007     Sheet music: I'd Like To Cradle You",
          "                     Livingston, Ray (Composer)",
          "                     Evans, Ray (Lyricist)",
          "                     Aaron Slick From Punkin Crick [Film] (Source)",
          "                     1951",
          "                       NOW LOCATED: SF PALM, Johnson Sheet Music Collection Box 1 (2007/02/22)"
        ]
        expect(one.eql? other).to be_falsy
      end

      it "returns false if composers differ" do
        one = Item.new [
          " 007.009.00007     Sheet music: I'd Like To Baby You",
          "                     Livingston, Ray (Composer)",
          "                     Evans, Ray (Lyricist)",
          "                     Aaron Slick From Punkin Crick [Film] (Source)",
          "                     1951",
          "                       NOW LOCATED: SF PALM, Johnson Sheet Music Collection Box 1 (2007/02/22)"
        ]
        other = Item.new [
          " 007.009.00007     Sheet music: I'd Like To Baby You",
          "                     Livingston, Jay (Composer)",
          "                     Evans, Ray (Lyricist)",
          "                     Aaron Slick From Punkin Crick [Film] (Source)",
          "                     1951",
          "                       NOW LOCATED: SF PALM, Johnson Sheet Music Collection Box 1 (2007/02/22)"
        ]
        expect(one.eql? other).to be_falsy
      end

      it "returns false if Lyricists differ" do
        one = Item.new [
          " 007.009.00007     Sheet music: I'd Like To Baby You",
          "                     Livingston, Ray (Composer)",
          "                     Evans, Ray (Lyricist)",
          "                     Aaron Slick From Punkin Crick [Film] (Source)",
          "                     1951",
          "                       NOW LOCATED: SF PALM, Johnson Sheet Music Collection Box 1 (2007/02/22)"
        ]
        other = Item.new [
          " 007.009.00007     Sheet music: I'd Like To Baby You",
          "                     Livingston, Ray (Composer)",
          "                     Evans, Jay (Lyricist)",
          "                     Aaron Slick From Punkin Crick [Film] (Source)",
          "                     1951",
          "                       NOW LOCATED: SF PALM, Johnson Sheet Music Collection Box 1 (2007/02/22)"
        ]
        expect(one.eql? other).to be_falsy
      end

      it "returns false if source names differ" do
        one = Item.new [
          " 007.009.00007     Sheet music: I'd Like To Baby You",
          "                     Livingston, Ray (Composer)",
          "                     Evans, Ray (Lyricist)",
          "                     Aaron Slick From Punkin Crick [Film] (Source)",
          "                     1951",
          "                       NOW LOCATED: SF PALM, Johnson Sheet Music Collection Box 1 (2007/02/22)"
        ]
        other = Item.new [
          " 007.009.00007     Sheet music: I'd Like To Baby You",
          "                     Livingston, Ray (Composer)",
          "                     Evans, Ray (Lyricist)",
          "                     Aaron Crick From Punkin Slick [Film] (Source)",
          "                     1951",
          "                       NOW LOCATED: SF PALM, Johnson Sheet Music Collection Box 1 (2007/02/22)"
        ]
        expect(one.eql? other).to be_falsy
      end

      it "returns false if source types differ" do
        one = Item.new [
          " 007.009.00007     Sheet music: I'd Like To Baby You",
          "                     Livingston, Ray (Composer)",
          "                     Evans, Ray (Lyricist)",
          "                     Aaron Slick From Punkin Crick [Film] (Source)",
          "                     1951",
          "                       NOW LOCATED: SF PALM, Johnson Sheet Music Collection Box 1 (2007/02/22)"
        ]
        other = Item.new [
          " 007.009.00007     Sheet music: I'd Like To Baby You",
          "                     Livingston, Ray (Composer)",
          "                     Evans, Ray (Lyricist)",
          "                     Aaron Slick From Punkin Crick [Stage] (Source)",
          "                     1951",
          "                       NOW LOCATED: SF PALM, Johnson Sheet Music Collection Box 1 (2007/02/22)"
        ]
        expect(one.eql? other).to be_falsy
      end

      it "returns false if dates differ" do
        one = Item.new [
          " 007.009.00007     Sheet music: I'd Like To Baby You",
          "                     Livingston, Ray (Composer)",
          "                     Evans, Ray (Lyricist)",
          "                     Aaron Slick From Punkin Crick [Film] (Source)",
          "                     1951",
          "                       NOW LOCATED: SF PALM, Johnson Sheet Music Collection Box 1 (2007/02/22)"
        ]
        other = Item.new [
          " 007.009.00007     Sheet music: I'd Like To Baby You",
          "                     Livingston, Ray (Composer)",
          "                     Evans, Ray (Lyricist)",
          "                     Aaron Slick From Punkin Crick [Film] (Source)",
          "                     1952",
          "                       NOW LOCATED: SF PALM, Johnson Sheet Music Collection Box 1 (2007/02/22)"
        ]
        expect(one.eql? other).to be_falsy
      end

      it "returns false if locations differ" do
        one = Item.new [
          " 007.009.00007     Sheet music: I'd Like To Baby You",
          "                     Livingston, Ray (Composer)",
          "                     Evans, Ray (Lyricist)",
          "                     Aaron Slick From Punkin Crick [Film] (Source)",
          "                     1951",
          "                       NOW LOCATED: SF PALM, Johnson Sheet Music Collection Box 1 (2007/02/22)"
        ]
        other = Item.new [
          " 007.009.00007     Sheet music: I'd Like To Baby You",
          "                     Livingston, Ray (Composer)",
          "                     Evans, Ray (Lyricist)",
          "                     Aaron Slick From Punkin Crick [Film] (Source)",
          "                     1951",
          "                       NOW LOCATED: SF PALM, Johnson Sheet Music Collection Box 2 (2007/02/22)"
        ]
        expect(one.eql? other).to be_falsy
      end

      it "ignores warnings" do
        one = Item.new [
          " 007.009.00007     Sheet music: I'd Like To Baby You",
          "                     Livingston, Ray (Composer)",
          "                     Evans, Ray (Lyricist)",
          "                     Aaron Slick From Punkin Crick [Film] (Source)",
          "                     1951",
          "                       NOW LOCATED: SF PALM, Johnson Sheet Music Collection Box 1 (2007/02/22)"
        ]
        other = Item.new [
          " 007.009.00007     Sheet music: I'd Like To Baby You",
          "                     Livingston, Ray (Composer)",
          "                     Evans, Ray (Lyricist)",
          "                     Harry S. Truman (President)",
          "                     Aaron Slick From Punkin Crick [Film] (Source)",
          "                     1951",
          "                       NOW LOCATED: SF PALM, Johnson Sheet Music Collection Box 1 (2007/02/22)"
        ]
        expect(one.eql? other).to be_truthy
      end

    end

    describe 'hash' do
      it "returns the same value for equal attributes" do
        input = [
          " 007.009.00007     Sheet music: I'd Like To Baby You",
          "                     Livingston, Ray (Composer)",
          "                     Evans, Ray (Lyricist)",
          "                     Aaron Slick From Punkin Crick [Film] (Source)",
          "                     1951",
          "                       NOW LOCATED: SF PALM, Johnson Sheet Music Collection Box 1 (2007/02/22)"
        ]
        one = Item.new input
        other = Item.new input
        expect(one.hash).to eq(other.hash)
      end

      it "returns different values for different accession numbers" do
        one = Item.new [
          " 007.009.00007     Sheet music: I'd Like To Baby You",
          "                     Livingston, Ray (Composer)",
          "                     Evans, Ray (Lyricist)",
          "                     Aaron Slick From Punkin Crick [Film] (Source)",
          "                     1951",
          "                       NOW LOCATED: SF PALM, Johnson Sheet Music Collection Box 1 (2007/02/22)"
        ]
        other = Item.new [
          " 007.009.00008     Sheet music: I'd Like To Baby You",
          "                     Livingston, Ray (Composer)",
          "                     Evans, Ray (Lyricist)",
          "                     Aaron Slick From Punkin Crick [Film] (Source)",
          "                     1951",
          "                       NOW LOCATED: SF PALM, Johnson Sheet Music Collection Box 1 (2007/02/22)"
        ]
        expect(one.hash).not_to eq(other.hash)
      end

      it "returns different values for different titles" do
        one = Item.new [
          " 007.009.00007     Sheet music: I'd Like To Baby You",
          "                     Livingston, Ray (Composer)",
          "                     Evans, Ray (Lyricist)",
          "                     Aaron Slick From Punkin Crick [Film] (Source)",
          "                     1951",
          "                       NOW LOCATED: SF PALM, Johnson Sheet Music Collection Box 1 (2007/02/22)"
        ]
        other = Item.new [
          " 007.009.00007     Sheet music: I'd Like To Cradle You",
          "                     Livingston, Ray (Composer)",
          "                     Evans, Ray (Lyricist)",
          "                     Aaron Slick From Punkin Crick [Film] (Source)",
          "                     1951",
          "                       NOW LOCATED: SF PALM, Johnson Sheet Music Collection Box 1 (2007/02/22)"
        ]
        expect(one.hash).not_to eq(other.hash)
      end

      it "returns different values for different composers" do
        one = Item.new [
          " 007.009.00007     Sheet music: I'd Like To Baby You",
          "                     Livingston, Ray (Composer)",
          "                     Evans, Ray (Lyricist)",
          "                     Aaron Slick From Punkin Crick [Film] (Source)",
          "                     1951",
          "                       NOW LOCATED: SF PALM, Johnson Sheet Music Collection Box 1 (2007/02/22)"
        ]
        other = Item.new [
          " 007.009.00007     Sheet music: I'd Like To Baby You",
          "                     Livingston, Jay (Composer)",
          "                     Evans, Ray (Lyricist)",
          "                     Aaron Slick From Punkin Crick [Film] (Source)",
          "                     1951",
          "                       NOW LOCATED: SF PALM, Johnson Sheet Music Collection Box 1 (2007/02/22)"
        ]
        expect(one.hash).not_to eq(other.hash)
      end

      it "returns different values for different Lyricists" do
        one = Item.new [
          " 007.009.00007     Sheet music: I'd Like To Baby You",
          "                     Livingston, Ray (Composer)",
          "                     Evans, Ray (Lyricist)",
          "                     Aaron Slick From Punkin Crick [Film] (Source)",
          "                     1951",
          "                       NOW LOCATED: SF PALM, Johnson Sheet Music Collection Box 1 (2007/02/22)"
        ]
        other = Item.new [
          " 007.009.00007     Sheet music: I'd Like To Baby You",
          "                     Livingston, Ray (Composer)",
          "                     Evans, Jay (Lyricist)",
          "                     Aaron Slick From Punkin Crick [Film] (Source)",
          "                     1951",
          "                       NOW LOCATED: SF PALM, Johnson Sheet Music Collection Box 1 (2007/02/22)"
        ]
        expect(one.hash).not_to eq(other.hash)
      end

      it "returns different values for different source names" do
        one = Item.new [
          " 007.009.00007     Sheet music: I'd Like To Baby You",
          "                     Livingston, Ray (Composer)",
          "                     Evans, Ray (Lyricist)",
          "                     Aaron Slick From Punkin Crick [Film] (Source)",
          "                     1951",
          "                       NOW LOCATED: SF PALM, Johnson Sheet Music Collection Box 1 (2007/02/22)"
        ]
        other = Item.new [
          " 007.009.00007     Sheet music: I'd Like To Baby You",
          "                     Livingston, Ray (Composer)",
          "                     Evans, Ray (Lyricist)",
          "                     Aaron Crick From Punkin Slick [Film] (Source)",
          "                     1951",
          "                       NOW LOCATED: SF PALM, Johnson Sheet Music Collection Box 1 (2007/02/22)"
        ]
        expect(one.hash).not_to eq(other.hash)
      end

      it "returns different values for different source types" do
        one = Item.new [
          " 007.009.00007     Sheet music: I'd Like To Baby You",
          "                     Livingston, Ray (Composer)",
          "                     Evans, Ray (Lyricist)",
          "                     Aaron Slick From Punkin Crick [Film] (Source)",
          "                     1951",
          "                       NOW LOCATED: SF PALM, Johnson Sheet Music Collection Box 1 (2007/02/22)"
        ]
        other = Item.new [
          " 007.009.00007     Sheet music: I'd Like To Baby You",
          "                     Livingston, Ray (Composer)",
          "                     Evans, Ray (Lyricist)",
          "                     Aaron Slick From Punkin Crick [Stage] (Source)",
          "                     1951",
          "                       NOW LOCATED: SF PALM, Johnson Sheet Music Collection Box 1 (2007/02/22)"
        ]
        expect(one.hash).not_to eq(other.hash)
      end

      it "returns different values for different dates" do
        one = Item.new [
          " 007.009.00007     Sheet music: I'd Like To Baby You",
          "                     Livingston, Ray (Composer)",
          "                     Evans, Ray (Lyricist)",
          "                     Aaron Slick From Punkin Crick [Film] (Source)",
          "                     1951",
          "                       NOW LOCATED: SF PALM, Johnson Sheet Music Collection Box 1 (2007/02/22)"
        ]
        other = Item.new [
          " 007.009.00007     Sheet music: I'd Like To Baby You",
          "                     Livingston, Ray (Composer)",
          "                     Evans, Ray (Lyricist)",
          "                     Aaron Slick From Punkin Crick [Film] (Source)",
          "                     1952",
          "                       NOW LOCATED: SF PALM, Johnson Sheet Music Collection Box 1 (2007/02/22)"
        ]
        expect(one.hash).not_to eq(other.hash)
      end

      it "returns false if locations differ" do
        one = Item.new [
          " 007.009.00007     Sheet music: I'd Like To Baby You",
          "                     Livingston, Ray (Composer)",
          "                     Evans, Ray (Lyricist)",
          "                     Aaron Slick From Punkin Crick [Film] (Source)",
          "                     1951",
          "                       NOW LOCATED: SF PALM, Johnson Sheet Music Collection Box 1 (2007/02/22)"
        ]
        other = Item.new [
          " 007.009.00007     Sheet music: I'd Like To Baby You",
          "                     Livingston, Ray (Composer)",
          "                     Evans, Ray (Lyricist)",
          "                     Aaron Slick From Punkin Crick [Film] (Source)",
          "                     1951",
          "                       NOW LOCATED: SF PALM, Johnson Sheet Music Collection Box 2 (2007/02/22)"
        ]
        expect(one.hash).not_to eq(other.hash)
      end

      it "ignores warnings" do
        one = Item.new [
          " 007.009.00007     Sheet music: I'd Like To Baby You",
          "                     Livingston, Ray (Composer)",
          "                     Evans, Ray (Lyricist)",
          "                     Aaron Slick From Punkin Crick [Film] (Source)",
          "                     1951",
          "                       NOW LOCATED: SF PALM, Johnson Sheet Music Collection Box 1 (2007/02/22)"
        ]
        other = Item.new [
          " 007.009.00007     Sheet music: I'd Like To Baby You",
          "                     Livingston, Ray (Composer)",
          "                     Evans, Ray (Lyricist)",
          "                     Harry S. Truman (President)",
          "                     Aaron Slick From Punkin Crick [Film] (Source)",
          "                     1951",
          "                       NOW LOCATED: SF PALM, Johnson Sheet Music Collection Box 1 (2007/02/22)"
        ]
        expect(one.hash).to eq(other.hash)
      end

    end

  end
end
