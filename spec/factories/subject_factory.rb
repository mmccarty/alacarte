# == Schema Information
#
# Table name: subjects
#
#  id           :integer          not null, primary key
#  subject_code :string(255)      default("")
#  subject_name :string(255)      default("")
#

require 'faker'

FactoryGirl.define do
  factory :subject do
    subject_code { Faker::Lorem.word     }
    subject_name { Faker::Lorem.sentence }
  end
end
