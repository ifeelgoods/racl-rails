require 'simple_racl/configuration'
require 'simple_racl/exception_unauthorized'

module SimpleRacl
  class Racl

    attr_reader :configuration

    def initialize
      @configuration = Configuration.new
    end

    def do_racl(current_role, action, values)

      return self.class.unauthorized unless configuration && current_role

      role_privileges = configuration.acl_privileges[current_role.to_sym]

      return self.class.unauthorized unless role_privileges

      assertion = role_privileges[action.to_sym]

      self.class.do_assertion(assertion, current_role, values)
    end

    def self.do_assertion(assertion, current_role, values)

      # not FalseClass or nil
      return unauthorized unless assertion

      return authorized if assertion.class == TrueClass

      if assertion.class == Proc && assertion.lambda?
        assertion_result = assertion.call(current_role, values)
        return do_assertion(assertion_result, current_role, values)
      end

      unauthorized
    end

    def self.unauthorized
      raise ExceptionUnauthorized
    end

    def self.authorized
      true
    end

  end
end
