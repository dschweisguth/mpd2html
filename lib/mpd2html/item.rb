require_relative 'logger'

module MPD2HTML
  class Item
    attr_reader :accession_number, :title, :composers, :lyricists, :source_type, :source_name, :date, :location

    ACCESSION_NUMBER = /\d{3}\.\d{3}\.\d{3,6}/

    def initialize(input)
      @composers = []
      @lyricists = []
      set_attributes input
      if @warnings.any?
        Logger.warn((@valid ? "Accepting" : "Skipping") +
          " item with warnings: #{concatenated_warnings}:\n#{input.join}")
      end
      if !@valid
        raise ArgumentError, concatenated_warnings
      end
    end

    private

    def set_attributes(input)
      @valid = true
      @warnings = []
      input.
        slice_before(/^(?: | {21}| {23})(?! )/).
        map { |broken_lines| broken_lines.map(&:strip).join ' ' }.
        each &method(:set_some_attributes)
      if !@accession_number
        @valid = false
        @warnings << "No accession number or title"
      end
      if @composers.empty?
        @valid = false
        @warnings << "No composer"
      end
      if @lyricists.empty?
        @warnings << "No lyricist"
      end
      if !@source_name
        @warnings << "No source"
      end
      if !@date
        @warnings << "No date"
      end
      if !@location
        @valid = false
        @warnings << "No location"
      end
    end

    PATTERNS = {
      set_accession_number_and_title: /^(#{ACCESSION_NUMBER})([^\d\s]?)\s+(Sheet music|Program):\s*(.*?)(?:\s*\(Popular Title in \w+\))?$/,
      add_composer:                   /^(.*?)\s*\((Composer|Company)\)$/,
      add_lyricist:                   /^(.*?)\s*\(Lyricist\)$/,
      add_composer_and_lyricist:      /^(.*?)\s*\(Composer & Lyricist\)$/,
      set_source_name_and_type:       /^(.*?)\s*\[([^\]}]+?)((?:\s*-\s*\d{4})?)([\]}])\s*\(Source\)$/,
      set_date:                       /^(c?\d{4})$/,
      set_location:                   %r(^NOW LOCATED: SF PALM, Johnson Sheet Music Collection\s*(.*?)\s*\(\d{4}/\d{2}/\d{2}\)$)
    }

    def set_some_attributes(line)
      PATTERNS.each do |method, pattern|
        match = line.match pattern
        if match
          send method, *match.captures
          break
        end
      end
    end

    def set_accession_number_and_title(accession_number, accession_number_suffix, format, title)
      if accession_number !~ /^\d{3}\.\d{3}\.\d{3,5}$/ || accession_number_suffix != ""
        @warnings << "Invalid accession number"
      end
      if format == 'Program'
        @warnings << %Q("Program" instead of "Sheet music")
      end
      if @accession_number
        @warnings << "More than one accession number and title"
        @valid = false
        return
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

    def set_source_name_and_type(source_name, source_type, date_in_source_type, source_type_terminator)
      if date_in_source_type != ""
        @warnings << "Source type contains date"
      end
      if source_type_terminator != ']'
        @warnings << "Source type not terminated by ]"
      end
      if @source_name
        @warnings << "More than one source"
        @valid = false
        return
      end
      @source_name = source_name
      @source_type = source_type
    end

    def set_date(date)
      set_scalar_attribute :date, date
    end

    def set_location(location)
      set_scalar_attribute :location, location
    end

    def set_scalar_attribute(name, value)
      instance_variable_name = "@#{name}"
      if instance_variable_get instance_variable_name
        @warnings << "More than one #{name}"
        @valid = false
        return
      end
      instance_variable_set instance_variable_name, value
    end

    def concatenated_warnings
      "#{@warnings.join '. '}."
    end

  end
end
