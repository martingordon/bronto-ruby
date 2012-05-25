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

  unless self.new.respond_to? :try
    # From: activesupport/lib/active_support/core_ext/object/try.rb, line 28
    def try(*a, &b)
      if a.empty? && block_given?
        yield self
      else
        __send__(*a, &b)
      end
    end
  end
end

class NilClass
  # From: activesupport/lib/active_support/core_ext/object/try.rb, line 50
  def try(*args)
    nil
  end
end
