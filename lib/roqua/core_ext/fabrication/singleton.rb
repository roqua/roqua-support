class Fabricate
  @singletons = {}

  def self.singleton(name, options={}, &block)
    @singletons[name] ||= Fabricate(name, options={}, &block)
    return @singletons[name]
  end
end