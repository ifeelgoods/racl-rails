module Racl
  module Rails
    class Racl

      attr_reader :current_account, :params, :configuration

      def initialize
        @configuration = Configuration.new
      end

      def do_racl(current_account, params)
        @current_account = current_account
        @params = params

        if configuration.nil?
          return self.class.return_unauthorized
        end

        if current_account.nil?
          return self.class.return_unauthorized
        end

        # convenient way should be configured in the application
        role = current_account.guest? ? :guest : (current_account.admin? ? :admin : :user)

        role_privileges = configuration.acl_privileges[role.to_sym]

        if role_privileges.nil?
          return self.class.return_unauthorized
        end

        action = params[:action]

        assertion = role_privileges[action.to_sym]

        do_assertion(assertion)

      end


      def do_assertion(assertion)
        if assertion.nil?
          return self.class.return_unauthorized
        end

        if assertion.class == TrueClass
          return self.class.return_authorized
        end

        if assertion.class == FalseClass
          return self.class.return_unauthorized
        end

        if (assertion.class == Proc) && assertion.lambda?
          assertion_result = assertion.call(current_account, params)
          return do_assertion(assertion_result)
        end

        self.class.return_unauthorized
      end

      def self.return_unauthorized
        raise ExceptionUnauthorized
      end

      def self.return_authorized
        return
      end

    end
  end

end
