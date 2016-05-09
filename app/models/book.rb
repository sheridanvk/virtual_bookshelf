class Book < ActiveRecord::Base
  belongs_to :user
  before_save :default_values
  def default_values
    if self.title_size.nil?
      self.title_size = '30px'
    end
  end
end
