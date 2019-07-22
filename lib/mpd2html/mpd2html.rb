require 'erubis'
require_relative 'item'
require_relative 'options'

module MPD2HTML
  class MPD2HTML
    def run
      options = Options.new
      options.parse!
      write_html(options)
    end

    private

    def write_html(options)
      FileUtils.mkdir_p options.output_dir
      template = IO.read File.expand_path("#{File.dirname __FILE__}/../../template/index.html.erb")
      bindings = { items: items(options.files) }
      page = Erubis::Eruby.new(template).result(bindings)
      IO.write "#{options.output_dir}/index.html", page
    end

    # TODO Dave test two files
    def items(files)
      files.map { |file| items_for file }.flatten
    end

    def items_for(file)
      IO.readlines(file).
        reject { |line| line =~ /^\s*$/ }.
        reject { |line| line =~ /^Browse List/ }.
        reject { |line| line =~ /^\s*Accession/ }.
        slice_before(/^\s*\d+\.\d+\.\d+/).
        map { |lines| item(lines) }
    end

    def item(lines)
      attrs = lines.
        slice_before(/^(?:\s|\s{21}|\s{23})\b/).
        map { |broken_lines| broken_lines.map(&:strip).join ' ' }.
        each_with_object({}) do |line, attrs|
          case line
            when /Sheet music:\s*(.*)/
              attrs[:title] = $1
              attrs[:title].sub!(/\s*\(Popular Title in English\)\s*$/, '')
            when /\s*(.*)\s*\(Composer\)/
              attrs[:composer] = $1
            when /\s*(.*)\s*\(Lyricist\)/
              attrs[:lyricist] = $1
            when /\s*(.*)\s*\(Source\)/
              attrs[:source] = $1
          end
        end
      Item.new(**attrs)
    end

  end
end
