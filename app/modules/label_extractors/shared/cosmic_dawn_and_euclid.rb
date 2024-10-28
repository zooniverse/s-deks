# frozen_string_literal: true
require_relative '../base_extractor'

module LabelExtractors
  module Shared
    class CosmicDawnAndEuclid < BaseExtractor

      def self.data_release_suffix
        raise NotImplementedError, "Subclass must define `data_release_suffix`"
      end

      # provide a flat task question and answers list for the decals mission catalogues
      def self.question_answers_schema
        label_prefixes.map do |task_key, question_prefix|
          data_labels[task_key].values.map do |answer_suffix|
            "#{question_prefix}-#{data_release_suffix}_#{answer_suffix}"
          end
        end.flatten
      end

    end
  end
end
