require 'spec_helper'
require 'roqua/support/stats'

describe 'Error reporting' do
  let(:backend) { double("StatsBackend") }
  let(:stats)   { Roqua::Support::Stats.new(backend) }

  before do
    Roqua.appname = 'appname'
  end

  describe 'tracking timing' do
    it 'reports to backend' do
      expect(backend).to receive(:measure).with('appname.data_export.duration', 2.3)
      stats.measure('data_export.duration', 2.3)
    end
  end

  describe 'tracking counters' do
    it 'reports to backend' do
      expect(backend).to receive(:increment).with('appname.notifications.hoe_gek_is_nl.finished', 1)
      stats.increment('notifications.hoe_gek_is_nl.finished', 1)
    end
  end

  describe 'tracking observed values' do
    it 'reports to backend' do
      expect(backend).to receive(:gauge).with('appname.protocol_subscriptions.active', 20123)
      stats.gauge('protocol_subscriptions.active', 20123)
    end
  end

  describe 'tracking number of unique things per time window' do
    it 'reports to backend' do
      expect(backend).to receive(:set).with('appname.active_epd_logins', 'b_handelaar')
      stats.set('active_epd_logins', 'b_handelaar')
    end
  end
end
