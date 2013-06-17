class Authorship < ActiveRecord::Base
  belongs_to :user
  belongs_to :tutorial

  attr_protected :rights

  def tutorials_with_rights(access)
    where(:rights => access).collect { |a| a.tutorial }
  end
end
