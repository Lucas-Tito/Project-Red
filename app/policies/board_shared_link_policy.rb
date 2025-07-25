class BoardSharedLinkPolicy < ApplicationPolicy
  # This policy handles authorization for BoardSharedLink records.

  # The `user` is inherited from ApplicationPolicy.
  # The `record` is the @shared_link instance from the controller.

  # Checks if a user can destroy a shared link.
  def destroy?
    # Only the owner of the board that the link belongs to can destroy it.
    # `record` here is the shared_link, which belongs_to a board.
    record.board.owner?(user)
  end
end
