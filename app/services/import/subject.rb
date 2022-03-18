# frozen_string_literal: true

module Import
  class Subject
    attr_accessor :zooniverse_subject_id, :context

    def initialize(zooniverse_subject_id, context)
      @zooniverse_subject_id = zooniverse_subject_id
      @context = context
    end

    def run
      subject = ::Subject.find_or_create_by!(context_id: context.id, zooniverse_subject_id: zooniverse_subject_id)
      SubjectBackfillerJob.perform_async(subject.id)
      subject
    end
  end
end
