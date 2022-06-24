# frozen_string_literal: true

module Zoobot
  CONTAINER_TRAINING_PATH_PREFIX = ENV.fetch('TRAINING_PATH_PREFIX', 'training_images')
  CONTAINER_PATH_PREFIX = "/#{Rails.env}/training_catalogues"

  def self.training_image_path(image_url)
    "#{CONTAINER_TRAINING_PATH_PREFIX}/#{File.basename(image_url)}"
  end

  def self.container_image_path(image_url)
    image_file_name = training_image_path(image_url)
    "/#{Rails.env}/#{image_file_name}"
  end

  def self.storage_path_key(workflow_id)
    "#{CONTAINER_PATH_PREFIX}/workflow-#{workflow_id}"
  end

  def self.gz_label_column_headers
    %w[id_str file_loc] | LabelExtractors::GalaxyZoo.question_answers_schema
  end
end
