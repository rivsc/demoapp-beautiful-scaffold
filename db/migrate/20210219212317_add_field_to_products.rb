class AddFieldToProducts < ActiveRecord::Migration[6.1]
  def change
    add_column :products, :my_date, :date
    add_column :products, :my_datetime, :datetime
  end
end
