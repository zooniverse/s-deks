# frozen_string_literal: true

module LabelExtractors
  module GalaxyZoo
    class BaseExtractor
      attr_reader :task_lookup_key, :task_prefix_label

      def initialize(task_lookup_key)
          @task_lookup_key = task_lookup_key
          @task_prefix_label = task_prefix
      end

      # extract the keys from the reduction data payload hash
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
          # create the lable key used for column headers in the derived training catalogues
          # note the hyphen and underscore formatting, see Zoobot label schema for more details
          "#{task_prefix_label}-#{data_release_suffix}_#{data_payload_label(key)}"
        end
      end

      def self.label_prefixes
        self::TASK_KEY_LABEL_PREFIXES
      end

      def self.data_labels
        self::TASK_KEY_DATA_LABELS
      end

      # Base version of question_answers_schema method to be customized by subclasses
      def self.question_answers_schema
        raise NotImplementedError, "Subclass must define `question_answers_schema`"
      end

      private

      def task_prefix
        prefix = self.class::TASK_KEY_LABEL_PREFIXES[task_lookup_key]
        raise UnknownTaskKey, "key not found: #{task_lookup_key}" unless prefix

        prefix
      end

      def data_payload_label(key)
        label = self.class::TASK_KEY_DATA_LABELS.dig(task_lookup_key, key)
        raise UnknownLabelKey, "key not found: #{key}" unless label

        label
      end

      def data_release_suffix
        self.class::data_release_suffix
      end
    end
  end
end
