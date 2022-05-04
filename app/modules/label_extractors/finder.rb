# frozen_string_literal: true

module LabelExtractors
  class Finder
    class UknownExtractor < StandardError; end
    class UknownTaskKey < StandardError; end

    def self.extractor_instance(task_schema_lookup_key)
      schema_name_and_task = /(.+)_(.+)/.match(task_schema_lookup_key)
      schema_klass = "LabelExtractors::#{schema_name_and_task[1].camelize}".constantize
      task_key = schema_name_and_task[2].upcase
      schema_klass.new(task_key)

    rescue NameError => _e
      raise UknownExtractor, "no extractor class found for '#{schema_name_and_task[1]}'"
    end
  end
end
