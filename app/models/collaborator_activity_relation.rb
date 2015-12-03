class CollaboratorActivityRelation < ActiveRecord::Base
  belongs_to :collaborator
  belongs_to :boom_activity
end
