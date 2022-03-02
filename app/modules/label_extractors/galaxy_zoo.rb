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
      GZ_TASK_KEY_MAPPING.fetch_values(*data_hash.keys)
    rescue KeyError => e
      raise UnkonwnLabelKey, e.message
    end
  end
end
