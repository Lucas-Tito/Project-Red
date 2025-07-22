class BoardSharedLink < ApplicationRecord
  belongs_to :board
  belongs_to :created_by, class_name: 'User', foreign_key: 'user_id', optional: true

  # Enum for permissions
  enum :permission, { viewer: 0, editor: 1 }

  # Validations
  validates :token, presence: true, uniqueness: true
  validates :permission, presence: true

  # Callbacks
  before_validation :generate_token, on: :create
  before_validation :set_expiration_date, on: :create

  # Returns if the link is expired
  def expired?
    expires_at.present? && expires_at < Time.current
  end

  # Generates the complete URL for the sharing link
  def url(request)
    Rails.application.routes.url_helpers.board_url(board, host: request.host_with_port, token: token)
  end

  private

  def generate_token
    self.token = SecureRandom.hex(16)
  end

  # Sets the expiration date to 30 days from creation
  def set_expiration_date
    self.expires_at ||= 30.days.from_now
  end
end