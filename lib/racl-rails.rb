require "racl-rails/version"

module Racl
  module Rails
    def self.include(base)
      base.send(:before_filter, :do_racl)
    end

    def initialize
      super
    end

    def do_racl
      if defined? @@RACL_CONFIG
        racl = @@RACL_CONFIG
      else
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
      }

      if !acl_fields[:acl].nil?
        privileges = acl_fields[:acl]
        privileges.each { |arr|
          privilege = arr[:privilege]

          if arr[:assertion]
            assert_obj = arr[:assertion]
            assertion = assert_obj.new(params)
            acl.allow(role, resource, privilege, assertion)
          else
            acl.allow(role, resource, privilege)
          end
        }
      end

      role = current_user.nil? ? 'guest' : (current_user.is_admin? ? 'admin' : 'user')
      if acl.is_allowed?(role, resource, params[:action])
        return
      else
        redirect_to # Something here
      end
    end
  end
end

if defined? ActionController::Base
  ActionController::Base.class_eval do
    include Racl::Rails
  end
end
