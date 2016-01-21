# frozen_string_literal: true
Sequel.migration do
  change do
    alter_table :rubygems do
      add_column :deps_md5, String
    end
  end
end
