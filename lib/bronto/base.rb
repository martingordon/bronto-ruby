module Bronto

  # According to Bronto's API documentation, the session credential returned by the
  # login() API call remains active for 20 minutes.  In addition, the expiration time
  # is reset after each successful use.  We will trigger a refresh before 20 minutes
  # to be on the safe side
  SESSION_REUSE_SECONDS = 120

  class Base
    attr_accessor :id, :api_key, :errors

    @@api_key = nil

    # Getter/Setter for global API Key.
    def self.api_key=(api_key)
      @@api_key = api_key
    end

    def self.api_key
      @@api_key
    end

    def self.connection_cache
      @@connection_cache ||= {}
    end

    # Simple helper method to convert class name to downcased pluralized version (e.g., Field -> fields).
    def self.plural_class_name
      self.to_s.split("::").last.downcase.pluralize
    end

    # The primary method used to interface with the SOAP API.
    #
    # If a symbol is passed in, it is converted to "method_plural_class_name" (e.g., :read => read_lists). A string
    # method is used as-is.
    # The message is a hash and becomes the body of the SOAP request
    def self.request(method, message = {})
      api_key = api_key || self.api_key

      method = "#{method}_#{plural_class_name}" if method.is_a? Symbol

      resp = api(api_key).call(method.to_sym, message: message)

      connection_cache[api_key][:last_used] = Time.now

      resp.body["#{method}_response".to_sym]
    end

    # Sets up the Savon SOAP client object, including sessionHeaders and returns the client.
    def self.api(api_key, refresh = false)
      return connection_cache[api_key][:client] unless refresh || session_expired(api_key) || connection_cache[api_key].nil?

      client = Savon.client(wsdl: 'https://api.bronto.com/v4?wsdl', ssl_version: :TLSv1_2)
      resp = client.call(:login, message: { api_token: api_key })

      connection_cache[api_key] = {
        client: Savon.client(
          wsdl: 'https://api.bronto.com/v4?wsdl',
          soap_header: {
            "tns:sessionHeader" => { session_id: resp.body[:login_response][:return] }
          },
          read_timeout: 600 # Give Bronto up to 10 minutes to reply
        ),
        last_used: nil
      }
      connection_cache[api_key][:client]
    end

    # returns true if a cached session identifier is missing or is too old
    def self.session_expired(api_key)
      return true if (connection_cache[api_key].nil?)
      last_used = connection_cache[api_key][:last_used]
      return true if (last_used == nil)
      return true if (Time.now.tv_sec - last_used.tv_sec > SESSION_REUSE_SECONDS)

      false
    end

    # Saves a collection of Bronto::Base objects.
    # Objects without IDs are considered new and are `create`d; objects with IDs are considered existing and are `update`d.
    def self.save(*objs)
      objs = objs.flatten
      api_key = objs.first.is_a?(String) ? objs.shift : self.api_key

      updates = []
      creates = []

      objs.each { |o| (o.id.present? ? updates : creates) << o }

      update(updates) if updates.count > 0
      create(creates) if creates.count > 0
      objs
    end

    # Finds objects matching the `filter` (a Bronto::Filter instance).
    def self.find(filter = Bronto::Filter.new, page_number = 1, api_key = nil)
      api_key = api_key || self.api_key

      resp = request(:read, { filter: filter.to_hash, page_number: page_number })

      Array.wrap(resp[:return]).map { |hash| new(hash) }
    end

    # Tells the remote server to create the passed in collection of Bronto::Base objects.
    # The object should implement `to_hash` to return a hash in the format expected by the SOAP API.
    #
    # Returns the same collection of objects that was passed in. Objects whose creation succeeded will be assigned the
    # ID returned from Bronto.
    # The first element passed in can be a string containing the API key; if none passed, will fall back to the global key.
    def self.create(*objs)
      objs = objs.flatten
      api_key = objs.first.is_a?(String) ? objs.shift : self.api_key

      resp = request(:add, {plural_class_name => objs.map(&:to_hash)})

      objs.each { |o| o.errors.clear }

      Array.wrap(resp[:return][:results]).each_with_index do |result, i|
        if result[:is_error]
          objs[i].errors.add(result[:error_code], result[:error_string])
        else
          objs[i].id = result[:id]
        end
      end

      objs
    end

    # Updates a collection of Bronto::Base objects. The objects should exist on the remote server.
    # The object should implement `to_hash` to return a hash in the format expected by the SOAP API.
    # The first element passed in can be a string containing the API key; if none passed, will fall back to the global key.
    def self.update(*objs)
      objs = objs.flatten
      api_key = objs.first.is_a?(String) ? objs.shift : self.api_key

      resp = request(:update, {plural_class_name => objs.map(&:to_hash)})

      objs.each { |o| o.errors.clear }
      objs
    end

    # Destroys a collection of Bronto::Base objects on the remote server.
    #
    # Returns the same collection of objects that was passed in. Objects whose destruction succeeded will
    # have a nil ID.
    #
    # The first element passed in can be a string containing the API key; if none passed, will fall back to the global key.
    def self.destroy(*objs)
      objs = objs.flatten
      api_key = objs.first.is_a?(String) ? objs.shift : self.api_key

      resp = request(:delete, {plural_class_name => objs.map { |o| { id: o.id }}})

      Array.wrap(resp[:return][:results]).each_with_index do |result, i|
        if result[:is_error]
          objs[i].errors.add(result[:error_code], result[:error_string])
        else
          objs[i].id = nil
        end
      end

      objs
    end

    # Accepts a hash whose keys should be setters on the object.
    def initialize(options = {})
      self.api_key = self.class.api_key
      self.errors = Errors.new
      options.each { |k,v| send("#{k}=", v) if respond_to?("#{k}=") }
    end

    # `to_hash` should be overridden to provide a hash whose structure matches the structure expected by the API.
    def to_hash
      {}
    end

    # Convenience instance method that calls the class `request` method.
    def request(method, message = {})
      self.class.request(method, message)
    end

    def reload
      return if self.id.blank?

      # The block below is evaluated in a weird scope so we need to capture self as _self for use inside the block.
      _self = self

      resp = request(:read, { filter: { id: _self.id } })

      resp[:return].each do |k, v|
        self.send("#{k}=", v) if self.respond_to? "#{k}="
      end

      nil
    end

    # Saves the object. If the object has an ID, it is updated. Otherwise, it is created.
    def save
      id.blank? ? create : update
    end

    # Creates the object. See `Bronto::Base.create` for more info.
    def create
      res = self.class.create(self.api_key, self)
      res.first
    end

    # Updates the object. See `Bronto::Base.update` for more info.
    def update
      self.class.update(self.api_key, self).first
    end

    # Destroys the object. See `Bronto::Base.destroy` for more info.
    def destroy
      self.class.destroy(self.api_key, self).first
    end
  end
end
