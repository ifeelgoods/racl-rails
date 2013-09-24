# SimpleRacl

This gem eases the integration of RACL with Rails.

No acl defined for an action => no access allowed.

## Installation

Add this line to your application's Gemfile:

    gem 'simple_racl'

And then execute:

    $ bundle install

## Usage

You need to include the module with:

`include SimpleRacl`

You need to define the current_role with a before filter.
And you have the possibility to define values which will be passed
into your custom validations.

```ruby
  def setup_racl
    self.racl_current_role = current_user? :user : :guest
    self.racl_values = {:current_user => current_user, :id => params['id]}
  end
```

After this configuration, add the following before_filter to check ACL
before the execution of the code in the action.

```ruby
  before_filter :do_racl
```

To configure the ability of a role you can use:

`acl_user, acl_admin, acl_guest`

or the basic method `acl_role` with which you need to specify the role.

The key `privileges` must be a hash of assertions.
The key `inherit` must be the symbol of previous defined role.

Example:

```ruby
  acl_user privileges: {
      index: true,
      show: true,
      show_from_adserver_affiliate_id: true
  }

  acl_admin inherit: :user
```

```ruby
    acl_role(:guest, show: true)
```

If the role trying to access to the resource is not allowed a ExceptionUnauthorized
exception will be raised.
Catch it to render whatever you want in this case:

```ruby
rescue_from ExceptionUnauthorized do
  # render 403
end
```

In an initializers, you can specify the role you want to use.
(defaults are :admin, :user, :guest)

```ruby
Racl::Rails::Configuration.authorized_roles = [:admin, :user]

```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
