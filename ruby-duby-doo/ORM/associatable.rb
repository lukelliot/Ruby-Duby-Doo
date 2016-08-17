require 'active_support/inflector'
require_relative 'has_many_options'
require_relative 'belongs_to_options'
require_relative 'sql_object'
require_relative 'db_connection'

module Associatable
  def belongs_to(name, options = {})
    self.assoc_options[name] = BelongsToOptions.new(name, options)

    define_method(name) do
      options = self.class.assoc_options[name]
      fkey_value = self.send(options.foreign_key)
      options
        .model_class
        .where(options.primary_key => fkey_value)
        .first
    end
  end

  def has_many(name, options = {})
    self.assoc_options[name]= HasManyOptions.new(name, self.name, options)

    define_method(name) do
      options = self.class.assoc_options[name]
      fkey_value = self.send(options.primary_key)
      options
        .model_class
        .where(options.foreign_key => fkey_value)
    end
  end

  def has_one_through(name, through_name, source_name)
    define_method(name) do
      through_options = self.class.assoc_options[through_name]
      source_options = through_options.model_class.assoc_options[source_name]

      through_table = through_options.table_name
      through_pkey = through_options.primary_key
      through_fkey = through_options.foreign_key

      source_table = source_options.table_name
      source_pkey = source_options.primary_key
      source_fkey = source_options.foreign_key

      through_fkey_value = self.send(through_fkey)
      res = DBConnection.execute(<<-SQL, through_fkey_value)
        SELECT #{source_table}.*
        FROM #{through_table}
        JOIN #{source_table}
          ON #{through_table}.#{source_fkey} = #{source_table}.#{source_pkey}
        WHERE #{through_table}.#{through_pkey} = ?
      SQL

      source_options.model_class.parse_all(res).first
    end
  end

  def assoc_options
    @assoc_options ||= {}
    @assoc_options
  end
end

class SQLObject
  extend Associatable
end
