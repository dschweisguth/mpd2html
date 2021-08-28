require_relative 'date_parser'
require_relative 'field_parser'

module MPD2HTML
  class OptionalFieldParser < FieldParser
    def self.attribute_names
      %i(composers lyricists source_names source_types)
    end

    attr_reader *attribute_names

    private

    def take(input)
      take_first_lines_matching input, /^ {21,22}(?! )/
    end

    def take_for_parsers(lines)
      [DateParser.new(lines)]
    end

    def parse(lines)
      initialize_attributes
      lines.
        slice_after(/\)$/).
        map { |broken_lines| broken_lines.map(&:strip).join ' ' }.
        each &method(:parse_field)
      assess_missing_attributes
    end

    def initialize_attributes
      @composers = []
      @lyricists = []
      @source_names = []
      @source_types = []
    end

    LANGUAGES = %w(American English French German Italian Portuguese Spanish Svensk Swedish)
    IGNORED_FIELDS = [
      "Adaptation", "Adapted", "Adapted by", "Animator", "Arranged by", "Arranger", "Artist", "Author", "Cartoonist",
      "Compiled by", "Dedicated to", "Director", "Editor", "Musical Director", "Performer", "Photographer", "Publisher"]
    PATTERNS = {
      /\((Composer|Company|Music)\)/                                                          => :add_composer,
      /\((?:Lyricist|Additional [lL]yrics|Translation|#{LANGUAGES.join '|'})\)/               => :add_lyricist,
      /\((?:#{LANGUAGES.join '|'}) (?:[lL]yrics?|[lL]yricist|[tT]ext|[wW]ords|[vV]ersion)\)/  => :add_lyricist,
      /\(Composer (?:&|and) Lyricist\)/                                                       => :add_composer_and_lyricist,
      /\((?:Lyrics?|(?:(?:#{LANGUAGES.join '|'}) )?Words) (?:&|and) Music\)/                  => :add_composer_and_lyricist,
      /\(Music (?:&|and) (?:Lyrics?|Words)\)/                                                 => :add_composer_and_lyricist,
      /\(Written (?:&|and) Composed\)/                                                        => :add_composer_and_lyricist,
      /(?:([\[{\]]\]?)([^\[\]}]+?)((?:\s*-\s*\d{4})?)([\[\]}])\.?\s*)?\(Source\)/             => :add_source_name_and_type,
      /\((?:#{IGNORED_FIELDS.join '|'})\)/                                                    => :ignore_field
    }.map { |pattern, method| [/^(.*?)\s*#{pattern}$/, method] }.to_h

    def parse_field(line)
      PATTERNS.each do |pattern, method|
        match = line.match pattern
        if match
          send method, *match.captures
          return
        end
      end
      warn %Q(Unparseable line: "#{line}")
    end

    def add_composer(composer, field_name)
      if field_name != "Composer"
        warn %Q("#{field_name}" instead of "Composer")
      end
      @composers +=
        composer.
          split(' / ').
          map { |c| c.match(/^(?:\d{4}\s+|\[Photocopy\]\s+)?(.*)/i).captures[0] }
    end

    def add_lyricist(lyricist)
      @lyricists += lyricist.split ' / '
    end

    def add_composer_and_lyricist(composer_and_lyricist)
      composers_and_lyricists = composer_and_lyricist.split ' / '
      @composers += composers_and_lyricists
      @lyricists += composers_and_lyricists
    end

    def add_source_name_and_type(source_name, source_type_initiator, source_type, date_in_source_type, source_type_terminator)
      if source_type.nil?
        warn "No source type"
      else
        if source_type_initiator != '['
          warn "Source type not initiated by ["
        end
        if date_in_source_type != ""
          warn "Source type contains date"
        end
        if source_type_terminator != ']'
          warn "Source type not terminated by ]"
        end
      end
      @source_names << source_name
      @source_types << source_type
    end

    def ignore_field(_value)
    end

    def assess_missing_attributes
      if @composers.empty?
        warn "No composer"
      end
      if @lyricists.empty?
        warn "No lyricist"
      end
      if @source_names.empty?
        warn "No source"
      end
    end

  end
end
