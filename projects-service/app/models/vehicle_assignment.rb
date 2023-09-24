class VehicleAssignment
     include Mongoid::Document
     include Mongoid::Timestamps
     field :_id, type: Integer
     field :project_id, type: Integer
     field :vehicle_id, type: Integer
     field :project_name, type: String
     belongs_to :project

     before_create :set_id

     validates :project_id, :vehicle_id,:project_name, presence: true
     validates_uniqueness_of :vehicle_id, scope: :project_id, message: 'is already assigned to this project.'

     def set_id
       last_VehicleAssignment = self.class.order_by(_id: 'desc').first
       self._id = last_VehicleAssignment ? last_VehicleAssignment._id + 1 : 1
     end
end