class BoardSharedLinksController < ApplicationController
  before_action :set_board

  # GET /boards/:board_id/shared_links
  def index
    @shared_links = @board.board_shared_links.order(created_at: :desc)
    authorize @board, :share? # Pundit check
  end

  # POST /boards/:board_id/shared_links
  def create
    authorize @board, :share? # Pundit check

    @shared_link = @board.board_shared_links.build(shared_link_params)
    @shared_link.created_by = current_user

    if @shared_link.save
      # Broadcast to all board collaborators about new shared link
      BoardChannel.broadcast_to(@board, {
        action: 'shared_link_created',
        shared_link: @shared_link,
        board_id: @board.id
      })
      
      # Returns the successfully created link
      render partial: 'board_shared_links/shared_link', locals: { shared_link: @shared_link }, status: :created
    else
      render json: { errors: @shared_link.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @board, :share?
    @shared_link.destroy
    head :no_content # Returns 204 No Content
  end

  private

  def set_board
    @board = current_user.boards.find(params[:board_id])
  end

  def set_shared_link
    @shared_link = @board.board_shared_links.find(params[:id])
  end

  def shared_link_params
    params.require(:board_shared_link).permit(:permission)
  end
end