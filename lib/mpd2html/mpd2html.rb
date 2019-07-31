require 'erubis'
require 'fileutils'
require_relative 'options'
require_relative 'parser'

module MPD2HTML
  class MPD2HTML
    def run
      options = Options.new
      options.parse!
      items = Parser.new.items options.files
      write_html(items, options.output_dir)
    end

    private

    def write_html(items, output_dir)
      FileUtils.mkdir_p output_dir
      IO.write "#{output_dir}/index.html", page(items)
    end

    def page(items)
      template = IO.read File.expand_path("#{File.dirname __FILE__}/../../template/index.html.erb")
      Erubis::Eruby.new(template).result items: items
    end

  end
end
