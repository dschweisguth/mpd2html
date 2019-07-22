feature "HTML generation from accessioning system dump" do
  let(:output_dir) { '/tmp/mpd2html-test-output' }

  scenario "User generates HTML" do
    run_mpd2html "two-items.txt"
    visit_page
    page_has_table_with_data [
      [
        "007.009.00007",
        "I'd Like To Baby You",
        "Livingston, Ray",
        "Evans, Ray",
        "Film",
        "Aaron Slick From Punkin Crick",
        "1951",
        "Box 1"
      ],
      [
        "007.009.00008",
        "Life Is a Beautiful Thing",
        "Livingston, Jay",
        "Evans, Ray",
        "Film",
        "Aaron Slick From Punkin Crick",
        "",
        "Box 1"
      ]
    ]
  end

  def run_mpd2html(file)
    FileUtils.rm_rf output_dir
    stub_const 'ARGV', ['-o', output_dir, "spec/features/mpd2html_spec/#{file}"]
    MPD2HTML::MPD2HTML.new.run
  end

  def visit_page
    visit "#{output_dir}/index.html"
  end

  def page_has_table_with_data(expected_data)
    actual_data = page.all('tr').to_a.tap(&:shift).map { |row| row.all('td').map(&:text) }
    expect(actual_data).to eq(expected_data)
  end

end
