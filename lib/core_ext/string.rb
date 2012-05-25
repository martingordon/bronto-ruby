class String
  unless self.new.respond_to? :pluralize
    # A very simple `pluralize` method that works for every object in the Bronto API.
    def pluralize
      self[-1] == "y" ? self[0...-1] + "ies" : self + "s"
    end
  end
end
