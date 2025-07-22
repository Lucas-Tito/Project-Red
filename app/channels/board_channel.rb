class BoardChannel < ApplicationCable::Channel
  def subscribed
    board = Board.find(params[:board_id])
    stream_for board
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  # Helper method to broadcast to a board by ID (useful when board is deleted)
  def self.broadcast_to_id(board_id, data)
    ActionCable.server.broadcast("board_channel:#{board_id}", data)
  end
end