# frozen_string_literal: true

module Zoobot
  def self.gz_label_column_headers
    # as data sets change, switch to different mission label extractors, e.g. Decals is older
    %w[id_str file_loc] | LabelExtractors::GalaxyZoo::CosmicDawn.question_answers_schema
  end

  module Storage
    CONTAINER_NAME = ENV.fetch('AZURE_STORAGE_CONTAINER', 'training')
    CATALOGUE_PREFIX = "catalogues/#{Rails.env}"
    CONTAINER_CATALOG_PATH_PREFIX = "#{CONTAINER_NAME}/#{CATALOGUE_PREFIX}"
    CONTAINER_IMAGE_PATH_PREFIX = "#{CATALOGUE_PREFIX}/images"

    def self.container_name
      CONTAINER_NAME
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
