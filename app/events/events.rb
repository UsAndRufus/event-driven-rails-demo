module Events
  module Articles
    Drafted = Class.new(ApplicationEvent)
    Published = Class.new(ApplicationEvent)
  end
end
