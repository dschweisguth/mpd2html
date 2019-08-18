require_relative 'attribute_parser'

module MPD2HTML
  class OptionalAttributeParser < AttributeParser
    def self.attribute_names
      %i(composers lyricists source_names source_types)
    end

    attr_reader *attribute_names

    def initialize(input)
      super()
      initialize_attributes
      input.
        slice_after(/\)$/).
        map { |broken_lines| broken_lines.map(&:strip).join ' ' }.
        each &method(:parse_attribute)
      assess_missing_attributes
    end

    def initialize_attributes
      @composers = []
      @lyricists = []
      @source_names = []
      @source_types = []
    end

    OPTIONAL_ATTRIBUTE_PATTERNS = {
      /^(.*?)\s*\((Composer|Company)\)$/                                                                                  => :add_composer,
      /^(.*?)\s*\(Lyricist\)$/                                                                                            => :add_lyricist,
      /^(.*?)\s*\((?:Composer (?:&|and) Lyricist|(?:Lyrics?|Words) (?:&|and) Music|Music (?:&|and) (?:Lyrics?|Words))\)$/ => :add_composer_and_lyricist,
      /^(.*?)\s*(?:([\[{\]]\]?)([^\[\]}]+?)((?:\s*-\s*\d{4})?)([\[\]}])\.?\s*)?\(Source\)$/                               => :add_source_name_and_type,
      /^.*?\s*\(Arranged by|Arranger|Artist|Author|Director|Performer|Photographer\)$/                                    => :ignore_field
    }

    def parse_attribute(line)
      OPTIONAL_ATTRIBUTE_PATTERNS.each do |pattern, method|
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
      @composers += composer.split ' / '
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

    def ignore_field
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
