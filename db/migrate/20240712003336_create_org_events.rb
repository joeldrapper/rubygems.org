class CreateOrgEvents < ActiveRecord::Migration[7.0]
  def change
    create_table :events_org_events do |t|
      t.string :tag, null: false, index: true
      t.string :trace_id, null: true
      t.references :org, null: false, foreign_key: true
      t.references :ip_address, null: true, foreign_key: true
      t.references :geoip_info, null: true, foreign_key: true
      t.jsonb :additional

      t.timestamps
    end
  end
end
