# frozen_string_literal: true

class AddNonNullConstraintToContexts < ActiveRecord::Migration[7.0]
  def change
    safety_assured do
      change_column_null :contexts, :active_subject_set_id, false
    end
  end
end
