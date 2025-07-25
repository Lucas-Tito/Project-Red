class BoardPolicy < ApplicationPolicy
  # A context object to hold the user and any relevant tokens.
  class UserContext
    attr_reader :user, :board_tokens

    def initialize(user, board_tokens)
      @user = user
      @board_tokens = board_tokens || {}
    end
  end

  attr_reader :user_context, :board

  def initialize(user_context, board)
    # The user_context is the `pundit_user` from the controller.
    # The board is the record we're authorizing.
    @user_context = user_context
    @board = board
  end

  # The actual user object.
  def user
    user_context.user
  end

  # The token for the specific board we're checking.
  def token
    user_context.board_tokens[board.id.to_s]
  end

  # Anyone can see a board if they have a valid token.
  def show?
    # The board's owner can always see it.
    return true if board.owner?(user)

    # Check for a valid shared link token.
    shared_link = BoardSharedLink.find_by(board_id: board.id, token: token)
    shared_link.present? && !shared_link.expired?
  end

  # Called from BoardSharedLinksController#create
  # Checks if the user is allowed to create a share link for the board.
  def share?
    # Only the owner of the board can create a share link.
    board.owner?(user)
  end
end
