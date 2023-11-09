class Employee
  include Mongoid::Document
  include Mongoid::Timestamps
  field :_id, type: Integer
  field :first_name, type: String
  field :last_name, type: String
  field :role, type: String
  field :qualifications, type: Array
  field :assigned_project, type: Array
  field :status, type: String

  before_create :set_id

  validates :first_name, :last_name, :status, presence: true

  private
  def set_id
    last_employees = self.class.order_by(_id: 'desc').first
    self._id = last_employees ? last_employees._id + 1 : 1
  end
end
