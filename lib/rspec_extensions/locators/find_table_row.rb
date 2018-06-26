require 'rspec/expectations'

module FindTableRow
  def find_table_row(*column_expectations)
    expectations_hash = column_expectations.extract_options!
    TableRowFinder.call(self, expectations_hash)
  end

  def find_table_cell(column_index_or_name, *column_expectations)
    expectations_hash = column_expectations.extract_options!
    finder = TableRowFinder.new(self, expectations_hash)
    row = finder.call
    column_index = finder.header_key_to_column_index(column_index_or_name)
    row.find(:xpath, "./td[#{column_index + 1}]")
  end

  class TableRowFinder
    def initialize(page, column_expectations)
      @page = page
      @column_expectations = column_expectations
    end

    def self.call(page, column_expectations)
      new(page, column_expectations).call
    end

    def call
      verify_table_ambiguity!
      find_row
    end

    def header_key_to_column_index(key)
      key.is_a?(String) ? existing_header_labels.index(key) : key
    end

    private

    attr_reader :page, :column_expectations

    def normalized_column_expectations
      @normalized_column_expectations ||= begin
        if column_expectations.is_a? Array
          column_expectations.each_with_index.each_with_object({}) do |(value, index), result|
            result[index] = value
          end
        else
          ensure_headers_presence!

          column_expectations.transform_keys do |key|
            header_key_to_column_index(key)
          end
        end
      end
    end

    def verify_table_ambiguity!
      if page.all('table').count > 1
        raise Capybara::Ambiguous, 'Ambiguous match, there is more than one table'
      end
    end

    def existing_header_labels
      @existing_header_labels ||= page.all('thead > tr > th').map(&:text)
    end

    def ensure_headers_presence!
      expected_header_labels = column_expectations.keys.select { |v| v.is_a? String }
      missing_headers = expected_header_labels - existing_header_labels

      if missing_headers.present?
        raise Capybara::ElementNotFound, "Could not find columns: #{missing_headers.join(', ')}"
      end
    end

    def find_row
      matching_rows = page.all('tbody > tr').find_all do |row|
        normalized_column_expectations.all? do |column_index, expectation|
          cell = row.find(:xpath, "./td[#{column_index + 1}]")
          compare(cell, expectation)
        end
      end

      if matching_rows.count > 1
        raise Capybara::Ambiguous, "Ambiguous match, found #{matching_rows.count} rows"
      elsif matching_rows.empty?
        raise Capybara::ElementNotFound, "Row with #{formatted_expected_attributes} not found"
      else
        matching_rows.first
      end
    end

    def formatted_expected_attributes
      if column_expectations.is_a?(Array)
        column_expectations.join(', ')
      else
        column_expectations.map do |header_name, expected_value|
          "#{header_name}: #{expected_value}"
        end.join(', ')
      end
    end

    def compare(cell, expectation)
      return expectation.matches?(cell) if expectation.respond_to?(:matches?)
      cell.text.strip == expectation.to_s.strip
    end
  end
end
