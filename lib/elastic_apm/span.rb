# frozen_string_literal: true

require 'securerandom'

require 'elastic_apm/span/context'

module ElasticAPM
  # @api private
  class Span
    DEFAULT_TYPE = 'custom'

    # rubocop:disable Metrics/ParameterLists
    def initialize(
      name,
      type = nil,
      transaction: nil,
      parent: nil,
      context: nil,
      stacktrace_builder: nil
    )
      @name = name
      @type = type || DEFAULT_TYPE

      @id = SecureRandom.hex(8)

      self.transaction = transaction
      self.parent = parent

      @context = context
      @stacktrace_builder = stacktrace_builder
    end
    # rubocop:enable Metrics/ParameterLists

    attr_accessor :name, :type, :original_backtrace, :parent
    attr_reader :id, :context, :stacktrace, :duration,
      :timestamp, :transaction_id, :trace_id

    def transaction=(transaction)
      @transaction_id = transaction&.id
      @trace_id = transaction&.trace_id
    end

    def parent_id
      @parent&.id || transaction_id
    end

    # life cycle

    def start
      @timestamp = Util.micros

      self
    end

    def stop
      @duration = Util.micros - timestamp
    end

    def done
      stop

      if should_build_stacktrace?
        build_stacktrace
      end

      self
    end

    def stopped?
      !!duration
    end

    def started?
      !!timestamp
    end

    def running?
      started? && !stopped?
    end

    # relations

    def inspect
      "<ElasticAPM::Span id:#{id}" \
        " name:#{name.inspect}" \
        " type:#{type.inspect}" \
        '>'
    end

    private

    def should_build_stacktrace?
      @stacktrace_builder && original_backtrace && long_enough_for_stacktrace?
    end

    def build_stacktrace
      @stacktrace = @stacktrace_builder.build(original_backtrace, type: :span)
      self.original_backtrace = nil # release it
    end

    def long_enough_for_stacktrace?
      min_duration =
        @stacktrace_builder.config.span_frames_min_duration_us

      return true if min_duration < 0
      return false if min_duration == 0

      duration >= min_duration
    end
  end
end
