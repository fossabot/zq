require 'test_helper'

class EchoComposerTestCase < ZQTestCase
  def test_compose_returns_data
    test_data = 'a'
    composer = ZQ::Composer::Echo.new
    result = composer.compose(test_data)
    assert_equal(test_data, result)
  end
  def test_compose_stdout_implicit
    test_data = 'a'
    assert_output test_data + "\n" do
      composer = ZQ::Composer::Echo.new
      composer.compose(test_data)
    end
  end
  def test_compose_stdout_explicit
    test_data = 'a'
    assert_output test_data + "\n" do
      composer = ZQ::Composer::Echo.new $stdout
      composer.compose(test_data)
    end
  end
  def test_compose_favours_composite_data_overraw_data
    test_data_raw = 'a'
    test_data_composite = 'A'
    file = StringIO.new
    composer = ZQ::Composer::Echo.new file
    composer.compose(test_data_raw, test_data_composite)
    assert_equal(test_data_composite + "\n", file.string)
  end
  def test_compose_to_file
    test_data = 'a'
    file = StringIO.new
    composer = ZQ::Composer::Echo.new file
    composer.compose(test_data)
    assert_equal(test_data + "\n", file.string)
  end
end

class JsonParseComposerTestCase < ZQTestCase
  def test_compose
    composer = ZQ::Composer::JsonParse.new
    json_source = "{\"a\": \"b\"}"
    new_hash = composer.compose(json_source)
    assert_equal(new_hash, {"a" => "b"})
  end
end

class JsonDumpComposerTestCase < ZQTestCase
  def test_compose
    composer = ZQ::Composer::JsonDump.new
    json_source = "{\"a\":\"b\"}"
    new_hash = composer.compose({"a" => "b"})
    assert_equal(new_hash, json_source)
  end
end


class RedisPublishComposerTestCase < ZQTestCase
  def test_compose
    channel_name = "test_ch"
    client_pub = Redis.new
    client_sub = Redis.new
    @payload = nil
    t = Thread.new do
      client_sub.subscribe(channel_name) do |on|
        on.message do |c, m|
          @payload = m
          client_sub.unsubscribe
        end
      end
    end
    # Wait until the client is subscribed
    # actullay i want to use the Wire test helper
    # in the redis-rb lib
    # https://github.com/redis/redis-rb/blob/eb7a1b5a3df862a158376c46655ffde307b8a518/test/publish_subscribe_test.rb
    sleep 1
    composer = ZQ::Composer::RedisPublish.new channel_name, client_pub
    composer.compose("some_data")
    t.join
    assert_equal("some_data", @payload)
  end
end

class UUIDjsonComposerTestCase < ZQTestCase
  def test_compose
    composer = ZQ::Composer::UUID4Hash.new
    expect(SecureRandom).to receive(:uuid).and_return("123")
    new_hash = composer.compose(Hash.new)
    assert_equal(new_hash, {"uuid" => "123"})
  end
end
