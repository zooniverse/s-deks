# frozen_string_literal: true

require 'honeybadger/ruby'

module IngoredErrorRegexes
  STALE_SUBJECT_SET = /^Panoptes::Client::ServerError:.+Attempted to update a stale object: SubjectSet/.freeze
end

Honeybadger.configure do |config|
  config.before_notify do |notice|
    # avoid reporting these errors as they are expected
    notice.halt! if IngoredErrorRegexes::STALE_SUBJECT_SET.match?(notice.error_message)
  end
end
