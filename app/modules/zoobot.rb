# frozen_string_literal: true

module Zoobot
  CONTAINER_TRAINING_PATH_PREFIX = "/#{Rails.env}/training_images"
  CONTAINER_PATH_PREFIX = "/#{Rails.env}/training_catalogues"

  def self.container_image_path(image_url)
    image_file_name = File.basename(image_url)
    "#{CONTAINER_TRAINING_PATH_PREFIX}/#{image_file_name}"
  end

  def self.storage_path_key(workflow_id)
    "#{CONTAINER_PATH_PREFIX}/workflow-#{workflow_id}"
  end
end
