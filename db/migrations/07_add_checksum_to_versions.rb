# frozen_string_literal: true
Sequel.migration do
  change do
    alter_table :versions do
      add_column :checksum, String, :size => 255
    end
  end
end
