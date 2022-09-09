# frozen_string_literal: true

module Zoobot
  def self.gz_label_column_headers
    %w[id_str file_loc] | LabelExtractors::GalaxyZoo.question_answers_schema
  end

  module Storage
    AZ_CONTAINER_NAME = ENV.fetch('AZ_CONTAINER_NAME', 'training')
    CATALOGUE_PREFIX = "catalogues/#{Rails.env}"
    CONTAINER_CATALOG_PATH_PREFIX = "#{AZ_CONTAINER_NAME}/#{CATALOGUE_PREFIX}"
    CONTAINER_IMAGE_PATH_PREFIX = "#{CATALOGUE_PREFIX}/images"

    def self.container_name
      AZ_CONTAINER_NAME
    end

    def self.training_image_path(image_url)
      # this needs to not have the /training/ container prefix path
      "#{CONTAINER_IMAGE_PATH_PREFIX}/#{File.basename(image_url)}"
    end

    def self.container_image_path(image_url)
      prefix = ENV.fetch('TRAINING_PATH_PREFIX', "/#{Rails.env}")
      "#{prefix}/#{File.basename(image_url)}"
    end

    def self.path_key(workflow_id)
      "/#{CONTAINER_CATALOG_PATH_PREFIX}/workflow-#{workflow_id}"
    end
  end
end
