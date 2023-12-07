# frozen_string_literal: true

Sequel.migration do
  change do
    create_table :checksums do
      primary_key :id
      String :name
      String :md5

      index [:name], :name => :index_checksums_on_name, :unique => true
    end
  end
end
