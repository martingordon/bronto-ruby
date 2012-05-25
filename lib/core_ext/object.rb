class Object
  # From: activesupport/lib/active_support/core_ext/object/blank.rb, line 14

  unless self.new.respond_to? :blank?
    def blank?
      respond_to?(:empty?) ? empty? : !self
    end
  end

  unless self.new.respond_to? :present?
    # From: activesupport/lib/active_support/core_ext/object/blank.rb, line 19
    def present?
      !blank?
    end
  end
end
