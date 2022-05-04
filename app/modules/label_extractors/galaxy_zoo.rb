# frozen_string_literal: true

module LabelExtractors
  class GalaxyZoo
    class UnknownTaskKey < StandardError; end
    class UnknownLabelKey < StandardError; end

    attr_reader :task_schema_lookup_key, :task_prefix_label

    # TODO: add all GZ decision tree task label lookups here
    # staging: T0, T1, T2, T3, T4, T5, T6, T7, T8, T9, T10
    # production: T0, T1, T2, T3, T4, T5, T6, T7, T8, T10, T11
    #
    # note: as the workflow question task key's don't change often they
    # have been hardcoded for now, can switch to dynamic lookup if needed
    TASK_LABEL_KEY_PREFIXES = {
      'T0' => 'smooth-or-featured'
    }.freeze
    TASK_KEY_DATA_LABELS = {
      'T0' => {
        '0' => 'smooth',
        '1' => 'featured-or-disk',
        '2' => 'artifact'
      }
    }.freeze

    # convert this and extract method to an instance vs static class method
    # and use the injected task_schema_lookup_key
    # to determine which
    def initialize(task_schema_lookup_key)
      @task_schema_lookup_key = task_schema_lookup_key
      @task_prefix_label = task_prefix
    end

    # extract the keys from the user_reduction data hash
    # and convert the keys to the workflow question tasks
    #
    # e.g. workflow type (GZ) are question type 'decision tree' tasks
    # looking at the 'T0' task it correlates to 3 exclusive answers:
    # 0 (smooth)
    # 1 (features or disk)
    # 2 (star or artifact)
    #
    # then combined with the label prefix used to identify the correlated task name for Zoobot
    def extract(data_hash)
      # use the known catalogue schema for Zoobot decals
      # https://github.com/mwalmsley/zoobot/blob/1a4f48105254b3073b6e3cb47014c6db938ba73f/zoobot/label_metadata.py#L32
      data_hash.transform_keys do |key|
        "#{task_prefix_label}_#{data_payload_label(key)}"
      end
    end

    private

    def task_prefix
      prefix = TASK_LABEL_KEY_PREFIXES[task_schema_lookup_key]
      raise UnknownTaskKey, "key not found: #{task_schema_lookup_key}" unless prefix

      prefix
    end

    def data_payload_label(key)
      label = TASK_KEY_DATA_LABELS.dig(task_schema_lookup_key, key)
      raise UnknownLabelKey, "key not found: #{key}" unless label

      label
    end
  end
end
