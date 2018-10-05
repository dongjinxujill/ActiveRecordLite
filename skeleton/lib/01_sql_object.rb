require_relative 'db_connection'
require 'active_support/inflector'


class SQLObject

  def self.columns
    DBConnection.execute2(<<-SQL)
      SELECT
        *
      FROM
        #{self.table_name}
    SQL
      .first.map {|el| el.to_sym}
  end

  def attributes
    @attributes ||= {}

  end

  def self.finalize!
    self.columns.each do |col|
      define_method(col) do
        attributes[col]
      end
      define_method("#{col}=") do |val|
        attributes[col] = val
      end
    end
  end

  def self.table_name=(table_name)
    table_name
  end

  def self.table_name
    self.to_s.downcase + 's'
  end

  def self.all
    res = DBConnection.execute(<<-SQL)
      SELECT
        *
      FROM
        #{self.table_name}
    SQL

    self.parse_all(res)

  end

  def self.parse_all(results)
    x = []
    results.each do |res|
      x << self.new(res)
    end
    x
  end

  def self.find(id)

    self.all.find { |obj| obj.id == id }

  end

  def initialize(params = {})
    params.each do |k,v|
      if !self.class.columns.include?(k.to_sym)
        raise "unknown attribute '#{k}'"
      else
        send("#{k}=", v)
      end
    end
  end


  def attribute_values
    self.class.columns.map do |el|
      send("#{el}=", attributes[el])
    end
  end

  def insert
    col_names = self.class.columns.join(',')
    question_marks = (["?"] * (self.class.columns).length).join(',')

    DBConnection.execute(<<-SQL, *attribute_values)
      INSERT INTO
        #{self.class.table_name} (#{col_names})
      VALUES
        (#{question_marks})
    SQL
    self.id = DBConnection.last_insert_row_id

  end



  def save

    if self.id.nil?
      self.insert
    else
      self.update
    end
  end
end
