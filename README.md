# RACL-Rails

This gem eases the integration of RACL with Rails.

## Installation

Add this line to your application's Gemfile:

    gem 'racl-rails'

And then execute:

    $ bundle

## Usage

you need to include the module with:

`include Racl::Rails`

Add the following before_filter to check ACL before the code in the
action of the controller is executed.

```ruby
  before_filter :do_racl
```

To configure a role you can use:

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


No rules defined for an action => no access allowed.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
