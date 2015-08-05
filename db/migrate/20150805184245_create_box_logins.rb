class CreateBoxLogins < ActiveRecord::Migration
  def change
    create_table :box_logins do |t|
      t.string :name
      t.text :details

      t.timestamps null: false
    end
  end
end
