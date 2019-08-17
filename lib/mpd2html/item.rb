require_relative 'logger'

module MPD2HTML
  class Item
    attr_reader :accession_number, :title, :composers, :lyricists, :source_types, :source_names, :dates, :location

    ACCESSION_NUMBER = %r(\d{3}[./]?\d{3,4}[./]?\d{3,6}|Unnumbered)

    def initialize(input)
      @input = input.freeze
      @warnings = []
      remaining_input = @input.dup
      accession_number_and_title_lines = take_accession_number_and_title_lines remaining_input
      parse_accession_number_and_title accession_number_and_title_lines
      optional_attribute_lines, date_lines = take_optional_attribute_and_date_lines remaining_input
      parse_optional_attributes optional_attribute_lines
      parse_dates date_lines
      parse_location remaining_input
      if @warnings.any?
        Logger.warn "Accepting item with warnings: #{@warnings.join '. '}.:\n#{@input.join}"
      end
    end

    private

    def take_accession_number_and_title_lines(input)
      [input.shift] + first_lines_matching(input, /^ {19,20}(?! )/)
    end

    def parse_accession_number_and_title(lines)
      line = lines.map(&:strip).join(' ')
      match = line.match /^(#{ACCESSION_NUMBER})([^\d\s]?)\s+(Sheet music|Program):\s*(.*?)(?:\s*\(Popular Title in \w+\))?$/
      if !match
        reject "No accession number or title"
      end
      accession_number, accession_number_suffix, format, title = *match.captures
      if accession_number !~ /^\d{3}\.\d{3}\.\d{3,5}$/ || accession_number_suffix != ""
        @warnings << "Invalid accession number"
      end
      if format == 'Program'
        @warnings << %Q("Program" instead of "Sheet music")
      end
      @accession_number = accession_number
      @title = title
    end

    def take_optional_attribute_and_date_lines(input)
      general_attribute_lines = first_lines_matching input, /^ {21,22}(?! )/
      date_lines = last_lines_not_matching general_attribute_lines, /\)$/
      [general_attribute_lines, date_lines]
    end

    def parse_optional_attributes(lines)
      initialize_optional_attributes
      lines.
        slice_after(/\)$/).
        map { |broken_lines| broken_lines.map(&:strip).join ' ' }.
        each &method(:parse_optional_attribute)
      assess_missing_optional_attributes
    end

    def initialize_optional_attributes
      @composers = []
      @lyricists = []
      @source_names = []
      @source_types = []
    end

    OPTIONAL_ATTRIBUTE_PATTERNS = {
      /^(.*?)\s*\((Composer|Company)\)$/                              => :add_composer,
      /^(.*?)\s*\(Lyricist\)$/                                        => :add_lyricist,
      /^(.*?)\s*\(Composer & Lyricist\)$/                             => :add_composer_and_lyricist, # TODO Dave handle "Words & Music", maybe others
      /^(.*?)\s*\[([^\]}]+?)((?:\s*-\s*\d{4})?)([\]}])\s*\(Source\)$/ => :add_source_name_and_type,
      /^.*?\s*\(Artist|Performer\)$/                                  => :ignore_field
    }

    def parse_optional_attribute(line)
      OPTIONAL_ATTRIBUTE_PATTERNS.each do |pattern, method|
        match = line.match pattern
        if match
          send method, *match.captures
          return
        end
      end
      @warnings << %Q(Unparseable line: "#{line}")
    end

    def add_composer(composer, field_name)
      if field_name != "Composer"
        @warnings << %Q("#{field_name}" instead of "Composer")
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

    def ignore_field
    end

    def assess_missing_optional_attributes
      if @composers.empty?
        @warnings << "No composer"
      end
      if @lyricists.empty?
        @warnings << "No lyricist"
      end
      if @source_names.empty?
        @warnings << "No source"
      end
    end

    def parse_dates(lines)
      @dates = []
      lines.
        map(&:strip).
        each do |line|
          match = line.match /^(c?\d{4})$/
          if match
            @dates << match.captures.first
          else
            @warnings << %Q(Unparseable date: "#{line}")
          end
        end
      if @dates.empty?
        @warnings << "No date"
      end
    end

    LOCATION_PATTERNS = [
      %r(^NOW LOCATED: SF PALM, Johnson Sheet Music Collection\s*(.*?)\s*\(\d{4}/\d{2}/\d{2}\)$),
      %r(^NOW LOCATED: SF PALM, (Shenson Research Room(?: Reference shelf)?)\s*\(\d{4}/\d{2}/\d{2}\)$),
      %r(^NOW LOCATED: SF PALM, Shenson Research Room Johnson Rare Sheet Music\s*(.*?)\s*\(\d{4}/\d{2}/\d{2}\)$),
      %r(^NOW LOCATED: SF PALM, (Stacks)\s*\(\d{4}/\d{2}/\d{2}\)$),
      %r(^NOW LOCATED: SF PALM, Stacks Johnson Rare Sheet Music\s*(.*?)\s*\(\d{4}/\d{2}/\d{2}\)$),
      %r(^NOW LOCATED: SF PALM, Stacks Johnson Sheet Music\s*\d+\.\d+\s*(.*?)\s*\(\d{4}/\d{2}/\d{2}\)$)
    ]

    def parse_location(input)
      line = input.map(&:strip).join ' '
      LOCATION_PATTERNS.each do |pattern|
        match = pattern.match line
        if match
          @location = match.captures.first
          break
        end
      end
      if !@location
        reject "No location"
      end
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

    def reject(warning)
      Logger.error "Skipping item: #{warning}:\n#{@input.join}"
      raise ArgumentError, warning
    end

  end
end
