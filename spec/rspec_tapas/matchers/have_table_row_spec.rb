require 'spec_helper'

describe 'have_table_row matcher' do
  context 'when columns are described by name' do
    context 'when table contains expected data' do
      it 'ensures that page have table with given data' do
        page = Capybara.string <<-HTML
          <table>
            <thead>
              <tr><th>Name</th><th>Age</th></tr>
            </thead>
            <tbody>
              <tr><td>John</td><td>27</td></tr>
            </tbody>
          </table>
        HTML

        expect(page).to have_table_row('Name' => 'John', 'Age' => 27)
        expect(page).to have_table_row(0 => 'John', 1 => 27)
        expect(page).to have_table_row('John', 27)
        expect(page).to have_table_row(have_content('oh'), 27)
      end
    end

    context 'when table does not contain expected data' do
      context 'when given column does not exist' do
        it 'returns error message indicating which column is missing' do
          page = Capybara.string <<-HTML
            <table>
              <thead>
                <tr><th>Age</th></tr>
              </thead>
              <tbody>
                <tr><td>12</td></tr>
              </tbody>
            </table>
          HTML

          page_without_headers = Capybara.string <<-HTML
            <table>
              <tbody>
                <tr><td>12</td></tr>
              </tbody>
            </table>
          HTML

          expect do
            expect(page).to have_table_row('Name' => 'John', 'Age' => 27)
          end.to fail_with('Could not find columns: Name')

          expect do
            expect(page_without_headers).to have_table_row('Name' => 'John', 'Age' => 27)
          end.to fail_with('Could not find columns: Name, Age')
        end
      end

      context 'when row with given data does not exist' do
        it 'returns error messages indicating which row is missing' do
          page = Capybara.string <<-HTML
            <table>
              <thead>
                <tr><th>Name</th><th>Age</th></tr>
              </thead>
              <tbody>
                <tr><td>Adam</td><td>24</td></tr>
                <tr><td>Bartosz</td><td>12</td></tr>
              </tbody>
            </table>
          HTML

          expect do
            expect(page).to have_table_row('Age' => 27, 'Name' => 'John')
          end.to fail_with('Row with Age: 27, Name: John not found')
        end
      end
    end

    context 'when there are two tables' do
      it 'requires table to be specified' do
        page = Capybara.string <<-HTML
          <table id="first-table">
            <thead>
              <tr><th><th>Name</th><th>Age</th></tr>
            </thead>
            <tbody>
              <tr><td>John</td><td>27</td></tr>
            </tbody>
          </table>
          <table id="second-table">
            <thead>
              <tr><th><th>Name</th><th>Age</th></tr>
            </thead>
            <tbody>
              <tr><td>John</td><td>27</td></tr>
            </tbody>
          </table>
        HTML

        expect do
          expect(page).to have_table_row('John', 27)
        end.to fail_with('Ambiguous match, there is more than one table')
      end

      it 'ensures that page have table with given data' do
        page = Capybara.string <<-HTML
          <table id="first-table">
            <thead>
              <tr><th><th>Name</th><th>Age</th></tr>
            </thead>
            <tbody>
              <tr><td>John</td><td>27</td></tr>
            </tbody>
          </table>
          <table id="second-table">
            <thead>
              <tr><th><th>Name</th><th>Age</th></tr>
            </thead>
            <tbody>
              <tr><td>John</td><td>27</td></tr>
            </tbody>
          </table>
        HTML

        within(page.find('table#second-table')) do
          expect(page).to have_table_row('John', 27)
        end
      end
    end
  end
end
