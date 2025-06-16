class CreateUsers < ActiveRecord::Migration[7.1]
  def change
    create_table :users do |t|
      t.string :idfa
      t.string :ban_status, default: 'not_banned'

      t.timestamps
    end
  end
end
