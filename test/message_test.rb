require_relative 'test_helper'

class MessageTest < Test::Unit::TestCase
  context "" do
    setup do
      @message = Bronto::Message.new(name: "Test Message")
      @message.add_content("html", "HTML Subject", "HTML Content")
      @message.add_content("text", "Text Subject", "Text Content")
    end

    teardown do
      reset_all
    end

    should "create a new message" do
      assert_equal nil, @message.id

      @message.save

      assert_not_nil @message.id
      assert_equal 0, @message.errors.count
    end

    should "get error on duplicate message" do
      @message.save

      m2 = Bronto::Message.new(name: "Test Message")
      m2.save

      assert_equal nil, m2.id
      assert_equal 1, m2.errors.count
      assert_equal "615", m2.errors.messages.keys.first
    end

    should "destroy a message" do
      @message.save

      assert_nothing_raised do
        @message.destroy
      end
    end

    should "find all messages" do
      @message.save

      messages = Bronto::Message.find

      assert_equal 1, messages.count
      assert_equal @message.id, messages.first.id

      m2 = Bronto::Message.new(name: "Test Message 2")
      m2.save

      assert_not_nil m2.id

      messages = Bronto::Message.find

      assert_equal 2, messages.count
    end

    should "find a specific message" do
      @message.save

      m2 = Bronto::Message.new(name: "Test Message 2")
      m2.save

      filter = Bronto::Filter.new
      filter.add_filter("name", "StartsWith", "Test")

      messages = Bronto::Message.find(filter)

      assert_equal 2, messages.count

      filter = Bronto::Filter.new
      filter.add_filter("id", @message.id)

      messages = Bronto::Message.find(filter)

      assert_equal 1, messages.count
      assert_equal @message.id, messages.first.id
    end
  end
end
