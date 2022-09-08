# frozen_string_literal: true

module Zoobot
  AZ_CONTAINER_NAME = ENV.fetch('AZ_CONTAINER_NAME', 'training')
  CONTAINER_CATALOG_PATH_PREFIX = "#{AZ_CONTAINER_NAME}/catalogues/#{Rails.env}"
  CONTAINER_IMAGE_PATH_PREFIX = "#{CONTAINER_CATALOG_PATH_PREFIX}/images"

  def self.training_image_path(image_url)
    "#{CONTAINER_IMAGE_PATH_PREFIX}/#{File.basename(image_url)}"
  end

  def self.container_image_path(image_url)
    prefix = ENV.fetch('TRAINING_PATH_PREFIX', "/#{Rails.env}")
    "#{prefix}/#{File.basename(image_url)}"
  end

  def self.storage_path_key(workflow_id)
    "/#{CONTAINER_CATALOG_PATH_PREFIX}/workflow-#{workflow_id}"
  end

  def self.gz_label_column_headers
    %w[id_str file_loc] | LabelExtractors::GalaxyZoo.question_answers_schema
  end
end
