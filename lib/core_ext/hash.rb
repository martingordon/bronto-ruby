class Hash
  unless self.respond_to? :compact
    # Simple method to remove nils from an array to ease use of the SOAP API
    def compact
      delete_if { |k, v| v.nil? }
    end
  end
end