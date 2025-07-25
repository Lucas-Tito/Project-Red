class ApplicationController < ActionController::Base
  include ActionView::RecordIdentifier
  allow_browser versions: :modern

  before_action :set_locale
  # The order of these before_actions is critical.
  # 1. Handle the token from the URL and store it in the session.
  before_action :handle_shared_token
  # 2. Authenticate the user OR validate the token from the session.
  before_action :authenticate_user
  # 3. Set the current board based on the user or the session.
  before_action :set_current_board

  private

  def set_locale
    I18n.locale = extract_locale_from_accept_language_header || I18n.default_locale
  end

  def extract_locale_from_accept_language_header
    return unless request.env['HTTP_ACCEPT_LANGUAGE']

    browser_locale = request.env['HTTP_ACCEPT_LANGUAGE'].scan(/^[a-z]{2}/).first
    I18n.available_locales.map(&:to_s).include?(browser_locale) ? browser_locale : nil
  end

  def set_current_board
    if current_user
      if params[:board_id]
        @current_board = current_user.boards.find(params[:board_id])
        session[:board_id] = @current_board.id
      elsif session[:board_id]
        @current_board = current_user.boards.find_by(id: session[:board_id])
      end

      if @current_board.nil?
        @current_board = current_user.boards.first_or_create!(name: "Meu Primeiro Board")
        session[:board_id] = @current_board.id
      end
    elsif session[:board_id]
      # This handles the case for a user accessing via a shared link who is not logged in.
      @current_board = Board.find_by(id: session[:board_id])
    end
  end

  def handle_shared_token
    # The board ID will be in `params[:id]` for the boards#show action.
    board_id = params[:id] if controller_name == 'boards'
    board_id ||= params[:board_id]

    if params[:token] && board_id
      session[:board_tokens] ||= {}
      session[:board_tokens][board_id.to_s] = params[:token]
    end
  end

  def authenticate_user
    # If a user is logged in, they are authenticated.
    return if current_user

    # If not logged in, check for a valid access token for the current board.
    board_id = params[:id] if controller_name == 'boards'
    board_id ||= params[:board_id]
    # After a redirect, the board_id won't be in the params, so we check the session.
    board_id ||= session[:board_id]

    if board_id
      # The token should now be in the session thanks to the `handle_shared_token` method.
      token = session.dig(:board_tokens, board_id.to_s)
      if token.present?
        shared_link = BoardSharedLink.find_by(board_id: board_id, token: token)
        # If the link is valid and not expired, allow access without a `current_user`.
        return if shared_link.present? && !shared_link.expired?
      end
    end

    # If there is no logged-in user and no valid token, redirect to the login page.
    redirect_to root_path
  end

  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end
  helper_method :current_user

  def pundit_user
    BoardPolicy::UserContext.new(current_user, session[:board_tokens])
  end

  def authorize(record, query = nil)
    policy = Pundit.policy(pundit_user, record)

    unless policy.public_send(query || action_name + "?")
      raise Pundit::NotAuthorizedError, "not allowed to #{query || action_name}?, this #{record.class}"
    end

    true
  end
end
