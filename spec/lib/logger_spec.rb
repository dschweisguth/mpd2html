require_relative '../../lib/mpd2html/logger'

module MPD2HTML
  describe Logger do
    describe '.warn' do
      it "passes the message to Kernel.warn" do
        allow(Kernel).to receive(:warn)
        message = "foo"
        described_class.warn message
        expect(Kernel).to have_received(:warn).with(message)
      end
    end
  end
end
