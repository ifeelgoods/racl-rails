require "racl-rails/version"

module Racl
  module Rails
    def self.included(base)
      base.send(:before_filter, :do_racl)
    end

    def initialize
      super
    end

    def do_racl
      begin
        racl = self.class.class_variable_get(:@@RACL_CONFIG)
      rescue NameError => e
        return
      end
      
      if racl.nil?
        return
      end

      acl = Racl::Acl.new
      resource = Racl::Resource::Generic.new(params[:controller])
      acl.add_resource(resource)
      
      racl[:roles].each { |role_name, acl_fields|
        role = Racl::Role::Generic.new(role_name)
        if !acl_fields[:inherits].nil?
          acl.add_role(role, acl_fields[:inherits])
        else
          acl.add_role(role)
        end

        if !acl_fields[:privileges].nil?
          acl_fields[:privileges].each { |privilege, assertions|
            privilege = privilege

            if !assertions.nil?
              if assertions.is_a? Hash
                assertion.each { |assertion|
                  acl.allow(role, resource, privilege, assertion)
                }
              else
                acl.allow(role, resource, privilege, assertions)
              end
            else
              acl.allow(role, resource, privilege)
            end
          }
        end
      }

      role = current_account.nil? ? 'guest' : (current_account.admin? ? 'admin' : 'user')
      if acl.is_allowed?(role, resource, params[:action].to_sym)
        return
      else
        @result[:status] = 942
        @result[:error_message] = "You do not have access."
        render_result(status: 403)
      end
    end
  end
end

if defined? ActionController::Base
  ActionController::Base.class_eval do
    include Racl::Rails
  end
end
