require_relative "./automated_init"

context "Filesystem" do
  fs = Storage::Filesystem.build
  bucket = "storage-test.notion.ca"

  test "basics" do
    key = "put.txt"
    data = "Test Data"

    fs.remove(bucket, key)
    refute fs.exists?(bucket, key)

    fs.put(bucket, key, data)
    assert fs.exists?(bucket, key)

    remote = fs.get(bucket, key)
    assert remote == data

    fs.remove(bucket, key)
    refute fs.exists?(bucket, key)
  end

  test "files" do
    key = "file.txt"
    path = "lib/storage/controls/data.txt"

    fs.remove(bucket, key)
    refute fs.exists?(bucket, key)

    fs.store(bucket, key, path)
    assert fs.exists?(bucket, key)

    remote = fs.get(bucket, key)
    assert remote == File.read(path)

    tmp = Tempfile.new
    fs.fetch(bucket, key, tmp.path)
    assert tmp.read == File.read(path)

    fs.remove(bucket, key)
    refute fs.exists?(bucket, key)
  end
end
