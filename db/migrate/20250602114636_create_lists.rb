class CreateLists < ActiveRecord::Migration[8.0]
  def change
    create_table :lists do |t|
      t.string :name
      t.text :description
      t.string :color

      t.timestamps
    end
  end
end
