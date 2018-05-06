# frozen_string_literal: true

module GraphQL
  module Tracing
    class NewRelicTracing < PlatformTracing
      self.platform_keys = {
        "lex" => "GraphQL/lex",
        "parse" => "GraphQL/parse",
        "validate" => "GraphQL/validate",
        "analyze_query" => "GraphQL/analyze",
        "analyze_multiplex" => "GraphQL/analyze",
        "execute_multiplex" => "GraphQL/execute",
        "execute_query" => "GraphQL/execute",
        "execute_query_lazy" => "GraphQL/execute",
      }

      def platform_trace(platform_key, key, data)
        begin
          if key == 'execute_query'
            operation_type = data[:context].query.selected_operation.operation_type
            operation_name = data[:context].query.selected_operation.selections.first.name
            NewRelic::Agent.set_transaction_name("GraphQL/#{operation_type}.#{operation_name}")
          else
            operation_type = "UnknownType"
            operation_name = "UnknownName"
            puts "================================================="
            puts "KEY: #{key}"
            puts "MULTIPLEX: #{data.key?(:multiplex)}"
            puts "OPERATION TYPE: #{operation_type}"
            puts "OPERATION NAME: #{operation_name}"
            puts "================================================="
            NewRelic::Agent.set_transaction_name("GraphQL/#{operation_type}.#{operation_name}")
          end
          
        rescue
          puts "Issue with GraphQL Instrumentation"
        end
        NewRelic::Agent::MethodTracerHelpers.trace_execution_scoped(platform_key) do
          yield
        end
      end

      def platform_field_key(type, field)
        "GraphQL/#{type.name}/#{field.name}"
      end
    end
  end
end