require 'spec_helper'

RSpec.describe "ReverbNation Weird UTF-8 Behavior" do
  before(:each) do
    @normal_client = Mysql2::Client.new DatabaseCredentials['root']
    @normal_client.query "DELETE FROM mysql2_test"

    @weird_client = Mysql2::Client.new DatabaseCredentials['root'].merge(:encoding => "latin1")
  end

  after(:each) do
    @normal_client.close if @normal_client
    @weird_client.close if @weird_client
  end

  {
    'char_test' => 'CHAR',
    'varchar_test' => 'VARCHAR',
    'tiny_text_test' => 'TINYTEXT',
    'text_test' => 'TEXT',
    'medium_text_test' => 'MEDIUMTEXT',
    'long_text_test' => 'LONGTEXT',
  }.each do |field, type|
    describe type do
      it "should round-trip something in both Latin-1 and UTF-8 as UTF-8 with the connection set to latin1" do
        test_string = "\u00E9" # LATIN SMALL LETTER E WITH ACUTE (U+00E9)
        @weird_client.query("INSERT INTO mysql2_test (#{field}) VALUES ('#{test_string}')")
        id = @weird_client.last_id
        result = @weird_client.query("SELECT * from mysql2_test where id = #{id}").first
        expect(result[field]).to eql(test_string)
      end

      it "should round-trip something outside of Latin-1 as UTF-8 with the connection set to latin1" do
        test_string = "\u{1F4A9}" # PILE OF POO (U+1F4A9)
        @weird_client.query("INSERT INTO mysql2_test (#{field}) VALUES ('#{test_string}')")
        id = @weird_client.last_id
        result = @weird_client.query("SELECT * from mysql2_test where id = #{id}").first
        expect(result[field]).to eql(test_string)
      end
    end
  end
end
