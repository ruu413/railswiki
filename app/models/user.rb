class User < ApplicationRecord
  has_many :user_usergroups, dependent: :destroy
  has_many :usergroups, :through =>:user_usergroups
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
end
