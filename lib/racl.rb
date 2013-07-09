require "racl/version"
require 'racl/racl'
require 'racl/configuration'
require 'racl/exception_unauthorized'


module Racl

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
      role_acl(:user, privileges)
    end

    def acl_admin(privileges)
      role_acl(:admin, privileges)
    end

    def acl_guest(privileges)
      role_acl(:guest, privileges)
    end

    def role_acl(role, privileges)
      @racl ||= Racl.new
      @racl.configuration.add_role(role, privileges)
    end

    def acl_to_json
      @racl.configuration.acl_privileges.to_json
    end


  end

  def do_racl
    return Racl.return_unauthorized unless self.class.racl

    self.class.racl.do_racl(current_account, params)

  end


end