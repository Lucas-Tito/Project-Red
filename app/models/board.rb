class Board < ApplicationRecord
  belongs_to :user
  has_many :lists, -> { order(position: :asc) }, dependent: :destroy
  has_many :board_shared_links, dependent: :destroy
  validates :name, presence: true

  before_validation :set_default_name, on: :create

  # Checks if the given user is the owner of the board.
  #
  # @param user_to_check [User] The user to check against the board's owner.
  # @return [Boolean] Returns true if the user is the owner, false otherwise.
  def owner?(user_to_check)
    # The `user` association comes from `belongs_to :user`.
    user == user_to_check
  end

  private

  def set_default_name
    return if name.present?

    base_name = I18n.t('boards.defaults.name')
    new_name = base_name
    i = 1
    # Ensure name is unique for this user
    while user.boards.exists?(name: new_name)
      new_name = "#{base_name} (#{i})"
      i += 1
    end
    self.name = new_name
  end
end