require_relative 'test_helper'

class BaseTest < Test::Unit::TestCase
  context "" do
    teardown do
      reset_all
    end

    should "reuse clients when the api key is the same" do
      client1 = Bronto::Base.api('api-key-1')
      client2 = Bronto::Base.api('api-key-1')

      assert client1.is_a?(Savon::Client)
      assert_equal client1, client2
    end

    should "not reuse clients when the api key is different" do
      client1 = Bronto::Base.api('api-key-1')
      client2 = Bronto::Base.api('api-key-2')

      assert client1.is_a?(Savon::Client)
      assert client2.is_a?(Savon::Client)
      assert_not_equal client1, client2
    end
  end
end
