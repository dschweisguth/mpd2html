module MPD2HTML
  class Item
    attr_reader :accession_number, :title, :composer, :lyricist, :source, :date, :location

    def initialize(accession_number:, title:, composer:, lyricist:, source:, date: nil, location:)
      @accession_number = accession_number
      @title = title
      @composer = composer
      @lyricist = lyricist
      @source = source
      @date = date
      @location = location
    end
  end
end
