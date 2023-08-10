class Vehicle
  include Mongoid::Document
  include Mongoid::Timestamps

  field :_id , type: Integer
  field :name, type: String
  field :status, type: String
  field :mileage, type: Integer
  field :reg_number, type: String
  field :rev_date, type: Date
  field :assign_project, type: Array, default: []
  field :capacity, type: Integer


  before_create :set_id

  validates :name, :status, presence: true

  private
  def set_id
    last_vehicle = self.class.order_by(_id: 'desc').first
    self._id = last_vehicle ? last_vehicle._id + 1 : 1
  end


end
