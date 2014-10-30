module Fetch
  class Configuration
    DEFAULTS = {
      user_agent:     "Mozilla/5.0",
      timeout:        10,
      namespaces:     ["fetch_sources"],
      raise_on_error: -> { defined?(Rails.env) && %w{development test}.include?(Rails.env) }
    }

    DEFAULTS.each do |option, value|
      ivar = "@#{option}"

      define_method(option) do
        return instance_variable_get(ivar) if instance_variable_defined?(ivar)
        value = value.call if value.is_a?(Proc)
        instance_variable_set(ivar, value)
      end

      define_method("#{option}=") do |value|
        instance_variable_set(ivar, value)
      end
    end

    # Convenience method for defining a single namespace that contains fetch modules.
    def namespace=(value)
      self.namespaces = [value]
    end
  end
end