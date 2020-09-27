class Storage
  class Filesystem
    include Storage::Interface
    include FileUtils
    include Dependency
    include Configure
    include Settings::Setting
    include Log::Dependency

    setting :root_path
    setting :url_base

    configure :filesystem_storage

    def self.build
      instance = new
      settings = Settings.build("settings/settings.json")
      settings.set(instance, :storage)

      return instance
    end

    def exists?(bucket, key)
      File.exists?(file_path(bucket, key))
    end

    def fetch(bucket, key, path)
      cp(file_path(bucket, key), path)
    end

    def copy(from_bucket, from_key, to_bucket, to_key)
      cp(file_path(from_bucket, from_key),
         file_path(to_bucket, to_key))
    end

    def get(bucket, key)
      File.read(file_path(bucket, key))
    end

    def put(bucket, key, data, **kwargs)
      path = file_path(bucket, key)
      mk_parents(path)
      File.open(path, 'wb') { |file| file.write(data) }
    end

    def store(bucket, key, path)
      dest = file_path(bucket, key)
      mk_parents(dest)
      cp(path, dest)
    end

    def remove(bucket, key)
      return nil unless exists?(bucket, key)
      rm(file_path(bucket, key))
    end

    def url(bucket, key, **kwargs)
      "#{url_base}/#{bucket}/#{key}"
    end

    def file_path(bucket, key)
      File.absolute_path("#{root_path}/#{bucket}/#{key}")
    end

    def mk_parents(path)
      mkdir_p(File.dirname(path))
    end

    module Substitute
      def self.build
        substitute = Storage::Memory.new
        substitute.type = "Filesystem"
        substitute
      end
    end
  end
end
