# frozen_string_literal: true

module LabelExtractors
  class GalaxyZoo
    class UnkonwnLabelKey < StandardError; end

    GZ_TASK_KEY_MAPPING = {
      '0' => 'smooth',
      '1' => 'features or disk',
      '2' => 'star or artifact'
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
      GZ_TASK_KEY_MAPPING.fetch_values(*data_hash.keys)
    rescue KeyError => e
      raise UnkonwnLabelKey, e.message
    end
  end
end
