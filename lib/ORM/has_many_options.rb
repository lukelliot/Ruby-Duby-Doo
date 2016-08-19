require_relative 'assoc_options'

class HasManyOptions < AssocOptions
  def initialize(name, self_class_name, options = {})
    defaults = {
      class_name: name.to_s.singularize.camelcase,
      primary_key: :id,
      foreign_key: %Q(#{self_class_name.underscore}_id).to_sym
    }

    defaults.keys.each do |assoc|
      self.send(%Q(#{assoc}=), options[assoc] || defaults[assoc])
    end
  end
end
