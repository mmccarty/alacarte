# == Schema Information
#
# Table name: masters
#
#  id    :integer          not null, primary key
#  value :string(255)      not null
#

require 'faker'

FactoryGirl.define do
  factory :master do
    value { Faker::Lorem.sentence }
  end
end
