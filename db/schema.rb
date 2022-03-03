# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.0].define(version: 2022_03_03_161713) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "contexts", force: :cascade do |t|
    t.bigint "workflow_id", null: false
    t.bigint "project_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["workflow_id", "project_id"], name: "index_contexts_on_workflow_id_and_project_id", unique: true
  end

  create_table "predictions", force: :cascade do |t|
    t.bigint "subject_id", null: false
    t.text "image_url", null: false
    t.jsonb "results", default: {}, null: false
    t.string "user_id"
    t.string "agent_identifier"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["subject_id"], name: "index_predictions_on_subject_id"
  end

  create_table "subjects", force: :cascade do |t|
    t.bigint "subject_id", null: false
    t.jsonb "metadata", default: {}, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "context_id", null: false
    t.jsonb "locations", default: []
    t.index ["subject_id", "context_id"], name: "index_subjects_on_subject_id_and_context_id", unique: true
  end

  create_table "user_reductions", force: :cascade do |t|
    t.bigint "subject_id", null: false
    t.bigint "workflow_id", null: false
    t.jsonb "labels", default: [], null: false
    t.jsonb "raw_payload", default: {}, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["subject_id"], name: "index_user_reductions_on_subject_id"
    t.index ["workflow_id", "subject_id"], name: "index_user_reductions_on_workflow_id_and_subject_id", unique: true
  end

  add_foreign_key "subjects", "contexts"
end
