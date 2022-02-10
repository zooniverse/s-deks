require 'rails_helper'

RSpec.describe Subject, type: :model do
  it 'creates a valid model' do
    expect(Subject.new).to be_valid
  end
end
