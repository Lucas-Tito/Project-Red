class BoardPolicy < ApplicationPolicy
  def share?
    # Only the board owner can share
    record.user == user
  end

  def show?
    # Allow viewing if the user is the owner or has a valid access token
    return true if record.user == user
    
    # Logic to check the sharing token
    shared_link = BoardSharedLink.find_by(board_id: record.id, token: @token)
    shared_link.present? && !shared_link.expired?
  end

  def update?
    # Allow editing if the user is the owner or has an 'editor' token
    return true if record.user == user

    shared_link = BoardSharedLink.find_by(board_id: record.id, token: @token)
    shared_link.present? && !shared_link.expired? && shared_link.editor?
  end

  # We need to initialize the policy with the token
  def initialize(user, record, token = nil)
    @user = user
    @record = record
    @token = token
  end

  class Scope < Scope
    def resolve
      scope.all
    end
  end
end