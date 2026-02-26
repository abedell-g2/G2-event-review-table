class CreateEntries < ActiveRecord::Migration[7.2]
  def change
    create_table :entries do |t|
      t.string :email
      t.string :id_number, null: false

      t.timestamps
    end

    add_index :entries, :id_number, unique: true
  end
end
