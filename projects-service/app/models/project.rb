class Project < ApplicationRecord
  include Mongoid::Document
  include Mongoid::Timestamps
  validates :id, type: String, presence: true
  validates :city, type: String, presence: true
  validates :client, type: String, presence: true
  validates :start_date, type: Date, presence: true
  validates :end_date, type: Date, presence: true
  validates :name, type: String, presence: true
  validates :status, type: String, presence: true
  validates :street, type: String, presence: true
  validates :zipcode, type: String, presence: true
end
