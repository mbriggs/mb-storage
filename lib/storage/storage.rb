class Storage
  include Storage::Interface
  include Configure
  include Log::Dependency

  configure :storage

  attr_writer :backends, :primary

  def backends
    @backends ||= [Memory.build]
  end

  def primary
    @primary ||= backends.first
  end

  def self.build(settings: nil)
    instance = new

    settings ||= Settings.build("settings/settings.json")
    backend_types = Array(settings.get(:storage, :type))
    primary_type = settings.get(:storage, :primary)

    backends = backend_types.map { |t| storage_type(t).build }
    primary = nil

    if primary_type
      primary_type = storage_type(primary_type)
      primary = backends.find { |b| b.instance_of?(primary_type) }
    end

    instance.primary = primary
    instance.backends = backends
    instance
  end

  def self.storage_type(type)
    case type
    when "memory"
      Memory.build
    when "filesystem"
      Filesystem.build
    when "s3"
      S3.build
    else
      raise "storage type not supported #{type}"
    end
  end

  def exists?(bucket, key)
    backends.any? { |backend| backend.exists?(bucket, key) }
  end

  def fetch(bucket, key, path)
    logger.debug { "fetch #{bucket}/#{key} => #{path}" }
    backend = backend(bucket, key)
    backend.fetch(bucket, key, path)
  end

  def get(bucket, key)
    backend = backend(bucket, key)
    backend.get(bucket, key)
  end

  def url(bucket, key, **kwargs)
    backend = backend(bucket, key)
    backend.url(bucket, key, **kwargs)
  end

  def put(bucket, key, data, **kwargs)
    primary.put(bucket, key, data, **kwargs)
  end

  def store(bucket, key, path, **kwargs)
    primary.store(bucket, key, path, **kwargs)
  end

  def remove(bucket, key)
    backend = backend(bucket, key)
    backend.remove(bucket, key)
  end

  def backend(bucket, key)
    if backends.length == 1
      return primary
    end

    backend = backends.find { |backend| backend.exists?(bucket, key) }
    backend || primary
  end
end
