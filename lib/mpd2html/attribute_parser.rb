module MPD2HTML
  class AttributeParser
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
