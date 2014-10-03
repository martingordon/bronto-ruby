require_relative 'test_helper'

class ListTest < Test::Unit::TestCase
  context "" do
    setup do
      @list = Bronto::List.new(name: "test_list", label: "Test List", visibility: "private")
    end

    teardown do
      reset_all
    end

    should "create a new list" do
      assert_equal nil, @list.id

      @list.save

      assert_not_nil @list.id
      assert_equal 0, @list.errors.count
    end

    should "get error on duplicate list" do
      @list.save

      l2 = Bronto::List.new(name: "test_list", label: "Test List 2", visibility: "private")
      l2.save

      assert_equal nil, l2.id
      assert_equal 1, l2.errors.count
      assert_equal "502", l2.errors.messages.keys.first
    end

    should "destroy a list" do
      @list.save

      assert_nothing_raised do
        @list.destroy
      end
    end

    should "find all lists" do
      @list.save

      lists = Bronto::List.find

      assert_equal 1, lists.count
      assert_equal @list.id, lists.first.id

      l2 = Bronto::List.new(name: "test_list_2", label: "Test List 2", visibility: "private")
      l2.save

      assert_not_nil l2.id

      lists = Bronto::List.find

      assert_equal 2, lists.count
    end

    should "find a specific list" do
      @list.save

      filter = Bronto::Filter.new
      filter.add_filter("name", "StartsWith", "test")

      lists = Bronto::List.find(filter)

      assert_equal 1, lists.count
      assert_equal @list.id, lists.first.id

      filter = Bronto::Filter.new
      filter.add_filter("id", @list.id)

      lists = Bronto::List.find(filter)

      assert_equal 1, lists.count
      assert_equal @list.id, lists.first.id
    end

    should "add to list" do
      @list.save

      assert_equal 0, @list.errors.count

      contact = Bronto::Contact.new(email: "#{Time.now.to_i}-#{rand(1000)}@example.com", status: "active")
      contact.save
      assert_equal 0, contact.errors.count

      assert_equal 0, @list.active_count

      assert @list.add_to_list(contact)

      sleep(5)

      @list.reload
      assert_equal 1, @list.active_count
    end

    should "remove from list" do
      @list.save
      assert_equal 0, @list.errors.count

      contact = Bronto::Contact.new(email: "#{Time.now.to_i}-#{rand(1000)}@example.com", status: "active")
      contact.save
      assert_equal 0, contact.errors.count

      contact2 = Bronto::Contact.new(email: "#{Time.now.to_i}-#{rand(1000)}@example.com", status: "active")
      contact2.save
      assert_equal 0, contact2.errors.count

      assert @list.add_to_list(contact, contact2)

      sleep(5)

      @list.reload
      assert_equal 2, @list.active_count

      assert @list.remove_from_list(contact)

      @list.reload
      assert_equal 1, @list.active_count
    end

    should "clear list" do
      @list.save

      contact = Bronto::Contact.new(email: "#{Time.now.to_i}-#{rand(1000)}@example.com", status: "active")
      contact.save
      assert_equal 0, contact.errors.count

      contact2 = Bronto::Contact.new(email: "#{Time.now.to_i}-#{rand(1000)}@example.com", status: "active")
      contact2.save
      assert_equal 0, contact2.errors.count

      assert @list.add_to_list(contact, contact2)

      sleep(5)

      @list.reload
      assert_equal 2, @list.active_count

      assert Bronto::List.clear_lists(@list)

      sleep(5)

      @list.reload
      assert_equal 0, @list.active_count
    end
  end
end
