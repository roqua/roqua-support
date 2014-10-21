# Roqua::Support

This gem contains all sorts of support utilities and helper methods that are
useful to have in RoQua's applications, but have nothing to with the domain.

## Usage

### Logging

```ruby
class Example
  include Roqua::Logging

  def methodname
    # This writes a single line to the event log with
    # the given event name and parameters as key=value format.
    eventlog.info 'example.eventname', optional: 'extra parameters'
  end

  def another
    # This automatically emits two lines, one for when the
    # block begins, one for when the block ends. ':started',
    # ':finished', ':failed' are appended to the event name
    # given, and the duration of the block is logged with
    # the :finished log line.
    eventlog.lifecycle 'example.lifecycle', optional: 'params' do
      sleep 5
    end
  end

  def third
    # This example is the same as the `another` example.
    sleep 5
  end
  log :third, 'example.lifecycle', optional: 'params'
end
```

### Rails logger

You can also add an additional request logger by adding this to `config/initializers/request_logger.rb`:

```ruby
require 'roqua/support/request_logger'
Roqua::Support::RequestLogger.attach_to :action_controller
```

### Responders

#### option 1

Create responder including the required responder modules and use it in a controller.

```ruby
class ApiResponder < ActionController::Responder
  include Roqua::Responders::ApiErrorsResponder
  include Roqua::Responders::ActiveInteractionAwareResponder
end
```

```
class ApiAreaController < ApplicationController
  self.responder = ApiResponder
  ...
```

#### option 2

Use gem 'responders'

And add required responder modules in a controller.

```
class ApiAreaController < ApplicationController
  responders :flash, Roqua::Responders::ApiErrorsResponder, Roqua::Responders::ActiveInteractionAwareResponder
  ...
```


Create

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
