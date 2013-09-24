require 'simple_acl/acl'

module SimpleAcl
  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods
    # privileges :
    # a symbol is the method allowed
    # a hash {:symbol => privileges } is the block to call to get the simple_acl
    # if a role is not define, no privileges will be given to him

    def acl
      @acl ||= Acl.new
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
      acl.configuration.add_role(role, privileges)
    end

    def acl_to_json
      acl.configuration.acl_privileges.to_json
    end
  end

  def acl_values=(values)
    Thread.current['acl_values'] = values
  end

  def acl_values
    Thread.current['acl_values']
  end

  def acl_current_role=(current_role)
    Thread.current['acl_current_role'] = current_role
  end

  def acl_current_role
    Thread.current['acl_current_role']
  end

  def do_acl
    return Acl.unauthorized unless self.class.acl

    self.class.acl.check_acl(acl_current_role, params[:action], acl_values)

  end
end