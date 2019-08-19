module MPD2HTML
  class FieldParser
    attr_reader :warnings

    def initialize
      @warnings = []
    end

    protected

    def warn(message)
      warnings << message
    end
  end
end
