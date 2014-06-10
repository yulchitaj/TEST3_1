class CreatePnResponses < ActiveRecord::Migration
  def change
    create_table :pn_responses do |t|

      t.timestamps
    end
  end
end
