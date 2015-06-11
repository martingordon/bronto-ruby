# Bronto

This is a handy library that wraps the Bronto SOAP API.

## Installation

Add this line to your application's Gemfile:

    gem 'bronto'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install bronto

## Usage

Let's setup some contacts, add them to a list, and then send them a message.

1. Require the library and specify the API Key on the Base class:

    ```
    require 'bronto'
    Bronto::Base.api_key = "..."
    ```

2. Create two contacts:

    ```
    contact_1 = Bronto::Contact.new(email: "test_1@example.com")
    contact_2 = Bronto::Contact.new(email: "test_2@example.com")

    puts contact_1.id
    # => nil

    puts contact_2.id
    # => nil

    # You can save multiple objects with one API call using the class `save` method.
    Bronto::Contact.save(contact_1, contact_2)

    # Both contacts should now have ids.
    puts contact_1.id
    # => "32da24c..."

    puts contact_2.id
    # => "98cd453..."
    ```

3. Create a list and the contacts:

    ```
    list = Bronto::List.new(name: "A Test List", label: "This is a test list.")
    list.save

    list.add_to_list(contact_1, contact_2)
    ```

4. Create a new message and add content:

    ```
    message = Bronto::Message.new(name: "Test Message")
    message.add_content("html", "HTML Subject", "HTML Content")
    message.add_content("text", "Text Subject", "Text Content")
    message.save
    ```

5. Create a new delivery with a message and recipients and send it ASAP:

    ```
    delivery = Bronto::Delivery.new(start: Time.now, type: "normal", from_name: "Test", from_email: "test@example.com")
    delivery.message_id = message.id
    delivery.add_recipient(list)
    delivery.save
    ```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
