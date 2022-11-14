# frozen_string_literal: true

module LabelExtractors
  module GalaxyZoo
    class CosmicDawn
      class UnknownTaskKey < StandardError; end
      class UnknownLabelKey < StandardError; end

      attr_reader :task_lookup_key, :task_prefix_label

      # GZ decision tree task schema and lable tables
      #
      # NOTE: staging is the same as prod but T10 maps to T11(prod) and T9 (last task) maps to T10(prod)
      # this mapping is done via the caesar external effect url configs
      # so T10 Reducer output sends to T11 schema mapping in KaDE
      # see details below for production schema task mappings
      #
      # Derived to conform to the existing catalogue schema for Zoobot decals (dr5, dr8 and onwards)
      # https://github.com/mwalmsley/zoobot/blob/1a4f48105254b3073b6e3cb47014c6db938ba73f/zoobot/label_metadata.py#L32
      TASK_KEY_LABEL_PREFIXES = {
        'T0' => 'smooth-or-featured',
        'T1' => 'how-rounded',
        'T2' => 'disk-edge-on',
        'T3' => 'edge-on-bulge',
        'T4' => 'bar',
        'T5' => 'has-spiral-arms',
        'T6' => 'spiral-winding',
        'T7' => 'spiral-arm-count',
        'T8' => 'bulge-size',
        'T11' => 'merging', # T10 is not used for training and no T9 in prod :shrug:
        'T12' => 'lensing',
        'T13' => 'clumps',
        'T14' => 'problem',
        'T15' => 'artifact'
      }.freeze
      TASK_KEY_DATA_LABELS = {
        'T0' => {
          '0' => 'smooth',
          '1' => 'featured-or-disk',
          '2' => 'problem'
        },
        'T1' => {
          '0' => 'round',
          '1' => 'in-between',
          '2' => 'cigar-shaped'
        },
        'T2' => {
          '0' => 'yes',
          '1' => 'no'
        },
        'T3' => {
          '0' => 'rounded',
          '1' => 'boxy',
          '2' => 'none'
        },
        'T4' => {
          '0' => 'no',
          '1' => 'weak',
          '2' => 'strong'
        },
        'T5' => {
          '0' => 'yes',
          '1' => 'no'
        },
        'T6' => {
          '0' => 'tight',
          '1' => 'medium',
          '2' => 'loose'
        },
        'T7' => {
          '0' => '1',
          '1' => '2',
          '2' => '3',
          '3' => '4',
          '4' => 'more-than-4',
          '5' => 'cant-tell'
        },
        'T8' => {
          '0' => 'none',
          '1' => 'small',
          '2' => 'moderate',
          '3' => 'large',
          '4' => 'dominant'
        },
        'T11' => {
          '0' => 'merger',
          '1' => 'major-disturbance',
          '2' => 'minor-disturbance',
          '3' => 'none'
        },
        'T12' => {
          '0' => 'yes',
          '1' => 'no'
        },
        'T13' => {
          '0' => 'yes',
          '1' => 'no'
        },
        'T14' => {
          '0' => 'star',
          '1' => 'non-star',
          '2' => 'zoom'
        },
        'T15' => {
          '0' => 'saturation',
          '1' => 'diffraction',
          '2' => 'satellite',
          '3' => 'ray',
          '4' => 'scattered',
          '5' => 'other'
        }
      }.freeze

      def self.label_prefixes
        TASK_KEY_LABEL_PREFIXES
      end

      def self.data_labels
        TASK_KEY_DATA_LABELS
      end

      # provide a flat task question and answers list for the decals mission catalogues
      def self.question_answers_schema
        label_prefixes.map do |task_key, question_prefix|
          data_labels[task_key].values.map do |answer_suffix|
            "#{question_prefix}_#{answer_suffix}"
          end
        end.flatten
      end

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
      # 2 (problem)
      #
      # then combined with the label prefix used to identify the correlated task name for Zoobot
      def extract(data_hash)
        data_hash.transform_keys do |key|
          # create the lable key used for column headers in the derived training catalogues
          # note the hyphen and underscore formatting, see Zoobot lable schema for more details
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
end
