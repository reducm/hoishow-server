class UserFollowCollaborator < ActiveRecord::Base
  belongs_to :user
  belongs_to :collaborator
end
