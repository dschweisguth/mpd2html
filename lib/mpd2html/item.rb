module MPD2HTML
  class Item
    attr_reader :title, :composer, :lyricist, :source

    def initialize(title:, composer:, lyricist:, source:)
      @title = title
      @composer = composer
      @lyricist = lyricist
      @source = source
    end
  end
end
