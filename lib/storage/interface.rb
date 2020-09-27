class Storage
  module Interface
    def self.included(cls)
      cls.class_exec do
        include Virtual

        abstract :exists?
        abstract :fetch
        abstract :copy
        abstract :get
        abstract :put
        abstract :store
        abstract :remove
        abstract :url
      end
    end
  end
end
