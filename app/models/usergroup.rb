class Usergroup < ApplicationRecord
  has_many :user_usergroups, dependent: :destroy
  has_many :users, :through => :user_usergroups

  accepts_nested_attributes_for :user_usergroups, allow_destroy: true
end
