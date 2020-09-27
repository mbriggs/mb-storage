class Storage
  module Controls
    module Key
      def self.example
        "key"
      end

      def self.storage_key
        "#{Controls::Bucket.example}/#{example}"
      end
    end
  end
end
