class Storage
  class Log < ::Log
    def tag!(tags)
      tags << :storage
    end
  end
end
