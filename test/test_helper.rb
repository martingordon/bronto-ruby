require 'turn'
require 'minitest/autorun'
require 'shoulda'

require_relative '../lib/bronto'
Bronto::Base.api_key = ""

HTTPI.log = false

def reset_all
  types = [Bronto::Contact, Bronto::Field, Bronto::List, Bronto::Message]

  types.each do |type|
    objs = type.find
    type.destroy(objs) if objs.count > 0
  end
end
