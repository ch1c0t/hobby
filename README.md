# Hobby

A professional way to create [Rack](http://rack.github.io/)-based applications.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'hobby'
# or this if you want to use hobby master
# gem 'hobby', github: 'ch1c0t/hobby'
```

And then execute:

```bash
$ bundle
```

Or install it yourself as:

```bash
$ gem install hobby
```

## Features

* DSL inspired by [Sinatra](http://www.sinatrarb.com/).
* [Speed](https://github.com/luislavena/bench-micro).
* Extensible with standard ruby classes and modules, with no extra logic. See
[hobby-auth](https://github.com/ch1c0t/hobby-auth) and [hobby-json](https://github.com/ch1c0t/hobby-json).
* Zero configuration.

## Philosophy

* [Don't repeat yourself](http://en.wikipedia.org/wiki/Don't_repeat_yourself)
* Encourages the understanding and use of [Rack](http://rack.github.io/) and
its extensions instead of providing such functionality.

## Usage

Hobbit applications are just instances of classes that inherits from
`Hobbit::Base`, which complies the
[Rack SPEC](http://rubydoc.info/github/rack/rack/master/file/SPEC).

### Hello World example

Create a file called `app.rb`:

```ruby
require 'hobby'

class App
  include Hobby
  get '/' do
    'Hello World!'
  end
end
```

Create a `config.ru` file:

```ruby
require './app'

run App.new # or just `run App`
```

Run it with `rackup`:

```bash
$ rackup
```

View your app at [http://localhost:9292](http://localhost:9292).

### Routes

Every route is composed of a verb, a path (optional) and an action(passed as a block).
When an incoming request matches a route, the action is executed and a response is sent
back to the client. The return value of the action will be the `body` of the
response. 

See an example:

```ruby
class App < Hobbit::Base
  get '/' do
    # ...
  end

  post '/' do
    # ...
  end

  put '/' do
    # ...
  end

  patch '/' do
    # ...
  end

  delete '/' do
    # ...
  end

  options '/' do
    # ...
  end
end
```

When a route gets called you have this methods available:

* `env`: The Rack environment.
* `request`: a `Rack::Request` instance.
* `response`: a `Rack::Response` instance.

And any other method defined in your application.

#### Available methods

* `delete`
* `get`
* `head`
* `options`
* `patch`
* `post`
* `put`

**Note**: Since most browsers don't support methods other than **GET** and
**POST** you must use the `Rack::MethodOverride` middleware. (See
[Rack::MethodOverride](https://github.com/rack/rack/blob/master/lib/rack/methodoverride.rb)).

#### Routes with variables

```ruby
require 'hobby'

class App
  include Hobby
  # matches both /hi/hobbit and /hi/patricio
  get '/hi/:name' do
    "Hello #{my[:name]}"
  end
end
```

#### Redirecting

If you look at Hobby implementation, you may notice that there is no
`redirect` method (or similar). This is because such functionality is provided
by [Rack::Response](https://github.com/rack/rack/blob/master/lib/rack/response.rb)
and for now we [don't wan't to repeat ourselves](http://en.wikipedia.org/wiki/Don't_repeat_yourself)
(obviously you can create an extension!). So, if you want to redirect to
another route, do it like this:

```ruby
require 'hobby'

class App
  include Hobby

  get '/' do
    response.redirect '/hi'
  end

  get '/hi' do
    'Hello World!'
  end
end
```

#### Halting

To immediately stop a request within route you can use `throw :halt`. 

```ruby
require 'hobby'

class App < Hobbit::Base
  use Rack::Session::Cookie, secret: SecureRandom.hex(64)

  def session
    env['rack.session']
  end

  get '/' do
    response.status = 401
    throw :halt, response.finish
  end
end
```

### Built on top of rack

Each Hobby application is a Rack stack (See this
[blog post](http://m.onkey.org/ruby-on-rack-2-the-builder) for more
information).

#### Mapping applications

You can mount any Rack application to the stack by using the `map` class
method:

```ruby
require 'hobby'

class InnerApp
  include Hobby

  # gets called when path_info = '/inner'
  get do
    'Hello InnerApp!'
  end
end

class App
  include Hobby

  map('/inner') { run InnerApp.new }

  get '/' do
    'Hello App!'
  end
end
```

#### Using middleware

You can add any Rack middleware to the stack by using the `use` class method:

```ruby
require 'hobby'

class App
  include Hobby

  use Rack::Session::Cookie, secret: SecureRandom.hex(64)
  use Rack::ShowExceptions

  def session
    env['rack.session']
  end

  get '/' do
    session[:name] = 'hobbit'
  end

  # more routes...
end

run App.new
```

### Security

By default, Hobbit (nor Rack) comes without any protection against web
attacks. The use of [rack-protection](https://github.com/rkh/rack-protection)
is highly recommended:

```ruby
require 'hobby'
require 'rack/protection'
require 'securerandom'

class App
  include Hobby

  use Rack::Session::Cookie, secret: SecureRandom.hex(64)
  use Rack::Protection

  get '/' do
    'Hello World!'
  end
end
```

See the [rack-protection](https://github.com/rkh/rack-protection)
documentation for futher information.

### Testing

[rack-test](https://github.com/brynary/rack-test) is highly recommended. See
an example:

In `app.rb`:

```ruby
require 'hobbit'

class App
  include Hobby

  get '/' do
    'Hello World!'
  end
end
```

In `app_spec.rb`:

```ruby
require 'minitest/autorun'
# imagine that app.rb and app_spec.rb are stored in the same directory
require 'app'

describe App do
  include Rack::Test::Methods

  def app
    App.new
  end

  describe 'GET /' do
    it 'must be ok' do
      get '/'
      last_response.must_be :ok?
      last_response.body.must_match /Hello World!/
    end
  end
end
```

See the [rack-test](https://github.com/brynary/rack-test) documentation
for futher information.

### Extensions

You can extend Hobbit by creating standard ruby modules. See an example:

```ruby
module MyExtension
  def do_something
    # do something
  end
end

class App
  include Hobby
  include MyExtension

  get '/' do
    do_something
    'Hello World!'
  end
end
```

#### Available extensions

* [hobby-auth](https://github.com/ch1c0t/hobby-auth): User authorization.
* [hobby-json](https://github.com/ch1c0t/hobby-json): JSON requests and responses.

## Community

* [Wiki](https://github.com/patriciomacadden/hobbit/wiki): Guides, how-tos and recipes
* IRC: [#hobbitrb](irc://chat.freenode.net/#hobbitrb) on [http://freenode.net](http://freenode.net)

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## License

See the [LICENSE](https://github.com/ch1c0t/hobby/blob/master/LICENSE).
