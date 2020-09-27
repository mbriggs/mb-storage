class Storage
  class Memory
    include Storage::Interface
    include Settings::Setting
    include Configure
    include Log::Dependency

    setting :url_base

    configure :memory_storage

    def self.build
      instance = new
      settings = Settings.build("settings/settings.json")
      settings.set(instance, :storage)
      instance
    end

    def storage
      @storage ||= {}
    end

    def exists?(bucket, key)
      storage_key = storage_key(bucket, key)
      !self.storage[storage_key].nil?
    end

    def fetch(bucket, key, path)
      storage_key = storage_key(bucket, key)
      data = self.storage[storage_key]
      File.open(path, 'wb') { |f| f.write(data) }
    end

    def get(bucket, key)
      storage_key = storage_key(bucket, key)
      self.storage[storage_key]
    end

    def put(bucket, key, data, **kwargs)
      storage_key = storage_key(bucket, key)
      self.storage[storage_key] = data
    end

    def store(bucket, key, path)
      storage_key = storage_key(bucket, key)
      data = File.read(path)
      self.storage[storage_key] = data
    end

    def remove(bucket, key)
      storage_key = storage_key(bucket, key)
      self.storage.delete(storage_key)
    end

    def url(bucket, key, **kwargs)
      if url_base
        "#{url_base}/#{bucket}/#{key}"
      else
        storage_key(bucket, key)
      end
    end

    def storage_key(bucket, key)
      "#{bucket}/#{key}"
    end
  end
end
