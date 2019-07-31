module MPD2HTML
  class Item
    attr_reader :accession_number, :title, :composers, :lyricists, :source_type, :source_name, :date, :location

    def initialize(accession_number:, title:, composers:, lyricists:, source_type:, source_name:, date: nil, location:)
      if !(accession_number && title && composers.any? && lyricists.any? && source_type && source_name && location)
        raise ArgumentError
      end
      @accession_number = accession_number
      @title = title
      @composers = composers
      @lyricists = lyricists
      @source_type = source_type
      @source_name = source_name
      @date = date
      @location = location
    end

    def ==(other)
      other.class == self.class && other.state == self.state
    end

    protected def state
      self.instance_variables.map { |variable| self.instance_variable_get variable }
    end

  end
end
