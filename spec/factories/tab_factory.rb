# == Schema Information
#
# Table name: tabs
#
#  id           :integer          not null, primary key
#  tab_name     :string(255)
#  updated_at   :datetime
#  position     :integer
#  template     :integer          default(2)
#  tabable_id   :integer
#  tabable_type :string(255)
#

require 'faker'

FactoryGirl.define do
  factory :tab do
    tab_name  { Faker::Lorem.sentence }
  end
end
