require_relative 'options'

module MPD2HTML
  class MPD2HTML
    def run
      options = Options.new
      options.parse!
      FileUtils.mkdir_p options.output_dir
      input = options.files.map { |file| IO.read file }.join
      IO.write "#{options.output_dir}/index.html", input
    end
  end
end
