class ContentManagementSchema < GraphQL::Schema
  require 'errors'
  
  use GraphQL::Subscriptions::ActionCableSubscriptions
  mutation(Types::MutationType)
  query(Types::QueryType)
  # loads in the subscription type and all its references
  subscription(Types::SubscriptionType)

  rescue_from Errors::SalesforceBadResponse do |exception|
    # in this case exection should be http response
    exception_with_response_message = Exception.new(JSON.parse(exception.response.body)['fault']['message'])
    GraphQL::ExecutionError.new(exception_with_response_message, extensions: { code: 'INTERNAL_SERVER_ERROR' })
  end

  # For batch-loading (see https://graphql-ruby.org/dataloader/overview.html)
  use GraphQL::Dataloader

  # catch rails errors and return an errrs array acording to the graphql spec
  rescue_from StandardError do |message|
    puts "GraphQL error: #{message}"
    GraphQL::ExecutionError.new(message, extensions: { code: 'INTERNAL_SERVER_ERROR' })
  end

  
  # GraphQL-Ruby calls this when something goes wrong while running a query:
  def self.type_error(err, context)
    # if err.is_a?(GraphQL::InvalidNullError)
    #   # report to your bug tracker here
    #   return nil
    # end
    super
  end

  # Union and Interface Resolution
  def self.resolve_type(abstract_type, obj, ctx)
    # TODO: Implement this method
    # to return the correct GraphQL object type for `obj`
    raise(GraphQL::RequiredImplementationMissingError)
  end

  # Stop validating when it encounters this many errors:
  validate_max_errors(100)

  # Relay-style Object Identification:

  # Return a string UUID for `object`
  def self.id_from_object(object, type_definition, query_ctx)
    # For example, use Rails' GlobalID library (https://github.com/rails/globalid):
    object.to_gid_param
  end

  # Given a string UUID, find the object
  def self.object_from_id(global_id, query_ctx)
    # For example, use Rails' GlobalID library (https://github.com/rails/globalid):
    GlobalID.find(global_id)
  end
end
