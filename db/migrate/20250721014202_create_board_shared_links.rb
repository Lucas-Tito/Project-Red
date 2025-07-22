class CreateBoardSharedLinks < ActiveRecord::Migration[8.0]
  def change
    create_table :board_shared_links, id: :uuid do |t|
      t.references :board, null: false, foreign_key: true
      t.references :user, null: true, foreign_key: { to_table: :users } # created_by_user_id
      t.string :token, null: false
      t.integer :permission, default: 0, null: false # 0: viewer, 1: editor
      t.datetime :expires_at

      t.timestamps
    end
    add_index :board_shared_links, :token, unique: true
  end
end