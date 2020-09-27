require_relative "./automated_init"

context "Memory" do
  bucket = Controls::Bucket.example
  key = Controls::Key.example
  data = Controls::Data.example
  url = Controls::URL.example
  storage_key = Controls::Key.storage_key

  test "put" do
    memory = Storage::Memory.new

    memory.put(bucket, key, data)

    assert memory.storage[storage_key] == data
  end

  test "get" do
    memory = Storage::Memory.new
    memory.storage[storage_key] = data

    stored = memory.get(bucket, key)

    assert stored == data
  end

  test "remove" do
    memory = Storage::Memory.new
    memory.storage[storage_key] = data

    memory.remove(bucket, key)

    stored = memory.storage[storage_key]
    assert stored.nil?
  end

  test "exists?" do
    memory = Storage::Memory.new
    memory.storage[storage_key] = data

    exists = memory.exists?(bucket, key)

    assert exists
  end

  test "doesnt exist" do
    memory = Storage::Memory.new

    exists = memory.exists?(bucket, key)

    refute exists
  end

  test "store" do
    memory = Storage::Memory.new
    file = Controls::File.example
    file.write(data)
    file.flush

    memory.store(bucket, key, file.path)

    stored = memory.storage[storage_key]
    assert stored == data
  end

  test "fetch" do
    memory = Storage::Memory.new
    file = Controls::File.example
    memory.storage[storage_key] = data

    memory.fetch(bucket, key, file.path)

    written = file.read
    assert written == data
  end

  test "url with base" do
    memory = Storage::Memory.new
    memory.url_base = url

    data_url = memory.url(bucket, key)

    assert data_url == "#{url}/#{bucket}/#{key}"
  end

  test "url without base" do
    memory = Storage::Memory.new

    data_url = memory.url(bucket, key)

    assert data_url == storage_key
  end
end
