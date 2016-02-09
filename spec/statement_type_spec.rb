# Explicitly tests + documents the remarkably naive means by which
# we identify the verb being used in a query. This is obviously
# subpar, but as this will be called *many* times during critical
# code, we can't afford to do legitimate SQL parsing.
RSpec.describe ActiveRecordStats, '.statement_type' do
  def statement_type(sql)
    ActiveRecordStats.statement_type(sql)
  end

  it 'returns the first word from the given string' do
    expect(statement_type("SELECT * FROM t")).to eq('SELECT')
  end

  it 'returns `nil` for empty strings' do
    expect(statement_type('')).to eq(nil)
  end

  it 'upcases the word' do
    expect(statement_type('truncate t')).to eq('TRUNCATE')
  end

  it 'discards leading whitespace and `--` comments' do
    type = statement_type <<-SQL

      -- comment!
        UPDATE t SET c = 1;

    SQL
    expect(type).to eq('UPDATE')
  end

  it 'naively considers queries starting with a CTE a `WITH` statement' do
    expect(statement_type("WITH t AS (SELECT 'foo') SELECT * FROM t")).to eq('WITH')
  end
end
