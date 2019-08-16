require_relative 'logger'

module MPD2HTML
  class Item
    attr_reader :accession_number, :title, :composers, :lyricists, :source_types, :source_names, :dates, :location

    ACCESSION_NUMBER = %r(\d{3}[./]?\d{3,4}[./]?\d{3,6}|Unnumbered)

    def initialize(input)
      @input = input.freeze
      @valid = true
      @warnings = []
      initialize_attributes
      parse
      assess_missing_attributes
      maybe_warn_or_raise
    end

    private

    def initialize_attributes
      @composers = []
      @lyricists = []
      @source_names = []
      @source_types = []
      @dates = []
    end

    def parse
      input = @input.dup

      accession_number_and_title_lines = [input.shift] + first_lines_matching(input, /^ {19,20}(?! )/)
      parse_line accession_number_and_title_lines.map(&:strip).join(' ')

      general_attr_lines = first_lines_matching(input, /^ {21,22}(?! )/)
      date_lines = last_lines_not_matching general_attr_lines, /\)$/
      general_attr_lines.
        slice_after(/\)$/).
        map { |broken_lines| broken_lines.map(&:strip).join ' ' }.
        each &method(:parse_line)
      date_lines.map(&:strip).each &method(:parse_line)

      parse_line input.map(&:strip).join(' ')
    end

    def first_lines_matching(lines, pattern)
      first_lines = []
      while lines.first =~ pattern
        first_lines << lines.shift
      end
      first_lines
    end

    def last_lines_not_matching(lines, pattern)
      last_lines = []
      while lines.last !~ pattern
        last_lines.unshift lines.pop
      end
      last_lines
    end

    def assess_missing_attributes
      if !@accession_number
        @valid = false
        @warnings << "No accession number or title"
      end
      if @composers.empty?
        @warnings << "No composer"
      end
      if @lyricists.empty?
        @warnings << "No lyricist"
      end
      if @source_names.empty?
        @warnings << "No source"
      end
      if @dates.empty?
        @warnings << "No date"
      end
    end

    def maybe_warn_or_raise
      if @valid
        if @warnings.any?
          Logger.warn "Accepting item with warnings: #{concatenated_warnings}:\n#{@input.join}"
        end
      else
        Logger.error "Skipping item with warnings: #{concatenated_warnings}:\n#{@input.join}"
        raise ArgumentError, concatenated_warnings
      end
    end

    PATTERNS = {
      /^(#{ACCESSION_NUMBER})([^\d\s]?)\s+(Sheet music|Program):\s*(.*?)(?:\s*\(Popular Title in \w+\))?$/        => :set_accession_number_and_title,
      /^(.*?)\s*\((Composer|Company)\)$/                                                                          => :add_composer,
      /^(.*?)\s*\(Lyricist\)$/                                                                                    => :add_lyricist,
      /^(.*?)\s*\(Composer & Lyricist\)$/                                                                         => :add_composer_and_lyricist, # TODO Dave handle "Words & Music", maybe others
      /^(.*?)\s*\[([^\]}]+?)((?:\s*-\s*\d{4})?)([\]}])\s*\(Source\)$/                                             => :add_source_name_and_type,
      /^.*?\s*\(Artist|Performer\)$/                                                                              => :ignore_field,
      /^(c?\d{4})$/                                                                                               => :add_date,
      %r(^NOW LOCATED: SF PALM, Johnson Sheet Music Collection\s*(.*?)\s*\(\d{4}/\d{2}/\d{2}\)$)                  => :set_location,
      %r(^NOW LOCATED: SF PALM, (Shenson Research Room(?: Reference shelf)?)\s*\(\d{4}/\d{2}/\d{2}\)$)            => :set_location,
      %r(^NOW LOCATED: SF PALM, Shenson Research Room Johnson Rare Sheet Music\s*(.*?)\s*\(\d{4}/\d{2}/\d{2}\)$)  => :set_location,
      %r(^NOW LOCATED: SF PALM, (Stacks)\s*\(\d{4}/\d{2}/\d{2}\)$)                                                => :set_location,
      %r(^NOW LOCATED: SF PALM, Stacks Johnson Rare Sheet Music\s*(.*?)\s*\(\d{4}/\d{2}/\d{2}\)$)                 => :set_location,
      %r(^NOW LOCATED: SF PALM, Stacks Johnson Sheet Music\s*\d+\.\d+\s*(.*?)\s*\(\d{4}/\d{2}/\d{2}\)$)           => :set_location
    }

    def parse_line(line)
      PATTERNS.each do |pattern, method|
        match = line.match pattern
        if match
          send method, *match.captures
          return
        end
      end
      @warnings << %Q(Unparseable line: "#{line}")
    end

    def set_accession_number_and_title(accession_number, accession_number_suffix, format, title)
      if accession_number !~ /^\d{3}\.\d{3}\.\d{3,5}$/ || accession_number_suffix != ""
        @warnings << "Invalid accession number"
      end
      if format == 'Program'
        @warnings << %Q("Program" instead of "Sheet music")
      end
      @accession_number = accession_number
      @title = title
    end

    def add_composer(composer, field_name)
      if field_name != "Composer"
        @warnings << %Q("#{field_name}" instead of "Composer")
      end
      @composers << composer
    end

    def add_lyricist(lyricist)
      @lyricists << lyricist
    end

    def add_composer_and_lyricist(composer_and_lyricist)
      @composers << composer_and_lyricist
      @lyricists << composer_and_lyricist
    end

    def add_source_name_and_type(source_name, source_type, date_in_source_type, source_type_terminator)
      if date_in_source_type != ""
        @warnings << "Source type contains date"
      end
      if source_type_terminator != ']'
        @warnings << "Source type not terminated by ]"
      end
      @source_names << source_name
      @source_types << source_type
    end

    def add_date(date)
      @dates << date
    end

    def set_location(location)
      @location = location
    end

    def ignore_field
    end

    def concatenated_warnings
      "#{@warnings.join '. '}."
    end

  end
end
