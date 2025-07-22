class ListsController < ApplicationController
  before_action :set_list, only: [:show, :edit, :update, :destroy]

  def move
    @list = List.find(params[:id])
    @list.insert_at(params[:position].to_i)
    
    # Broadcast to all board collaborators
    BoardChannel.broadcast_to(@list.board, {
      action: 'list_moved',
      list_id: @list.id,
      new_position: params[:position].to_i
    })
    
    head :ok
  end

  # GET /lists
  def index
    # Only show lists from the current board.
    @lists = @current_board.lists.order(:position)
  end

  # GET /list/new
  def new
    @list = @current_board.lists.build
  end

  # POST /lists or /lists.json
  def create
    @list = @current_board.lists.build(list_params)

    respond_to do |format|
      if @list.save
        # Broadcast to all board collaborators
        BoardChannel.broadcast_to(@current_board, {
          action: 'list_created',
          list: @list,
          html: ApplicationController.render(
            partial: 'lists/list',
            locals: { list: @list, start_editing_name: false }
          )
        })
        
        format.turbo_stream do
          streams = [
              # Inserts new list before "New List" button.
              turbo_stream.before(
                "add_new_list_placeholder",
                partial: "lists/list",
                locals: { list: @list, start_editing_name: true }
              )
            ]
            # If it's the first list of a board, remove empty board message.
            if @current_board.lists.count == 1
              streams << turbo_stream.remove("empty_board_message")
            end
            render turbo_stream: streams
        end
        format.html { redirect_to app_root_path, notice: "List was successfully created." }
      else
        format.turbo_stream do
          render turbo_stream: turbo_stream.prepend("lists_list_container",
                                                   partial: "shared/turbo_flash",
                                                   locals: { alert: @list.errors.full_messages.join(", ") }),
                 status: :unprocessable_entity
        end
        format.html do
          @lists = @current_board.lists.order(:position)
          flash.now[:alert] = @list.errors.full_messages.join(", ")
          render 'tasks/index', status: :unprocessable_entity
        end
      end
    end
  end

  # GET /lists/:id
  def show
    # @list is defined by before_action
  end

  # GET /lists/:id/edit
  def edit
    # @list is defined by before_action
  end

  # PATCH/PUT /lists/:id or /lists/:id.json
  def update
    # @list is defined by before_action
    respond_to do |format|
      if @list.update(list_params)
        # Broadcast to all board collaborators
        BoardChannel.broadcast_to(@list.board, {
          action: 'list_updated',
          list: @list,
          html: ApplicationController.render(
            partial: 'lists/list',
            locals: { list: @list }
          )
        })
        
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(dom_id(@list),
                                                   partial: "lists/list",
                                                   locals: { list: @list })
        end
        format.html { redirect_to tasks_path, notice: "list was successfully updated." }
        format.json { render json: { id: @list.id, name: @list.name, description: @list.description }, status: :ok }
      else
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(dom_id(@list),
                                                   partial: "lists/list",
                                                   locals: { list: @list }),
                 status: :unprocessable_entity
        end
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @list.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /lists/:id
  def destroy
    # @list is defined by before_action
    # Store board reference before destroying list
    board = @list.board
    list_id = @list.id
    
    @list.destroy
    
    # Broadcast to all board collaborators
    BoardChannel.broadcast_to(board, {
      action: 'list_deleted',
      list_id: list_id
    })
    
    respond_to do |format|
      format.turbo_stream { render turbo_stream: turbo_stream.remove(dom_id(@list)) }
      format.html { redirect_to tasks_path, notice: "list excluded successfully.", status: :see_other }
    end
  end

  private

  def set_list
    @list = List.find(params[:id])
  end

  def list_params
    params.require(:list).permit(:name, :description, :color)
  end
end