class InitEmailAutomation < ActiveRecord::Migration
  def change
    create_table :email_automations do |t|
      t.string :automation_type
      t.integer :email_automated_id
      t.string :email_automated_type
      t.timestamps
    end

    create_table :email_automation_states do |t|
      t.integer :email_automation_id
      t.string :label
      t.datetime :handled_at
      t.timestamps
    end
  end
end
