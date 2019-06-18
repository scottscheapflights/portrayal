require 'portrayal/version'
require 'portrayal/schema'

module Portrayal
  NULL = :_portrayal_value_not_set

  def keyword(name, optional: NULL, default: NULL, &block)
    unless respond_to?(:portrayal)
      class << self; attr_reader :portrayal end
      @portrayal = Schema.new
    end

    attr_reader name

    portrayal.add_keyword(name, optional, default)
    class_eval(portrayal.definition_of_initialize)

    unless portrayal.equality_defined?
      class_eval(portrayal.definition_of_equality)
      portrayal.mark_equality_defined
    end

    if block_given?
      keyword_class = Class.new(superclass) { extend Portrayal }
      keyword_class.class_eval(&block)
      const_set(portrayal.camelcase(name), keyword_class)
    end
  end
end