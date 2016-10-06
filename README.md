# Roqua::Support

This gem contains all sorts of support utilities and helper methods that are
useful to have in RoQua's applications, but have nothing to with the domain.

## Usage

### Instrumentation

```ruby
class Example
  include Roqua::Support::Instrumentation

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
end
```

### Rails instrumentation for active_interaction operations

```ruby
# Adds the instrumentation around all active_interaction operations:
# ActiveSupport::Notifications.instrument 'operation.active_interaction',
#                                         class_name: self.class.to_s.underscore do
require 'roqua/core_ext/active_interaction/rails_instrumentation'
```

### Rails logger

You can also add an additional request logger by adding this to `config/initializers/request_logger.rb`:

```ruby
require 'roqua/support/request_logger'
Roqua::Support::RequestLogger.attach_to :action_controller
```

### Error reporting

Log and error to Roqua.logger, appsignal and/or airbrake, depending on which is configured.

```ruby
Roqua::Support::Errors.report(exception, extra: 'params')
```

Add extra info to all reports (global setting, put in initializer)

```
Roqua::Support::Errors.extra_parameters = {root_path: Rails.root.to_s}
```

When you want to add more info, but want to catch the error higher up you can call Errors.add_parameters, which will save them on the current exception instance.

```
rescue
  raise Roqua::Support::Errors::add_parameters(more: 'params')
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

### ActiveInteraction extensions

```
require 'roqua/core_ext/active_interaction/filters/date_time_as_unix_extension'
```

Allows a date or date_time attribute to be set by a unix time e.g. 1415608242 or '1415608242'.


```
require 'roqua/core_ext/active_interaction/filters/duration_filter'

class DurationFilterOperation < ActiveInteraction::Base
  duration :duration
  duration :foo, strip: true, default: nil # value is nil if duration is 0.
end

DurationFilterOperation.run(duration: 1.week)
DurationFilterOperation.run(duration: {value: 1, unit: 'weeks'})
```

Allows you to specify an ActiveSupport::Duration attribute.


### Validators

```ruby
require 'roqua/validators/subset_validator'
```

In errors.yml (Optional - Given defaults are available)
```
nl:
  errors:
    messages:
      subset: bevat onbekende keuzes
```



## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
