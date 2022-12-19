# frozen_string_literal: true

class AddSubjectSetIdToContexts < ActiveRecord::Migration[7.0]
  def change
    add_column :contexts, :active_subject_set_id, :bigint
  end
end
