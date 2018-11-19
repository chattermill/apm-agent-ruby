# frozen_string_literal: true

module ElasticAPM
  module Transport
    module Serializers
      # @api private
      class SpanSerializer < Serializer
        # rubocop:disable Metrics/MethodLength
        def build(span)
          {
            span: {
              id: span.id,
              transaction_id: span.transaction_id,
              parent_id: span.parent_id,
              name: keyword_field(span.name),
              type: keyword_field(span.type),
              duration: ms(span.duration),
              context: build_context(span.context),
              stacktrace: span.stacktrace.to_a,
              timestamp: span.timestamp,
              trace_id: span.trace_id
            }
          }
        end
        # rubocop:enable Metrics/MethodLength

        private

        def build_context(context)
          return unless context

          context.to_h
        end
      end
    end
  end
end
