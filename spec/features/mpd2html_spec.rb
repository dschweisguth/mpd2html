require_relative '../../lib/mpd2html/mpd2html'

feature "Generate HTML from accessioning system dump" do
  let(:output_dir) { '/tmp/mpd2html-test-output' }

  scenario "User generates HTML" do
    run_mpd2html "item.txt"
    MPD2HTML::MPD2HTML::PAGES.each do |page_class|
      visit_page_for page_class
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
        ]
      ]
    end
  end

  scenario "User sorts by title" do
    run_mpd2html "title.txt"
    visit_page_for MPD2HTML::Page::Title
    expect(page.all 'link[rel="canonical"]', visible: false).to be_empty
    page_has_sorted_column MPD2HTML::Page::Title
    page_has_links_to_sort_other_columns MPD2HTML::Page::Title
    page_has_table_with_data sort_test_data_sorted_by(MPD2HTML::Page::Title)
  end

  scenario "User sorts by composers" do
    run_mpd2html "composers.txt"
    visit_page_for MPD2HTML::Page::Composers
    expect(page.find('link[rel="canonical"]', visible: false)[:href]).
      to eq("https://mpdsf.github.io/assets/johnson-collection.html")
    page_has_sorted_column MPD2HTML::Page::Composers
    page_has_links_to_sort_other_columns MPD2HTML::Page::Composers
    page_has_table_with_data sort_test_data_sorted_by(MPD2HTML::Page::Composers)
  end

  def run_mpd2html(file)
    FileUtils.rm_rf output_dir
    stub_const 'ARGV', ['-o', output_dir, "spec/features/mpd2html_spec/#{file}"]
    MPD2HTML::MPD2HTML.new.run
  end

  def visit_page_for(page_class)
    visit "#{output_dir}/#{page_class.new.basename}.html"
  end

  def page_has_sorted_column(page_class)
    expect(page.all('th').count { |th| th.text == "#{page_class.new.primary_sort_column_name} ▽" }).to eq(1)
  end

  def page_has_links_to_sort_other_columns(page_class)
    MPD2HTML::MPD2HTML::PAGES.reject { |other_page_class| other_page_class == page_class }.each do |other_page_class|
      other_page_object = other_page_class.new
      expect(page.find(%Q(th a[href="#{other_page_object.basename}.html"])).text).
        to eq(other_page_object.primary_sort_column_name)
    end
  end

  def page_has_table_with_data(expected_data)
    actual_data = page.all('tr').to_a.tap(&:shift).map { |row| row.all('td').map(&:text) }
    expect(actual_data).to eq(expected_data)
  end

  DATA_THAT_ALWAYS_SORTS_FIRST = [
    "000.000.00001",
    "Always",
    "Ager, Ray",
    "Arlen, Ray",
    "Film",
    "Always an Answer",
    "1901",
    "Box 1"
  ]

  DATA_THAT_ALWAYS_SORTS_MIDDLE = [
    "000.000.00002",
    "Be My Baby",
    "Brown, Ray",
    "Black, Ray",
    "Film",
    "Bye Bye Bluebird",
    "1902",
    "Box 2"
  ]

  DATA_THAT_ALWAYS_SORTS_LAST = [
    "000.000.00003",
    "Call Me",
    "Charles, Ray",
    "Cohn, Ray",
    "Film",
    "Can't Come Closer",
    "1903",
    "Box 3"
  ]

  def sort_test_data_sorted_by(page_class)
    page_object = page_class.new
    [
      with_value_from(DATA_THAT_ALWAYS_SORTS_LAST, DATA_THAT_ALWAYS_SORTS_FIRST, page_object.primary_sort_column),
      DATA_THAT_ALWAYS_SORTS_MIDDLE,
      with_value_from(DATA_THAT_ALWAYS_SORTS_FIRST, DATA_THAT_ALWAYS_SORTS_LAST, page_object.primary_sort_column),
    ]
  end

  def with_value_from(theme, variation, index)
    theme.dup.tap { |data| data[index] = variation[index] }
  end

end
