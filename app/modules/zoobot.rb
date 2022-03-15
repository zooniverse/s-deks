# frozen_string_literal: true

module Zoobot
  CONTAINER_TRAINING_PATH_PREFIX = '/training_images'

  def self.container_image_path(image_url)
    image_file_name = File.basename(image_url)
    "#{CONTAINER_TRAINING_PATH_PREFIX}/#{image_file_name}"
  end
end
