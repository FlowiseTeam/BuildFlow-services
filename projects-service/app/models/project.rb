class Project < ApplicationRecord
  include Mongoid::Document
  include Mongoid::Timestamps
  validates :_id, type: Integer, presence: true
  validates :city, type: String, presence: true
  validates :client, type: String, presence: true
  validates :start_date, type: Date, presence: true
  validates :end_date, type: Date, presence: true
  validates :name, type: String, presence: true
  validates :status, type: String, presence: true
  validates :street, type: String, presence: true
  validates :zipcode, type: String, presence: true
  field :workers, type: Array, default: []
  before_create :set_id

  private

  def set_id
    last_project = self.class.order_by(_id: 'desc').first
    self._id = last_project ? last_project._id + 1 : 1
  end
end





