require 'optparse'

module MPD2HTML
  class Options
    attr_reader :output_dir, :files

    def initialize
      @output_dir = nil
    end

    def parse!
      parser = OptionParser.new do |op|
        op.banner = "Usage: #{$PROGRAM_NAME} -o OUTPUT_DIR [other options] file [...]"

        op.on('-o OUTPUT_DIR', "Output directory") do |output_dir|
          @output_dir = output_dir
        end

        # -h and --help work by default, but implement them explicitly so they're
        # documented
        op.on("-h", "--help", "Prints this help") do
          warn op.to_s
          exit
        end

      end
      begin
        parser.parse!
      rescue OptionParser::ParseError
        abort parser.to_s
      end
      if !@output_dir
        abort_with_help parser, "Please specify an output directory with -o."
      end
      if ARGV.empty?
        abort_with_help parser, "Please specify one or more input files."
      end
      @files = ARGV
    end

    def abort_with_help(parser, message)
      abort "#{message}\n#{parser}"
    end

  end
end
