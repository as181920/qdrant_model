module QdrantModel
  class PointPage < ApiClient
    include ActiveModel::API
    include ActiveModel::Validations
    include Enumerable

    attr_accessor :page, :per, :points, :next_page_offset

    delegate :empty?, :each, :[], to: :points

    def next_page?
      next_page_offset.present? && (points.size == per)
    end

    def next_page
      page.next if next_page?
    end
  end
end
