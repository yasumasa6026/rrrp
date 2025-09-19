class AddNameToSolidQueueProcesses < ActiveRecord::Migration[8.0]
  def change
    add_column :solid_queue_processes, :name, :string
    add_index :solid_queue_processes, [:name, :supervisor_id], unique: true
  end
end
