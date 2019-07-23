module MPD2HTML
  class Item
    REQUIRED_ATTRIBUTES = %i(accession_number title composer lyricist source_type source_name location)

    attr_reader :accession_number, :title, :composer, :lyricist, :source_type, :source_name, :date, :location

    def initialize(accession_number:, title:, composer:, lyricist:, source_type:, source_name:, date: nil, location:)
      @accession_number = accession_number
      @title = title
      @composer = composer
      @lyricist = lyricist
      @source_type = source_type
      @source_name = source_name
      @date = date
      @location = location
    end
  end
end
