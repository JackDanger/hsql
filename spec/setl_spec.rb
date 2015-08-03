describe SETL do
  let(:sql_file_name) { 'well_formed' }
  let(:sql_file) { File.expand_path("../#{sql_file_name}.sql", __FILE__) }
  let(:file_contents) { File.read(sql_file) }
  let(:environment) { 'development' }

  describe '.parse' do
    subject { SETL.parse(file_contents, environment) }

    context 'when the front matter is missing' do
      it 'throws an error'
    end

    context 'when the environment is not provided' do
      let(:environment) {}
      it 'throws an error'
    end

    context 'when there are variables in the SQL not represented in front matter' do
      let(:sql_file_name) { 'missing_variables.sql' }
      it 'throws an error'
    end

    context 'for the development environment' do
      it 'interpolates development variables'
    end

    context 'for the production environment' do
      let(:environment) { 'production' }
      it 'interpolates production variables'
    end

    context 'when using the example from the README' do
      let(:file_contents) do
        readme = File.expand_path('../../README.md', __FILE__)
        File.readlines(readme).detect do |line|
          line =~ /^    /
        end
      end

      it 'interpolates successfully' do
        puts file_contents
      end
    end
  end
end
