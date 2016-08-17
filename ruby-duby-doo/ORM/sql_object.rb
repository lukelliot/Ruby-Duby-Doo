require 'active_support/inflector'
require_relative 'db_connection'

class SQLObject
  def self.columns
    return @columns if @columns

    @columns = DBConnection
                .execute2("SELECT * FROM #{table_name}")
                .first
                .map(&:to_sym)
  end

  def self.finalize!
    columns.each do |column|
      define_method(column) { attributes[column] }

      define_method("#{column}=") do |value|
        attributes[column] = value
      end
    end
  end

  def self.table_name=(table_name)
    @table_name = table_name
  end

  def self.table_name
    @table_name ||= "#{self}".tableize
  end

  def self.all
    all_rows = <<-SQL
      SELECT #{table_name}.*
      FROM #{table_name}
    SQL

    parse_all(DBConnection.execute(all_rows))
  end

  def self.parse_all(results)
    results.each_with_object([]) do |params, class_objs|
      class_objs << self.new(params)
    end
  end

  def self.find(id)
    data = DBConnection.execute(<<-SQL).first
      SELECT * FROM #{table_name} WHERE #{table_name}.id = #{id}
    SQL

    data ? self.new(data) : nil
  end

  def initialize(params = {})
    params.each do |attr_name, val|
      attr_sym = attr_name.to_sym
      unless self.class.columns.include?(attr_sym)
        raise "unknown attribute '#{attr_name}'"
      else
        self.send("#{attr_sym}=", val)
      end
    end
  end

  def attributes
    @attributes ||= {}
  end

  def attribute_values
    self.class.columns.map do |attr_name|
      self.send(attr_name.to_sym)
    end
  end

  def insert
    non_primary_cols = self.class.columns.drop(1)
    col_names = non_primary_cols.map(&:to_s).join(", ")
    question_marks = (["?"] * non_primary_cols.count).join(", ")

    DBConnection.execute(<<-SQL, *attribute_values.drop(1))
      INSERT INTO #{self.class.table_name} (#{col_names})
      VALUES (#{question_marks})
    SQL

    self.id = DBConnection.last_insert_row_id
  end

  def update
    attr_line = self.class.columns.map { |attr| %Q(#{attr} = ?) }.join(", ")

    DBConnection.execute(<<-SQL, *attribute_values, id)
      UPDATE #{self.class.table_name}
      SET #{attr_line}
      WHERE #{self.class.table_name}.id = ?
    SQL
  end

  def save
    id.nil? ? insert : update
  end
end
