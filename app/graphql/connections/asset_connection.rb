module Connections

  class AssetEdgeType < GraphQL::Types::Relay::BaseEdge
    node_type(Types::AssetType)
  end
  
  class Connections::AssetConnection < GraphQL::Types::Relay::BaseConnection
    # GraphQL::Relay::ConnectionType.bidirectional_pagination = true

    field :total_count, Integer, 'Total # of objects returned from this Plural Query', null: false
    def total_count
      object.nodes&.count
    end

    field :total_page_count, Integer, 'Total # of pages, based on total count and pagesize', null: false
    def total_page_count
      return 1 unless object.nodes&.count&.positive?
      # get total count and create array with total count as first item
      my_total_count = object.nodes&.count
      possible_page_sizes = [my_total_count]

      # add first and last argument counts to the array if they exist
      possible_page_sizes.push(50)
      # possible_page_sizes.push(object.arguments[:last]) if object.arguments[:last]

      # get the smallest of the array items
      actual_page_size = possible_page_sizes.min

      # return the total_count divided by the page size, rounded up
      (my_total_count / actual_page_size.to_f).ceil
    end

    edge_type(AssetEdgeType)
  end
end