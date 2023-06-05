class Comment
  include Mongoid::Document
  include Mongoid::Timestamps
  field :_id, type: Integer
  field :message, type: String
  field :status, type: String
  mount_uploader :image, CommentsImagesUploader
  belongs_to :project
  before_create :set_id

  validates :message, :status, presence: true
  def set_id
    last_comment = self.class.order_by(_id: 'desc').first
    self._id = last_comment ? last_comment._id + 1 : 1
  end

end
