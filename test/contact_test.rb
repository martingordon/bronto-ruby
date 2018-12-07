require_relative 'test_helper'

class ContactTest < Test::Unit::TestCase
  context "" do
    setup do
      @contact = Bronto::Contact.new(email: "#{Time.now.to_i}-#{rand(1000)}@example.com", status: "active")
    end

    teardown do
      reset_all
    end

    should "create a new contact" do
      assert_equal nil, @contact.id

      @contact.save

      assert_not_nil @contact.id
      assert_equal 0, @contact.errors.count
    end

    should "update contact status" do
      assert_equal nil, @contact.id

      @contact.status = 'unsub'
      @contact.update

      assert_not_nil @contact.id
      assert_equal 0, @contact.errors.count
    end

    should "destroy a contact" do
      @contact.save

      assert_nothing_raised do
        @contact.destroy
      end
    end

    should "find all contacts" do
      @contact.save

      contacts = Bronto::Contact.find

      assert_equal 1, contacts.count
      assert_equal @contact.id, contacts.first.id

      c2 = Bronto::Contact.new(email: "#{Time.now.to_i}-#{rand(1000)}@example.com")
      c2.save

      assert_not_nil c2.id

      contacts = Bronto::Contact.find

      assert_equal 2, contacts.count
    end

    should "find a specific contact" do
      @contact.save

      filter = Bronto::Filter.new
      filter.add_filter("email", "EndsWith", "example.com")

      contacts = Bronto::Contact.find(filter)

      assert_equal 1, contacts.count
      assert_equal @contact.id, contacts.first.id

      filter = Bronto::Filter.new
      filter.add_filter("id", @contact.id)

      contacts = Bronto::Contact.find(filter)

      assert_equal 1, contacts.count
      assert_equal @contact.id, contacts.first.id
    end

    should "include fields in results" do
      f = Bronto::Field.new(name: "test_field", label: "Test Field", type: "text", visibility: "private")
      f.save

      @contact.set_field(f, "test value")
      @contact.save

      contacts = Bronto::Contact.find(Bronto::Filter.new, 1, [f.id], true)
      assert_equal @contact.id, contacts.first.id
      assert_equal "test value", contacts.first.get_field(f)
    end
  end
end
