require_relative 'test_helper'

class SMSKeywordTest < Test::Unit::TestCase
  context "" do
    setup do
      @keyword = Bronto::SMSKeyword.new(name: "test_keyword", description: "Test SMS Keyword")
    end

    teardown do
      reset_all
    end

    should "create a new keyword" do
      assert_equal nil, @keyword.id

      @keyword.save

      assert_not_nil @keyword.id
      assert_equal 0, @keyword.errors.count
    end

    should "get error on duplicate keyword" do
      @keyword.save

      k2 = Bronto::SMSKeyword.new(name: "test_keyword", label: "Test SMS Keyword 2")
      k2.save

      assert_equal nil, k2.id
      assert_equal 1, k2.errors.count
      assert_equal "502", k2.errors.messages.keys.first
    end

    should "destroy a keyword" do
      @keyword.save

      assert_nothing_raised do
        @keyword.destroy
      end
    end

    should "find all keywords" do
      @keyword.save

      keywords = Bronto::SMSKeyword.find

      assert_equal 1, keywords.count
      assert_equal @keyword.id, keywords.first.id

      k2 = Bronto::SMSKeyword.new(name: "test_keyword_2", label: "Test SMS Keyword 2")
      k2.save

      assert_not_nil k2.id

      keywords = Bronto::SMSKeyword.find

      assert_equal 2, keywords.count
    end

    should "find a specific keyword" do
      @keyword.save

      filter = Bronto::Filter.new
      filter.add_filter("name", "StartsWith", "test")

      keywords = Bronto::SMSKeyword.find(filter)

      assert_equal 1, keywords.count
      assert_equal @keyword.id, keywords.first.id

      filter = Bronto::Filter.new
      filter.add_filter("id", @keyword.id)

      keywords = Bronto::SMSKeyword.find(filter)

      assert_equal 1, keywords.count
      assert_equal @keyword.id, keywords.first.id
    end

    should "add to keyword" do
      @keyword.save

      assert_equal 0, @keyword.errors.count

      contact = Bronto::Contact.new(email: "#{Time.now.to_i}-#{rand(1000)}@example.com", status: "active")
      contact.save
      assert_equal 0, contact.errors.count

      assert_equal 0, @keyword.subscriber_count

      assert @keyword.add_to_keyword(contact)

      sleep(5)

      @keyword.reload
      assert_equal 1, @keyword.subscriber_count
    end

    should "remove from keyword" do
      @keyword.save
      assert_equal 0, @keyword.errors.count

      contact = Bronto::Contact.new(email: "#{Time.now.to_i}-#{rand(1000)}@example.com", status: "active")
      contact.save
      assert_equal 0, contact.errors.count

      contact2 = Bronto::Contact.new(email: "#{Time.now.to_i}-#{rand(1000)}@example.com", status: "active")
      contact2.save
      assert_equal 0, contact2.errors.count

      assert @keyword.add_to_keyword(contact, contact2)

      sleep(5)

      @keyword.reload
      assert_equal 2, @keyword.subscriber_count

      assert @keyword.remove_from_keyword(contact)

      @keyword.reload
      assert_equal 1, @keyword.subscriber_count
    end

    # should "clear keyword" do
    #   @keyword.save

    #   contact = Bronto::Contact.new(email: "#{Time.now.to_i}-#{rand(1000)}@example.com", status: "active")
    #   contact.save
    #   assert_equal 0, contact.errors.count

    #   contact2 = Bronto::Contact.new(email: "#{Time.now.to_i}-#{rand(1000)}@example.com", status: "active")
    #   contact2.save
    #   assert_equal 0, contact2.errors.count

    #   assert @keyword.add_to_keyword(contact, contact2)

    #   sleep(5)

    #   @keyword.reload
    #   assert_equal 2, @keyword.subscriber_count

    #   assert Bronto::SMSKeyword.clear_keywords(@keyword)

    #   sleep(5)

    #   @keyword.reload
    #   assert_equal 0, @keyword.subscriber_count
    # end
  end
end
