require_relative 'test_helper'

class FieldTest < Test::Unit::TestCase
  context "" do
    setup do
      @field = Bronto::Field.new(name: "test_field", label: "Test Field", type: "text", visibility: "private")
    end

    teardown do
      reset_all
    end

    should "create a new field" do
      assert_equal nil, @field.id

      @field.save

      assert_not_nil @field.id
      assert_equal 0, @field.errors.count
    end

    should "get error on duplicate field" do
      @field.save

      f2 = Bronto::Field.new(name: "test_field", label: "Test Field 2", type: "text", visibility: "private")
      f2.save

      assert_equal nil, f2.id
      assert_equal 1, f2.errors.count
      assert_equal "402", f2.errors.messages.keys.first
    end

    should "destroy a field" do
      @field.save

      assert_nothing_raised do
        @field.destroy
      end
    end

    should "find all fields" do
      @field.save

      fields = Bronto::Field.find

      assert_equal 1, fields.count
      assert_equal @field.id, fields.first.id

      f2 = Bronto::Field.new(name: "test_field_2", label: "Test Field 2", type: "text", visibility: "private")
      f2.save

      assert_not_nil f2.id

      fields = Bronto::Field.find

      assert_equal 2, fields.count
    end

    should "find a specific field" do
      @field.save

      filter = Bronto::Filter.new
      filter.add_filter("name", "StartsWith", "test")

      fields = Bronto::Field.find(filter)

      assert_equal 1, fields.count
      assert_equal @field.id, fields.first.id

      filter = Bronto::Filter.new
      filter.add_filter("id", @field.id)

      fields = Bronto::Field.find(filter)

      assert_equal 1, fields.count
      assert_equal @field.id, fields.first.id
    end

  end
end
