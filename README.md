This program converts reports from the collection management system(s) used by
San Francisco's [Museum of Performance + Design](https://www.mpdsf.org/) to HTML.
At present, it handles reports from the the STAR collection management system.

# Install

- Install the version of ruby given in .ruby-version however you prefer
- `gem install bundler`
- `bundle`

# Use

- Export catalog entries from STAR to MS Word
- Export from MS Word to text
- `bin/mpd2html -o <directory where output should be written> <file> [...]`

`bin/mpd2html -h` to see additional options. 
