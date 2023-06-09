class Api::GraphqlController < Api::ApiController
  include ActionController::Cookies
  require 'jwt'
  before_action :set_paper_trail_whodunnit, :set_current_user

  def execute
    variables = ensure_hash(params[:variables])
    query = params[:query]
    operation_name = params[:operationName]
    context = {
      # Query context goes here, for example:
      current_user: @current_user,
    }
    result = ContentManagementSchema.execute(query, variables: variables, context: context, operation_name: operation_name)
    render json: result
  rescue => e
    raise e 
    p e
    # handle_error_in_development e
  end

  private

  # overide the one in the api controller to format errors to graphql spec
  def require_token
    if !request.headers['apiToken']
      return render json: {errors: [{message: "Auth token missing", locations: [], extensions: {code: "AUTHENTICATION_ERROR"}}]}
    end
    begin
      decoded_token = JWT.decode request.headers['apiToken'], Rails.application.credentials.secret_key_base, true, {algorithm: 'HS512'}
      @current_user = User.find(decoded_token[0]["user_id"])
    rescue => exception
      return render json: {errors: [{message: "Token verification error", locations: [], extensions: {code: "AUTHENTICATION_ERROR"}}]}
    end
  end

  # Handle form data, JSON body, or a blank value
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

  def handle_error_in_development(e)
    logger.error e.message
    logger.error e.backtrace.join("\n")

    render json: { error: { message: e.message, backtrace: e.backtrace }, data: {} }, status: 500
  end

  def set_current_user
    current_user
  end
end
