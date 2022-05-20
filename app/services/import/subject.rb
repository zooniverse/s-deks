# frozen_string_literal: true

module Import
  class Subject
    attr_accessor :zooniverse_subject_id, :context

    def initialize(zooniverse_subject_id, context)
      @zooniverse_subject_id = zooniverse_subject_id
      @context = context
    end

    def run
      subject = upsert_subject
      SubjectBackfillerJob.perform_async(subject.id)
      subject
    end

    private

    def upsert_subject
      # use upsert to avoid collisions for inserting rows
      upsert_results = ::Subject.upsert_all(
        [{
          context_id: context.id,
          zooniverse_subject_id: zooniverse_subject_id
        }],
        unique_by: %i[zooniverse_subject_id context_id],
        update_only: [:context_id] # must have an update clause to get a result set
      )
      upserted_subject_id = upsert_results.to_a.first['id']
      ::Subject.find(upserted_subject_id)
    end
  end
end
