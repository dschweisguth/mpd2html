module MPD2HTML
  class Item
    attr_reader :title, :composer, :lyricist

    def initialize(title:, composer:, lyricist:)
      @title = title
      @composer = composer
      @lyricist = lyricist
    end
  end
end
