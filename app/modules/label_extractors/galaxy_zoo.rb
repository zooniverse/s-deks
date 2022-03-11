# frozen_string_literal: true

module LabelExtractors
  class GalaxyZoo
    class UnkonwnLabelKey < StandardError; end

    GZ_LABEL_KEY_PREFIX = 'smooth-or-featured_'
    GZ_TASK_KEY_MAPPING = {
      '0' => 'smooth',
      '1' => 'featured-or-disk',
      '2' => 'artifact'
    }.freeze

    # extract the keys from the user_reduction data hash
    # and convert the keys to the workflow question tasks
    #
    # note: as the workflow question task key's don't change often they
    # have been hardcoded for now, can switch to dynamic lookup if needed
    def self.extract(data_hash)
      # e.g. workflow type (GZ) is question type tasks (T0 task specifically)
      # which correlates to 3 exclusive answers:
      # 0 (smooth)
      # 1 (features or disk)
      # 2 (star or artifact)
      #
      # asked mike about the enhanced workflow
      # it only uses T0 data but we collect all task data in the raw classifications (T0 - TN)
      # however caesar only extracts / reduces T0 data
      # and Mike confirmed my understanding
      # that only task T0 is what Zoobot / Active Learning Loop is training and classifying on
      #
      # use the known catalogue schema for Zoobot decals
      # https://github.com/mwalmsley/zoobot/blob/1a4f48105254b3073b6e3cb47014c6db938ba73f/zoobot/label_metadata.py#L32
      data_hash.transform_keys do |key|
        raise UnkonwnLabelKey, "key not found: #{key}" unless GZ_TASK_KEY_MAPPING[key]

        "#{GZ_LABEL_KEY_PREFIX}#{GZ_TASK_KEY_MAPPING[key]}"
      end
    end
  end
end
