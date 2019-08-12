require_relative '../../lib/mpd2html/options'

describe MPD2HTML::Options do
  describe '#parse!' do
    let(:options) { described_class.new }

    it "parses minimal valid options" do
      stub_const 'ARGV', %w(-o output input.txt)
      options.parse!
      expect(options.output_dir).to eq('output')
      expect(options.verbose).to be_falsey
      expect(options.files).to eq(%w(input.txt))
    end

    it "sets verbose to true when -v is given" do
      stub_const 'ARGV', %w(-o output -v input.txt)
      options.parse!
      expect(options.output_dir).to eq('output')
      expect(options.verbose).to be_truthy
      expect(options.files).to eq(%w(input.txt))
    end

    context "watching stderr" do
      class Watcher
        attr_reader :output

        def initialize
          @output = []
        end

        def write(string)
          @output << string
        end

      end

      let(:stderr) { Watcher.new }

      around do |example|
        old_stderr = $stderr
        $stderr = stderr
        begin
          example.run
        ensure
          $stderr = old_stderr
        end
      end

      it "aborts if an output dir was not specified" do
        stub_const 'ARGV', %w(input.txt)
        expect { options.parse! }.to raise_error SystemExit
        expect(stderr.output.first).to match(/Please specify an output directory with -o\./)
      end

      it "aborts if one or more files were not specified" do
        stub_const 'ARGV', %w(-o output)
        expect { options.parse! }.to raise_error SystemExit
        expect(stderr.output.first).to match(/Please specify one or more input files\./)
      end

      it "aborts if an unknown option was specified" do
        stub_const 'ARGV', %w(-x)
        expect { options.parse! }.to raise_error SystemExit
        expect(stderr.output.first).to start_with('Usage:')
      end

      it "prints help and exits if -h was specified" do
        stub_const 'ARGV', %w(-h)
        expect { options.parse! }.to raise_error SystemExit
        expect(stderr.output.first).to start_with('Usage:')
      end

    end

  end
end
