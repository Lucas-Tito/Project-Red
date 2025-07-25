class BoardSharedLinksController < ApplicationController
  before_action :set_board, only: [:create]
  before_action :set_shared_link, only: [:destroy]

  # Creates a new shareable link for a board.
  # POST /boards/:board_id/board_shared_links
  def create
    # Authorize that the current user is allowed to share this board.
    authorize @board, :share?

    @shared_link = @board.board_shared_links.new(shared_link_params)

    if @shared_link.save
      # Render the partial for the newly created shared link.
      render partial: 'board_shared_links/board_shared_link', locals: { board_shared_link: @shared_link }, status: :created
    else
      # If saving fails, return the errors.
      render json: { errors: @shared_link.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # Revokes a shared link.
  # DELETE /board_shared_links/:id
  def destroy
    # Authorize that the current user can destroy this link.
    authorize @shared_link

    @shared_link.destroy
    head :no_content
  end

  private

  # Finds the board associated with the request.
  def set_board
    # This needs to find the board using the `board_id` from the URL.
    @board = Board.find(params[:board_id])
  end

  # Finds the shared link to be destroyed.
  def set_shared_link
    @shared_link = BoardSharedLink.find(params[:id])
  end

  # Strong parameters for creating a shared link.
  def shared_link_params
    params.require(:board_shared_link).permit(:permission)
  end
end
