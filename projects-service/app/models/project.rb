class Project
  include Mongoid::Document
  include Mongoid::Timestamps
  field :_id, type: Integer
  field :city, type: String
  field :client, type: String
  field :start_date, type: Date
  field :end_date, type: Date
  field :name, type: String
  field :status, type: String
  field :street, type: String
  field :zipcode, type: String
  field :workers, type: Array, default: []
  before_create :set_id

  has_many :comments, dependent: :destroy

  validates :city, :client, :start_date, :end_date, :name, :status, :street, :zipcode, presence: true


  private
  def set_id
    last_project = self.class.order_by(_id: 'desc').first
    self._id = last_project ? last_project._id + 1 : 1
  end
end