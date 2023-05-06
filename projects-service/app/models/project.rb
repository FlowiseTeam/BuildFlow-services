class Project
  include Mongoid::Document
  include Mongoid::Timestamps
  field :id, type: String
  field :city, type: String
  field :client, type: String
  field :start_date, type: Date
  field :end_date, type: Date
  field :name, type: String
  field :status, type: String
  field :street, type: String
  field :zipcode, type: String
end
