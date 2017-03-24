module ExpertSenderApi
  module DataTable
    def add_row_to_xml(row, xml)
      xml.Row do
        insert_row_to_xml(row, xml)
      end
    end

    def insert_row_to_xml(row, xml)
      xml.Columns do
        row.each_pair { |col_name, col_value| insert_col_to_xml(col_name, col_value, xml) }
      end
    end

    def insert_col_to_xml(col_name, col_value, xml)
      xml.Column do
        xml.Name col_name
        xml.Value col_value
      end
    end
  end
end
