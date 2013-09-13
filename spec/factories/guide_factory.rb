# == Schema Information
#
# Table name: guides
#
#  id          :integer          not null, primary key
#  guide_name  :string(255)      not null
#  node_id     :integer
#  updated_at  :datetime
#  created_by  :string(255)      default("")
#  published   :boolean          default(FALSE)
#  description :text
#  relateds    :text
#

require 'faker'

FactoryGirl.define do
  factory :guide do
    guide_name { Faker::Lorem.sentence }

    factory :published_guide do
      published true
    end
  end
end
