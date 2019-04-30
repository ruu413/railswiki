class Page < ApplicationRecord
  #has_many_attached :files
  #mount_uploader :file, FileUploader 
  has_many :uploadfiles#, dependent: :destroy
  has_many :comments,dependent: :destroy
  has_many :updatehistorys,dependent: :destroy
  #accepts_attachments_for :uploadfiles, attachment: :file
end
