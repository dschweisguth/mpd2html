require_relative 'item'

module MPD2HTML
  class Parser
    # TODO Dave test two files
    def self.items(files)
      files.map { |file| items_for file }.flatten
    end

    def self.items_for(file)
      IO.readlines(file).
        reject { |line| line =~ /^\s*$/ }.
        reject { |line| line =~ /^Browse List/ }.
        reject { |line| line =~ /^\s*Accession/ }.
        slice_before(/^\s*\d+\.\d+\.\d+/).
        map { |lines| item(lines) }.compact
    end

    def self.item(lines)
      attrs = lines.
        slice_before(/^(?:\s|\s{21}|\s{23})\b/).
        map { |broken_lines| broken_lines.map(&:strip).join ' ' }.
        each_with_object({}) do |line, attrs|
        case line
          when /(\d{3}\.\d{3}\.\d{5})\s+Sheet music:\s*(.*)/
            attrs[:accession_number] = $1
            attrs[:title] = $2
            attrs[:title].sub!(/\s*\(Popular Title in English\)\s*$/, '')
          when /\s*(.*)\s*\(Composer\)/
            attrs[:composer] = $1
          when /\s*(.*)\s*\(Lyricist\)/
            attrs[:lyricist] = $1
          when /\s*(.*)\s*\(Source\)/
            attrs[:source] = $1
          when /^\s*(\d{4})\s*$/
            attrs[:date] = $1
          when /NOW LOCATED: SF PALM, Johnson Sheet Music Collection\s*(.*)/
            attrs[:location] = $1
            attrs[:location].sub!(%r(\s*\(\d{4}/\d{2}/\d{2}\)\s*$), '')
        end
      end
      if attrs[:accession_number] && attrs[:title] && attrs[:composer] && attrs[:lyricist] && attrs[:source] && attrs[:location]
        Item.new(**attrs)
      else
        warn "Skipping invalid entry:"
        warn lines
        nil
      end
    end

  end
end
