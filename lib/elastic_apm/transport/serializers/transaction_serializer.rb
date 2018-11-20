# frozen_string_literal: true

module ElasticAPM
  module Transport
    module Serializers
      # @api private
      class TransactionSerializer < Serializer
        def initialize(config)
          super

          @context_serializer = ContextSerializer.new(config)
        end

        attr_reader :context_serializer

        # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
        def build(transaction)
          {
            transaction: {
              id: transaction.id,
              trace_id: transaction.trace_id,
              parent_id: transaction.parent_id,
              name: keyword_field(transaction.name),
              type: keyword_field(transaction.type),
              result: keyword_field(transaction.result.to_s),
              duration: ms(transaction.duration),
              timestamp: transaction.timestamp,
              sampled: transaction.sampled?,
              context: context_serializer.build(transaction.context),
              span_count: {
                started: transaction.started_spans,
                dropped: transaction.dropped_spans
              }
            }
          }
        end
        # rubocop:enable Metrics/MethodLength, Metrics/AbcSize

        # @api private
        class ContextSerializer < Serializer
          def build(context)
            {
              custom: context.custom,
              tags: keyword_object(context.tags),
              request: build_request(context.request),
              response: build_response(context.response),
              user: build_user(context.user)
            }
          end

          private

          # rubocop:disable Metrics/MethodLength
          def build_request(request)
            return unless request

            {
              body: request.body,
              cookies: request.cookies,
              env: request.env,
              headers: request.headers,
              http_version: keyword_field(request.http_version),
              method: keyword_field(request.method),
              socket: request.socket,
              url: request.url
            }
          end
          # rubocop:enable Metrics/MethodLength

          def build_response(response)
            return unless response

            {
              status_code: response.status_code,
              headers: response.headers,
              headers_sent: response.headers_sent,
              finished: response.finished
            }
          end

          def build_user(user)
            return unless user

            {
              id: keyword_field(user.id),
              email: keyword_field(user.email),
              username: keyword_field(user.username)
            }
          end
        end
      end
    end
  end
end
