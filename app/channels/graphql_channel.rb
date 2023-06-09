# Channel used by the graphql schema
class GraphqlChannel < ApplicationCable::Channel
  rescue_from StandardError, with: :report_error
  @op_name
  # To be called when a consumer subscribes to the GraphQL channel (ie when a user first opens the application).
  def subscribed
    # Store all GraphQL subscriptions the consumer is listening for on this channel
    @subscription_ids = []
  end

  # To be called when a subscribed consumer registers for a subscription event on this channel. 
  # This will be called once for every event the frontend wants to be notified about.
  def execute(data)
    query = data['query']
    variables = ensure_hash(data['variables'])
    @op_name = data['operationName']
    operation_name = data['operationName']
    context = {
      # Re-implement whatever context methods you need
      # in this channel or ApplicationCable::Channel
      # current_user: current_user,
      # Make sure the channel is in the context
      channel: self
      # https://medium.com/@jerridan/implementing-graphql-subscriptions-in-rails-and-react-9e05ca8d6b20
      # Note that current_application_context has been added to the context object. 
      # As I mentioned earlier, the Connection instance will be the parent of the GraphqlChannel instance, 
      # so we can get any authorization details that were set in the Connection here.
     # current_application_context: connection.current_application_context
    }
    result = ContentManagementSchema.execute(query, variables: variables, context: context, operation_name: operation_name)
    payload = {
      result: result.to_h,
      more: result.subscription?
    }
    # Track the subscription here so we can remove it
    # on unsubscribe.
    @subscription_ids << result.context[:subscription_id] if result.context[:subscription_id]

    transmit(payload)
  end

  # To be called when a consumer unsubscribes from the GraphQL channel (ie when a user closes the application).
  def unsubscribed
    # Delete all of the consumer's subscriptions from the GraphQL Schema
    @subscription_ids.each do |sid|
      ContentManagementSchema.subscriptions.delete_subscription(sid)
    end
  end

  private

  def report_error(e)
    puts "Error in graphql channel: #{e} - Op: #{@op_name}"
  end

  def ensure_hash(ambiguous_param)
    case ambiguous_param
    when String
      if ambiguous_param.present?
        ensure_hash(JSON.parse(ambiguous_param))
      else
        {}
      end
    when Hash, ActionController::Parameters
      ambiguous_param
    when nil
      {}
    else
      raise ArgumentError, "Unexpected parameter: #{ambiguous_param}"
    end
  end
end
