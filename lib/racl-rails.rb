require "racl-rails/version"
require 'racl-rails/racl_c'
require 'racl-rails/exception_unauthorized'


module Racl
  module Rails

    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      # privileges :
      # a symbol is the method allowed
      # a hash {:symbol => privileges } is the block to call to get the racl
      # if a role is not define, no privileges will be given to him

      def racl
        @racl
      end

      def acl_user(privileges)
        @racl ||= Racl_c.new
        @racl.role_acl(:user, privileges)
      end

      def acl_admin(privileges)
        @racl ||= Racl_c.new
        @racl.role_acl(:admin, privileges)
      end

      def acl_guest(privileges)
        @racl ||= Racl_c.new
        @racl.role_acl(:guest, privileges)
      end

      def acl_to_json
        @racl.acl_to_json
      end

    end

    def do_racl
      return Racl_c.return_unauthorized unless self.class.racl

      self.class.racl.do_racl(current_account, params)

    end


  end
end