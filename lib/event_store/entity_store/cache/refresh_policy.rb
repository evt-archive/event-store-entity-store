module EventStore
  module EntityStore
    class Cache
      module RefreshPolicy
        class Error < StandardError; end

        def self.!(*)
          raise Virtual::PureMethodError, '"!"'
        end

        def self.configure(receiver, policy_name)
          policy_class = policy_class(policy_name)
          receiver.refresh = policy_class
          policy_class
        end

        def self.policy_class(policy_name=nil)
          policy_name ||= Defaults::Name.get

          policy_class = policies[policy_name]

          unless policy_class
            error_msg = "Refresh policy \"#{policy_name}\" is unknown. It must be one of: immediate, none, or age."
            logger.error error_msg
            raise Error, error_msg
          end

          policy_class
        end

        def self.policies
          @policies ||= {
            immediate: Immediate,
            none: None,
            age: Age
          }
        end

        def self.logger
          @logger ||= Telemetry::Logger.build self
        end

        module Defaults
          module Name
            def self.env_var_name
              'ENTITY_CACHE_REFRESH'
            end

            def self.env_var_value
              ENV[env_var_name]
            end

            def self.name
              'immediate'
            end

            def self.get
              name = env_var_value
              name ||= self.name
              name = name.to_sym

              name
            end
          end
        end
      end
    end
  end
end