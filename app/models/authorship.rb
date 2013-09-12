# == Schema Information
#
# Table name: authorships
#
#  id          :integer          not null, primary key
#  tutorial_id :integer          not null
#  user_id     :integer          not null
#  rights      :integer          default(1), not null
#

class Authorship < ActiveRecord::Base
  belongs_to :user
  belongs_to :tutorial

  def tutorials_with_rights(access)
    where(:rights => access).collect { |a| a.tutorial }
  end
end
