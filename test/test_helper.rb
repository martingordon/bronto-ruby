require 'test/unit'
require 'turn'
require 'shoulda'

require 'bronto'
Bronto::Base.api_key = ""

Savon.configure { |config| config.log = true }

HTTPI.log = false


def reset_all
  types = [Bronto::Contact, Bronto::Field, Bronto::List]

  types.each do |type|
    objs = type.find
    type.destroy(objs) if objs.count > 0
  end
end
