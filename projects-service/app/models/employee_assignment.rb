class EmployeeAssignment
     include Mongoid::Document
     include Mongoid::Timestamps
     field :_id, type: Integer
     field :project_id, type: Integer
     field :employee_id, type: Integer
     field :project_name, type: String
     belongs_to :project

     before_create :set_id

     validates :project_id, :employee_id,:project_name, presence: true
     def set_id
       last_EmployeeAssignment = self.class.order_by(_id: 'desc').first
       self._id = last_EmployeeAssignment ? last_EmployeeAssignment._id + 1 : 1
     end
end