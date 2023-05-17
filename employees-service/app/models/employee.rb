class Employee
  include Mongoid::Document
  include Mongoid::Timestamps
  field :id, type: Integer
  field :first_name, type: String
  field :last_name, type: String
  field :role, type: String
  field :qualifications, type: Array
  field :assigned_project, type: String
  field :status, type: String
end
