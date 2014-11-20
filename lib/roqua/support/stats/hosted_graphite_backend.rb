require 'hosted_graphite'

module Roqua
  module Support
    class Stats
      class HostedGraphiteBackend
        def submit(key, value)
          HostedGraphite.send_metric(key, value)
        end
      end
    end
  end
end
