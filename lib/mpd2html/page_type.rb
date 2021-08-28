module MPD2HTML
  class PageType
    attr_reader :primary_sort_attribute, :primary_sort_column, :basename

    def initialize(primary_sort_attribute, primary_sort_column, basename)
      @primary_sort_attribute = primary_sort_attribute
      @primary_sort_column = primary_sort_column
      @basename = basename
    end

    TITLE = PageType.new :title, 1, 'johnson-collection'
    COMPOSERS = PageType.new :composers, 2, 'johnson-collection-by-composer'
    ALL = [TITLE, COMPOSERS]

  end
end
