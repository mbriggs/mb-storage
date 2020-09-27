class Storage
  class S3
    include Storage::Interface
    include Dependency
    include Configure
    include Log::Dependency

    dependency :client, Aws::S3::Client
    dependency :resource, Aws::S3::Resource

    configure :s3_storage

    def self.build
      instance = new
      settings = Settings.build("settings/settings.json")
      access_key_id = settings.get(:aws, :access_key_id)
      secret_access_key = settings.get(:aws, :secret_access_key)
      region = settings.get(:aws, :region)

      credentials = Aws::Credentials.new(access_key_id, secret_access_key)

      config = {credentials: credentials, region: region}

      instance.client = Aws::S3::Client.new(config)
      instance.resource = Aws::S3::Resource.new(client: instance.client)

      return instance
    end

    def exists?(bucket, key)
      object(bucket, key).exists?
    rescue Aws::S3::Errors::Forbidden
      raise AccessDeniedError.new(bucket, key)
    end

    def fetch(bucket, key, path)
      object(bucket, key).download_file(path)
    rescue Aws::S3::Errors::Forbidden
      raise AccessDeniedError.new(bucket, key)
    end

    def copy(from_bucket, from_key, to_bucket, to_key)
      client.copy_object(
        bucket: to_bucket,
        key: to_key,
        copy_source: "#{from_bucket}/#{from_key}"
      )
    rescue Aws::S3::Errors::Forbidden
      raise AccessDeniedError.new(bucket, key)
    end

    def get(bucket, key)
      object(bucket, key).get.body.read
    rescue Aws::S3::Errors::Forbidden
      raise AccessDeniedError.new(bucket, key)
    end

    def put(bucket, key, data, private: true)
      client.put_object(body: data, bucket: bucket, key: key,
                        acl: private ? 'private' : 'public')

    rescue Aws::S3::Errors::Forbidden
      raise AccessDeniedError.new(bucket, key)
    end

    def store(bucket, key, path, private: true)
      File.open(path, 'rb') do |file|
        client.put_object(bucket: bucket, key: key, body: file,
                          acl: private ? 'private' : 'public')
      end
    rescue Aws::S3::Errors::Forbidden
      raise AccessDeniedError.new(bucket, key)
    end

    def remove(bucket, key)
      object(bucket, key).delete
    rescue Aws::S3::Errors::Forbidden
      raise AccessDeniedError.new(bucket, key)
    end

    def url(bucket, key, filename: nil, expires_in_seconds: 60 * 60 * 24 * 7, content_disposition: nil, public_url: false, **kwargs)
      return object(bucket, key).public_url if public_url

      opts = {expires_in: expires_in_seconds}

      if filename
        content_disposition = "attachment;filename=#{filename}"
      end

      opts[:response_content_disposition] = content_disposition if content_disposition

      logger.trace { "generating url for #{bucket}/#{key}." }

      url = object(bucket, key).presigned_url(:get, opts).to_s

      logger.trace { "s3 url: #{url}" }

      url

    rescue Aws::S3::Errors::Forbidden
      raise AccessDeniedError.new(bucket, key)
    end

    def object(bucket, key)
      resource.bucket(bucket).object(key)
    end

    module Substitute
      def self.build
        substitute = Storage::Memory.new
        substitute.type = "S3"
        substitute
      end
    end
  end
end
