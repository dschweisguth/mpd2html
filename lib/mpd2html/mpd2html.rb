require 'fileutils'
require_relative 'options'
require_relative 'page'
require_relative 'parser'

module MPD2HTML
  class MPD2HTML
    def run
      options = Options.new
      options.parse!
      Logger.verbose = options.verbose
      items = Parser.new.items options.files
      Page::ALL.each do |page|
        page.render items, options.output_dir
      end
      FileUtils.cp Dir.glob("#{File.dirname __FILE__}/../../assets/*"), options.output_dir
    end
  end
end
