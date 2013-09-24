require 'simple_racl/racl'

module SimpleRacl
  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods
    # privileges :
    # a symbol is the method allowed
    # a hash {:symbol => privileges } is the block to call to get the simple_racl
    # if a role is not define, no privileges will be given to him

    def racl
      @racl ||= Racl.new
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
      racl.configuration.add_role(role, privileges)
    end

    def acl_to_json
      racl.configuration.acl_privileges.to_json
    end
  end

  def racl_values=(values)
    Thread.current['racl_values'] = values
  end

  def racl_values
    Thread.current['racl_values']
  end

  def racl_current_role=(current_role)
    Thread.current['racl_current_role'] = current_role
  end

  def racl_current_role
    Thread.current['racl_current_role']
  end

  def do_racl
    return Racl.unauthorized unless self.class.racl

    self.class.racl.do_racl(racl_current_role, params[:action], racl_values)

  end
end