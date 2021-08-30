require_relative '../../../lib/mpd2html/page/context'
require_relative '../../../lib/mpd2html/page/title'

module MPD2HTML
  module Page
    describe Context do
      let(:context) { Context.new Title.new, [] }

      describe '#with_breaks' do
        it "concatenates strings with HTML breaks" do
          expect(context.with_breaks ["a", "b"]).to eq("a<br/>b")
        end

        it "ignores nil" do
          expect(context.with_breaks ["a", nil, "b"]).to eq("a<br/>b")
        end

      end
    end
  end
end
