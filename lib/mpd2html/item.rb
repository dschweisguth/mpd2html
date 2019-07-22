module MPD2HTML
  class Item
    attr_reader :title, :composer

    def initialize(title:, composer:)
      @title = title
      @composer = composer
    end
  end
end
