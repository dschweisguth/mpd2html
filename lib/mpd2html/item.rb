module MPD2HTML
  class Item
    attr_reader :accession_number, :title, :composer, :lyricist, :source, :location

    def initialize(accession_number:, title:, composer:, lyricist:, source:, location:)
      @accession_number = accession_number
      @title = title
      @composer = composer
      @lyricist = lyricist
      @source = source
      @location = location
    end
  end
end
