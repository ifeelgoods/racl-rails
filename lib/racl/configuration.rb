module Racl
  module Rails
    class Configuration

      attr_reader :acl_privileges

      def initialize
        @acl_privileges = {}
      end

      def add_role(role, privileges)
        privileges = add_inherit(privileges)
        check_set_up(role => privileges)

        @acl_privileges[role] ||= {}

        # rules priority: allow > inherit

        # add privileges
        @acl_privileges[role] = privileges[:privileges] if privileges[:privileges]

        # add inherits, with the merge this way we keep previous rules
        @acl_privileges[role] = privileges[:inherit].merge(@acl_privileges[role]) if privileges[:inherit]

        # do a deep freeze one day
      end

      private

      # add previous privileges defined into the configuration
      def add_inherit(privileges)
        if privileges[:inherit]
          raise 'Unauthorized inherit class type (only Symbol is allowed)' if privileges[:inherit].class != Symbol
          raise 'Inherit specified is not defined previously' unless @acl_privileges[privileges[:inherit]]
          privileges[:inherit] = @acl_privileges[privileges[:inherit]]
        end
        privileges
      end

      # check of the set up
      def check_set_up(privileges)
        authorized_privileges_config = [Hash]
        authorized_roles = [:admin, :user, :guest]
        authorized_keys_config = [:privileges, :inherit]

        # check role
        privileges.keys.each do |role|
          raise "Unauthorized role #{role}" unless authorized_roles.include?(role)

          # check config keys
          privileges[role].keys.each do |config_key|
            raise "Unauthorized privilege #{config_key}" unless authorized_keys_config.include?(config_key)

            # check if this config is a hash
            raise "Unauthorized privilege #{privileges[role][config_key]}" unless authorized_privileges_config.include?(privileges[role][config_key].class)

            privileges[role][config_key].keys.each do |action|
              action_assertion = privileges[role][config_key][action]
              check_assertion(action_assertion)
            end
          end
        end
      end

      def check_assertion(assertion)
        authorized_assertion = [TrueClass, FalseClass, Proc]
        raise "Unauthorized assertion #{assertion.class}" unless authorized_assertion.include?(assertion.class)
      end
    end
  end
end
