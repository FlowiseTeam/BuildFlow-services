class Comment
  include Mongoid::Document
  include Mongoid::Timestamps
  field :_id, type: Integer
  field :message, type: String
  field :status, type: String
  belongs_to :project
  before_create :set_id

  def set_id
    last_comment = self.class.order_by(_id: 'desc').first
    self._id = last_comment ? last_comment._id + 1 : 1
  end

end
