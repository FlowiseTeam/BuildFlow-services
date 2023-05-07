
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

  private

  def set_id
    self._id = self.class.increment_counter(:projects)
  end

  def self.increment_counter(name)
    counter = Counter.find_or_create_by(name: name)
    counter.inc(seq: 1)
    counter.seq
  end
end

class Counter
  include Mongoid::Document

  field :name, type: String
  field :seq, type: Integer, default: 0

  index({ name: 1 }, { unique: true, name: "name_index" })
end

