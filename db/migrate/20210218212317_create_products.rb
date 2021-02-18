class CreateProducts < ActiveRecord::Migration[6.1]
  def change
    create_table :products do |t|
      t.float :price
      t.string :color
      t.text :description
      t.integer :family_id
      t.string :description_typetext
      t.text :description_fulltext

      t.timestamps
    end
    add_index :products, :family_id
  end
end
