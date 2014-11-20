require 'spec_helper'
require 'roqua/support/stats'

describe 'Error reporting' do
  let(:backend) { double("StatsBackend") }
  let(:stats)   { Roqua::Support::Stats.new(backend) }

  before do
    Roqua.appname = 'appname'
  end

  describe 'tracking a value' do
    it 'reports to backend' do
      expect(backend).to receive(:submit).with('appname.data_export.duration', 2.3)
      stats.submit('data_export.duration', 2.3)
    end
  end
end
