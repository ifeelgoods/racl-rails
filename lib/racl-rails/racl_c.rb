class Racl_c

  attr_reader :current_account, :params

  def do_racl(current_account, params)
    @current_account = current_account
    @params = params

    if @acl_privileges.nil?
      return self.class.return_unauthorized
    end

    if current_account.nil?
      return self.class.return_unauthorized
    end

    # convenient way should be configured in the application
    role = current_account.guest? ? :guest : (current_account.admin? ? :admin : :user)

    role_privileges = @acl_privileges[role.to_sym]

    if role_privileges.nil?
      return self.class.return_unauthorized
    end

    action = params[:action]

    assertion = role_privileges[action.to_sym]

    check_assertion(assertion)

  end


  def check_assertion(assertion)
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
      return check_assertion(assertion_result)
    end

    return self.class.return_unauthorized
  end

  def self.return_unauthorized
    raise ExceptionUnauthorized
  end

  def self.return_authorized
    return
  end

   ### CONFIGURATION ###

  def role_acl(role, privileges)
    privileges = complete_inherit(privileges) if privileges[:inherit]
    check_set_up(role => privileges)

    @acl_privileges ||= {}
    @acl_privileges[role] ||= {}

    # rules priority: allow > inherit

    # allow, with the merge this way we keep previous rules
    @acl_privileges[role] = privileges[:privileges] if privileges[:privileges]

    # add inherits, with the merge this way we keep previous rules
    @acl_privileges[role] = privileges[:inherit].merge(@acl_privileges[role]) if privileges[:inherit]

    # do a deep freeze one day
  end

  def complete_inherit(privileges)
    if privileges[:inherit]
      raise 'Unauthoriwed inherit class type (only Symbol is allowed)' if privileges[:inherit].class != Symbol
      raise 'Inherit specified is not defined previously' unless @acl_privileges[privileges[:inherit]]
      privileges[:inherit] = @acl_privileges[privileges[:inherit]]
    end
    privileges
  end

  # check of the set up
  # generic method to check a hash of configuration {:roles {privileges}}, with privileges {:action => assertion}
  def check_set_up(privileges)
    authorized_privileges = [Hash]
    authorized_roles = [:admin, :user, :guest]
    authorized_config = [:privileges, :inherit]

    privileges.keys.each do |role|
      raise "Unauthorized role #{role}" unless authorized_roles.include?(role)
      privileges[role].each do |config,value|
        raise "Unauthorized privilege #{config}" unless authorized_config.include?(config)
      end

      authorized_config.each do |key_config|
        if privileges[role][key_config]
          raise "Unauthorized privilege #{privileges[role][key_config]}" unless authorized_privileges.include?(privileges[role][key_config].class)
          if privileges[role][key_config].class == Hash
          #  raise "One privilege per Hash" unless privileges[role][key_config].count == 1
            privileges[role][key_config].each do |key,value|
              check_set_up_assertion(value)
            end
          else
            check_set_up_assertion(privileges[role][key_config])
          end

        end
      end
    end
  end

  def check_set_up_assertion(assertion)
    authorized_assertion = [TrueClass, FalseClass, Proc]
    raise "Unauthorized assertion #{assertion.class}" unless authorized_assertion.include?(assertion.class)
  end

  # documentation

  def acl_to_json
    @acl_privileges.to_json
  end
end