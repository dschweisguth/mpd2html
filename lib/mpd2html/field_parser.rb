module MPD2HTML
  class FieldParser
    attr_reader :warnings

    def initialize
      @parsers = []
      @warnings = []
    end

    def parsers
      @parsers
    end

    protected

    def take_first_lines_matching(lines, pattern)
      first_lines = []
      while lines.first =~ pattern
        first_lines << lines.shift
      end
      first_lines
    end

    def warn(message)
      warnings << message
    end

  end
end
