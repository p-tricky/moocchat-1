class Condition < ActiveRecord::Base
  has_many :tasks
  serialize :prologue, Array
  serialize :body, Array
  serialize :epilogue, Array
  attr_accessible :name

end
