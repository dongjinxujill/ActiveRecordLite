require_relative '02_searchable'
require 'active_support/inflector'

class AssocOptions
  attr_accessor(
    :foreign_key,
    :class_name,
    :primary_key
  )

  def model_class
    self.class_name.constantize
  end

  def table_name
    self.class_name.downcase + 's'
  end
end

class BelongsToOptions < AssocOptions
  def initialize(name, options = {})
    if options[:foreign_key]
      @foreign_key = options[:foreign_key]
    else
      @foreign_key = (name.to_s + '_id').to_sym
    end
    if options[:class_name]
      @class_name = options[:class_name]
    else
      @class_name = name.to_s.camelcase
    end
    if options[:primary_key]
      @primary_key = options[:primary_key]
    else
      @primary_key = :id
    end

  end
end

class HasManyOptions < AssocOptions
  def initialize(name, self_class_name, options = {})
    if options[:foreign_key]
      @foreign_key = options[:foreign_key]
    else
      @foreign_key = (self_class_name + '_id').downcase.to_sym
    end
    if options[:class_name]
      @class_name = options[:class_name]
    else
      @class_name = name.to_s.singularize.camelcase
    end
    if options[:primary_key]
      @primary_key = options[:primary_key]
    else
      @primary_key = :id
    end
  end
end

module Associatable
  def belongs_to(name, options = {})
    options = BelongsToOptions.new(name, options = {})
    define_method(name) do
      options = self.class.assoc_options[name]

      key_val = self.send(options.foreign_key)
      options
        .model_class
        .where(options.primary_key => key_val)
        .first
    end
  end

  def has_many(name, options = {})
    self.assoc_options[name] =
      HasManyOptions.new(name, self.name, options)

    define_method(name) do
      options = self.class.assoc_options[name]

      key_val = self.send(options.primary_key)
      options
        .model_class
        .where(options.foreign_key => key_val)

  end

  def assoc_options
    @assoc_options ||= {}
    @assoc_options
  end
end

class SQLObject
  extend Associatable
end
