class User < ActiveRecord::Base
  has_secure_password
  has_many :books, dependent: :destroy

  before_save :downcase_fields

  def downcase_fields
    self.name.downcase!
  end

  extend FriendlyId
  friendly_id :name, :use => :slugged, :slug_column => :name

  def slug_candidates
  [
    :name
  ]
  end

  def should_generate_new_friendly_id?
      new_record?
  end
end
