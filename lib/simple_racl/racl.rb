require 'simple_racl/configuration'
require 'simple_racl/exception_unauthorized'

module SimpleRacl
  class Racl

    attr_reader :configuration

    def initialize
      @configuration = Configuration.new
    end

    def do_racl(current_role, action, values)

      return self.class.return_unauthorized if configuration.nil? || current_role.nil?

      role_privileges = configuration.acl_privileges[current_role.to_sym]

      return self.class.return_unauthorized if role_privileges.nil?

      assertion = role_privileges[action.to_sym]

      self.class.do_assertion(assertion, current_role, values)
    end

    def self.do_assertion(assertion, current_role, values)

      return return_unauthorized if assertion.nil? || assertion.class == FalseClass

      return return_authorized if assertion.class == TrueClass

      if (assertion.class == Proc) && assertion.lambda?
        assertion_result = assertion.call(current_role, values)
        return do_assertion(assertion_result, current_role, values)
      end

      return_unauthorized
    end

    def self.return_unauthorized
      raise ExceptionUnauthorized
    end

    def self.return_authorized
      return
    end

  end
end
