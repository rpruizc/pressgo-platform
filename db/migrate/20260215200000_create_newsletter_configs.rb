class CreateNewsletterConfigs < ActiveRecord::Migration[8.0]
  def change
    create_table :newsletter_configs do |t|
      t.references :account, null: false, foreign_key: true, index: {unique: true}
      t.string :cadence, null: false
      t.string :tone, null: false, default: "balanced"
      t.integer :story_count, null: false, default: 5
      t.string :template_key, null: false
      t.boolean :autopilot_enabled, null: false, default: false
      t.string :default_send_timezone, null: false, default: "UTC"
      t.integer :default_send_hour, null: false, default: 9
      t.integer :default_send_minute, null: false, default: 0
      t.integer :default_send_weekday, null: false, default: 1
      t.timestamps
    end

    add_index :newsletter_configs, :cadence
  end
end
