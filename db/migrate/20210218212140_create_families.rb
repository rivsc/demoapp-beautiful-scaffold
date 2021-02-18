class CreateFamilies < ActiveRecord::Migration[6.1]
  def change
    create_table :families do |t|
      t.string :name
      t.text :description
      t.string :description_typetext
      t.text :description_fulltext

      t.timestamps
    end
  end
end
