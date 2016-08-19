require_relative 'assoc_options'

class BelongsToOptions < AssocOptions
  def initialize(name, options = {})
    defaults = {
      class_name: name.to_s.camelcase,
      primary_key: :id,
      foreign_key: %Q(#{name}_id).to_sym
    }

    defaults.keys.each do |assoc|
      self.send(%Q(#{assoc}=), options[assoc] || defaults[assoc])
    end
  end
end
