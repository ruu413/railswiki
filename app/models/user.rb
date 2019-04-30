class User < ApplicationRecord
  has_many :user_usergroups, dependent: :destroy
  has_many :usergroups, :through =>:user_usergroups
  has_many :comments
  has_many :updatehistorys
  has_many :emojis
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :lockable, :trackable
end
