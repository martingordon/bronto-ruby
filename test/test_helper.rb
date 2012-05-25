require 'test/unit'
require 'turn'
require 'shoulda'

require 'bronto'
Bronto::Base.api_key = "800B6CB2-8709-4325-B338-8321897A11CA"

Savon.configure do |config|
  config.log = false
end

HTTPI.log = false


def reset_all
  types = [Bronto::Contact, Bronto::Field, Bronto::List]

  types.each do |type|
    objs = type.find
    type.destroy(objs) if objs.count > 0
  end
end
