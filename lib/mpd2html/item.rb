module MPD2HTML
  class Item
    attr_reader :title, :composer, :lyricist, :source, :location

    def initialize(title:, composer:, lyricist:, source:, location:)
      @title = title
      @composer = composer
      @lyricist = lyricist
      @source = source
      @location = location
    end
  end
end
