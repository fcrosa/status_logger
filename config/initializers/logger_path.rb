if defined?(ActiveSupport::LoggerThreadSafeLevel)
  module ActiveSupport::LoggerThreadSafeLevel
    Logger ||= ::Logger
  end
end