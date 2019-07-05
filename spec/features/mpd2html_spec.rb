feature "HTML generation from accessioning system dump" do
  let(:output_dir) { '/tmp/mpd2html-test-output' }

  scenario "User generates HTML" do
    run_mpd2html "two-items.txt"

    visit_page

    page_has_text "I'd Like To Baby You"
    page_has_text "Life Is a Beautiful Thing"
  end

  def run_mpd2html(file)
    FileUtils.rm_rf output_dir
    stub_const 'ARGV', ['-o', output_dir, "spec/features/mpd2html_spec/#{file}"]
    MPD2HTML::MPD2HTML.new.run
  end

  def visit_page
    visit "#{output_dir}/index.html"
  end

  def page_has_text(text)
    expect(page).to have_text(text)
  end

end
