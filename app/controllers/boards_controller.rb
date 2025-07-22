class BoardsController < ApplicationController
  before_action :set_board, only: [:update, :destroy]


  def index
    @boards = current_user.boards.order(:name)
    @lists = @current_board.lists.includes(:tasks).order(:position) if @current_board
  end

  # POST /boards or /boards.turbo_stream
  def create
    @old_board = @current_board
    @board = current_user.boards.build(board_params)

    respond_to do |format|
      if @board.save
        session[:board_id] = @board.id
        @current_board = @board # Update @current_board to the new board for the rendering context

        format.turbo_stream do
          render turbo_stream: [
            # Replace the old board to remove its highlight.
            (@old_board ? turbo_stream.replace(dom_id(@old_board), partial: "boards/board", locals: { board: @old_board, current_board: @current_board }) : ''),
            
            # Insert the new board, highlighted and ready for editing.
            turbo_stream.before("new_board_form", partial: "boards/board",
              locals: { board: @board, current_board: @current_board, start_editing_name: true }),
            
            # Clear lists and tasks from screen to show the ones from the new board (which are empty)
            turbo_stream.update("lists_container", "")
          ]
        end
        format.html { redirect_to app_root_path, notice: 'Board criado com sucesso.' }
      else
        format.turbo_stream do
          # Error logic to handle turbo_stream request - log error to console
          Rails.logger.error "Board creation failed: #{@board.errors.full_messages.join(', ')}"
          head :unprocessable_entity
        end
        format.html do
          # Error logic to handle html request
          @boards = current_user.boards.order(:name)
          @lists = @current_board&.lists&.includes(:tasks)&.order(:position)
          flash.now[:alert] = @board.errors.full_messages.join(", ")
          render 'tasks/index', status: :unprocessable_entity
        end
      end
    end
  end

  def update
    respond_to do |format|
      if @board.update(board_params)
        # Broadcast to all board collaborators
        BoardChannel.broadcast_to(@board, {
          action: 'board_updated',
          board: @board
        })
        
        format.turbo_stream { redirect_to app_root_path, status: :see_other }
        format.json { render json: @board, status: :ok }
        format.html { redirect_to app_root_path, notice: 'Board atualizado.' }
      else
        format.json { render json: { errors: @board.errors.full_messages }, status: :unprocessable_entity }
        format.html { render 'tasks/index', status: :unprocessable_entity }
      end
    end
  end

  def destroy
    # Store board id before destruction for broadcast
    board_id = @board.id
    
    @board.destroy

    # Broadcast to all board collaborators about board deletion
    BoardChannel.broadcast_to_id(board_id, {
      action: 'board_deleted',
      board_id: board_id
    })

    # If the deleted board was the active one,
    # defines first board from list as active.
    if session[:board_id] == board_id
      session[:board_id] = current_user.boards.order(:name).first&.id
    end

    respond_to do |format|

      # For Turbo Stream and HTML requests, the best response is a redirect.
      # Turbo will intercept and handle the transition intelligently.
      # The notice ensures that the user sees a confirmation.
      format.turbo_stream { redirect_to app_root_path, notice: 'Board excluído com sucesso.' }
      format.html { redirect_to app_root_path, notice: "Board excluído com sucesso.", status: :see_other }
    end
  end

  private

  def set_board
    @board = current_user.boards.find(params[:id])
  end

  # Use .fetch to prevent crash if 'board' param doesn't exists
  def board_params
    params.fetch(:board, {}).permit(:name)
  end

end