class CreateMeets < ActiveRecord::Migration[5.2]
  def change
    create_table :meets do |t|
      t.references :user, foreign_key: true
      t.datetime :date

      t.timestamps
    end
  end
end