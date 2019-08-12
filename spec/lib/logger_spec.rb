require_relative '../../lib/mpd2html/logger'

module MPD2HTML
  describe Logger do
    let(:message) { "message" }

    before do
      allow(Kernel).to receive(:warn)
    end

    describe '.error' do
      it "passes the message to Kernel.warn if verbose is false" do
        Logger.verbose = false
        described_class.error message
        expect(Kernel).to have_received(:warn).with(message)
      end

      it "passes the message to Kernel.warn if verbose is true" do
        Logger.verbose = true
        described_class.error message
        expect(Kernel).to have_received(:warn).with(message)
      end

    end

    describe '.warn' do
      it "does nothing if verbose is false" do
        Logger.verbose = false
        described_class.warn message
        expect(Kernel).not_to have_received(:warn)
      end

      it "passes the message to Kernel.warn if verbose is true" do
        Logger.verbose = true
        described_class.warn message
        expect(Kernel).to have_received(:warn).with(message)
      end

    end

  end
end
