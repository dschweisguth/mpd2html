require 'fileutils'
require_relative 'options'
require_relative 'page/composers'
require_relative 'page/title'
require_relative 'parser'

module MPD2HTML
  class MPD2HTML
    PAGES = [Page::Title, Page::Composers]

    def run
      options = Options.new
      options.parse!
      Logger.verbose = options.verbose
      items = Parser.new.items options.files
      PAGES.each do |page_class|
        page_class.new.render items, options.output_dir
      end
      FileUtils.cp Dir.glob("#{File.dirname __FILE__}/../../assets/*"), options.output_dir
    end

  end
end
