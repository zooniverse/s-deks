# frozen_string_literal: true

module ReductionBasicAuth
  def self.username
    ENV.fetch('REDUCTION_BASIC_AUTH_USERNAME', 'sdeks-user')
  end

  def self.password
    ENV.fetch('REDUCTION_BASIC_AUTH_PASSWORD', 'sdeks-password')
  end
end