require_relative "./automated_init"

context "S3" do
  s3 = Storage::S3.build
  bucket = "storage-test.notion.ca"

  test "basics" do
    key = "put.txt"
    data = "Test Data"

    s3.remove(bucket, key)

    refute s3.exists?(bucket, key)

    s3.put(bucket, key, data)

    assert s3.exists?(bucket, key)

    result = s3.get(bucket, key)

    assert result == data

    s3.remove(bucket, key)

    refute s3.exists?(bucket, key)
  end

  test "files" do
    key = "file.txt"
    path = "lib/storage/controls/data.txt"
    s3.remove(bucket, key)

    refute s3.exists?(bucket, key)

    s3.store(bucket, key, path)

    assert s3.exists?(bucket, key)

    remote = s3.get(bucket, key)
    local = File.read(path)
    tmp = Tempfile.new

    assert remote == local

    downloaded = s3.fetch(bucket, key, tmp.path)

    assert File.read(tmp.path) == local

    s3.remove(bucket, key)

    refute s3.exists?(bucket, key)
  end
end
