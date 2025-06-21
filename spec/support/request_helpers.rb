# RSpec configuration and helper methods

RSpec.configure do |config|
  # Custom matcher for checking response content without controller testing
  config.include Module.new {
    def have_successful_response
      have_http_status(:success)
    end

    def have_redirect_response
      have_http_status(:redirect)
    end

    def have_unprocessable_entity_response
      have_http_status(:unprocessable_entity)
    end
  }
end

# Custom matcher for query counting (simplified version)
RSpec::Matchers.define :exceed_query_limit do |expected|
  match do |actual|
    query_count = 0
    subscriber = ActiveSupport::Notifications.subscribe('sql.active_record') do |*args|
      query_count += 1
    end

    actual.call
    ActiveSupport::Notifications.unsubscribe(subscriber)

    query_count <= expected
  end

  failure_message do |actual|
    "expected the block to not exceed #{expected} queries"
  end
end
