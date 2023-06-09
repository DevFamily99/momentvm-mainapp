# This file contains are custom errors for the cms
class Errors
  # When they don't have permission to do something
  class Forbidden < StandardError; end
  # When something they want is not found
  class NotFound < StandardError; end
  # When the input is somehow bad
  class InvalidParameters < StandardError; end
  # A network error i.e. from micro services
  class NetworkError < StandardError; end
  # When the SFCC retuns a non 200 response
  class SalesforceBadResponse < StandardError
    attr_reader :response

    def initialize(response)
      super
      @response = response
    end
  end
end
