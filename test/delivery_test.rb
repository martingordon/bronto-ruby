require_relative 'test_helper'

class DeliveryTest < Test::Unit::TestCase
  context "" do
    setup do
      @message = Bronto::Message.new(name: "Test Message")
      @message.add_content("html", "HTML Subject", "HTML Content")
      @message.add_content("text", "Text Subject", "Text Content")
      @message.save

      @contact = Bronto::Contact.new(email: "#{Time.now.to_i}-#{rand(1000)}@example.com", status: "active")
      @contact.save

      @delivery = Bronto::Delivery.new(start: Time.now.strftime("%Y-%m-%dT%H:%M:%S.%6N%:z"), from_name: "Hello", from_email: "test@example.com")
      @delivery_2 = Bronto::Delivery.new(start: (Time.now + (60 * 60 * 24 * 5)).strftime("%Y-%m-%dT%H:%M:%S.%6N%:z"), from_name: "Hello", from_email: "test2@example.com")
    end

    teardown do
      reset_all
    end

    should "create a new delivery" do
      assert_equal nil, @delivery.id

      @delivery.add_recipient(@contact)
      @delivery.save
      assert_equal "205", @delivery.errors.messages.keys.first

      @delivery.message_id = @message.id
      @delivery.save

      assert_not_nil @delivery.id
      assert_equal 0, @delivery.errors.count
    end

    should "destroy a delivery" do
      @delivery.message_id = @message.id
      @delivery.add_recipient(@contact)
      @delivery.save

      assert_nothing_raised do
        @delivery.destroy
      end
    end

    should "find all deliveries" do
      orig_delivery_count = Bronto::Delivery.find.count

      @delivery.add_recipient(@contact)
      @delivery.message_id = @message.id
      @delivery.save
      assert_not_nil @delivery.id

      sleep(2)

      deliveries = Bronto::Delivery.find
      assert_equal orig_delivery_count + 1, deliveries.count
      assert deliveries.any? { |d| d.id == @delivery.id }

      @delivery_2.add_recipient(@contact)
      @delivery_2.message_id = @message.id
      @delivery_2.save
      assert_not_nil @delivery_2.id

      sleep(2)

      deliveries = Bronto::Delivery.find
      assert_equal orig_delivery_count + 2, deliveries.count
    end

    should "find a specific delivery" do
      @delivery.add_recipient(@contact)
      @delivery.message_id = @message.id
      @delivery.save

      @delivery_2.add_recipient(@contact)
      @delivery_2.message_id = @message.id
      @delivery_2.save

      filter = Bronto::Filter.new
      filter.add_filter("message_id", @message.id)

      sleep(2)

      deliveries = Bronto::Delivery.find(filter)
      assert_equal 2, deliveries.count

      filter = Bronto::Filter.new
      filter.add_filter("id", @delivery.id)

      deliveries = Bronto::Delivery.find(filter)

      assert_equal 1, deliveries.count
      assert deliveries.any? { |d| d.id == @delivery.id }
    end
  end
end
