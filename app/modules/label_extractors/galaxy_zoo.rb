# frozen_string_literal: true

module LabelExtractors
  class GalaxyZoo
    class UnknownTaskKey < StandardError; end
    class UnknownLabelKey < StandardError; end

    attr_reader :task_lookup_key, :task_prefix_label

    # TODO: add all GZ decision tree task label lookups here
    # staging: T0, T1, T2, T3, T4, T5, T6, T7, T8, T9(== T10 prod), T10(== T11 prod)
    # production: T0, T1, T2, T3, T4, T5, T6, T7, T8, T10 (last task - not used in training), T11
    # T0
    # 'smooth-or-featured-dr5': ['_smooth', '_featured-or-disk', '_artifact']
    # T1
    # 'how-rounded-dr5': ['_round', '_in-between', '_cigar-shaped']
    # T2
    # 'disk-edge-on-dr5': ['_yes', '_no']
    # T3
    # 'edge-on-bulge-dr5': ['_boxy', '_none', '_rounded']
    # T4
    # 'bar-dr5': ['_strong', '_weak', '_no']
    # T5
    # 'has-spiral-arms-dr5': ['_yes', '_no']
    # T6
    # 'spiral-winding-dr5': ['_tight', '_medium', '_loose']
    # T7
    # 'spiral-arm-count-dr5': ['_1', '_2', '_3', '_4', '_more-than-4', '_cant-tell']
    # T8
    # 'bulge-size-dr5': ['_dominant', '_large', '_moderate', '_small', '_none']
    # T11 (T10 on staging)
    # 'merging-dr5': ['_none', '_minor-disturbance', '_major-disturbance', '_merger']

    # NOTE: as the workflow question task key's don't change often they
    # have been hardcoded for now, can switch to dynamic lookup if needed
    #
    # use the known catalogue schema for Zoobot decals
    # https://github.com/mwalmsley/zoobot/blob/1a4f48105254b3073b6e3cb47014c6db938ba73f/zoobot/label_metadata.py#L32
    TASK_KEY_LABEL_PREFIXES = {
      'T0' => 'smooth-or-featured',
      'T1' => 'how-rounded-',
      # 'T' => '',
    }.freeze
    TASK_KEY_DATA_LABELS = {
      'T0' => {
        '0' => 'smooth',
        '1' => 'featured-or-disk',
        '2' => 'artifact'
      },
      'T1' => {
        '0' => 'round',
        '1' => 'in-between',
        '2' => 'cigar-shaped'
      }
    }.freeze

    def self.label_prefixes
      TASK_KEY_LABEL_PREFIXES
    end

    def self.data_labels
      TASK_KEY_DATA_LABELS
    end

    # convert this and extract method to an instance vs static class method
    # and use the injected task_lookup_key
    # to determine which
    def initialize(task_lookup_key)
      @task_lookup_key = task_lookup_key
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
      data_hash.transform_keys do |key|
        # TODO: inject the data release (-dr5 / -dr8)
        # catalogue identifier here
        # NOTE: we only use -dr8 for now, -dr5 is fininshed like -dr12 (gz 1 & 2)
        # e.g. -dr8 and allow this to be set via ENV var at boot / run time
        "#{task_prefix_label}_#{data_payload_label(key)}"
      end
    end

    private

    def task_prefix
      prefix = TASK_KEY_LABEL_PREFIXES[task_lookup_key]
      raise UnknownTaskKey, "key not found: #{task_lookup_key}" unless prefix

      prefix
    end

    def data_payload_label(key)
      label = TASK_KEY_DATA_LABELS.dig(task_lookup_key, key)
      raise UnknownLabelKey, "key not found: #{key}" unless label

      label
    end
  end
end
