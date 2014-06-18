class Fabricate
  def self.singleton(name, options={}, &block)
    @singletons[name] ||= Fabricate(name, options={}, &block)
    return @singletons[name]
  end

  def self.clear_singletons!
    @singletons = {}
  end

  clear_singletons!
end
