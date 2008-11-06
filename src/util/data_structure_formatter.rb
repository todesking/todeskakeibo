require 'pp'
module DataStructureFormatter
  module Tree
    class Accessor
      def value_accessor &body
        @value_accessor=body
      end
      def child_enumerator &body
        @child_enumerator=body
      end
      def value_of target
        @value_accessor.call(target)
      end
      def children target
        @child_enumerator.call(target)
      end
    end
    class Formatter
      def initialize accessor
        @accessor=accessor
      end
      def format(target)
        out=[]
        format_impl(target,false,'','--',out,false)
        return out.join("\n")
      end
      def format_array(target)
        out=[]
        format_impl(target,false,'','--',out,true)
        out
      end
      def format_impl(target,parent_has_next_child,prefix,item_prefix,output,include_node)
        value=@accessor.value_of(target)
        text=prefix+item_prefix+value
        if include_node
          output << [ target, text ]
        else
          output << text
        end
        children=@accessor.children(target).to_a
        child_prefix=prefix+(parent_has_next_child ? '| ' : '  ')
        (0...children.length-1).each{|i|
          format_impl(children[i],true,child_prefix,'+-',output,include_node)
        }
        format_impl(children.last,false,child_prefix,'`-',output,include_node) unless children.empty?
      end
    end
  end
  module Table
    class Accessor
      def row_enumerator &block
        @row_enumerator=block
      end
      def column_enumerator &block
        @column_enumerator=block
      end
      def rows data
        @row_enumerator.nil? ? data : @row_enumerator.call(data)
      end
      def columns row
        @column_enumerator.nil? ? row : @column_enumerator.call(row)
      end
      def convert_to_table data
        table=[]
        rows(data).each{|row|
          table << columns(row).to_a
        }
        table
      end
    end
    class Formatter
      def initialize accessor,colnames
        @accessor=accessor
        @colnames=colnames
        @justify={}
      end
      def format data
        table=@accessor.convert_to_table(data)
        widths=column_widths(table)
        result=[]
        result << render_sepalate_line(widths)
        result << render_header(widths)
        result << render_sepalate_line(widths)
        table.each{|row| result << render_row(widths,row)}
        result << render_sepalate_line(widths)
        return result.join("\n")
      end
      def column_justify(col,value)
        @justify[col]=value
      end
      def render_sepalate_line widths
        '+'+widths.map{|w| '-'*(w+2)}.join('+')+'+'
      end
      def render_header widths
        '|'+(0...widths.length).map{|i|
          " #{@colnames[i].ljust(widths[i])} "
        }.join('|')+'|'
      end
      def render_row widths,row
        '|'+(0...widths.length).map{|i|
          value=row[i]
          width=widths[i]
          justify=
            @justify[i]||
            case
            when value.kind_of?(Numeric)
              :right
            else
              :left
            end
          justified=case justify
                    when :left
                      value.to_s.ljust(width)
                    when :right
                      value.to_s.rjust(width)
                    else
                      raise 'ASSERTION ERROR'
                    end
          " #{justified} "
        }.join('|')+'|'
      end
      def column_widths table
        widths=@colnames.map{|cn|cn.length}
        table.each{|row|
          w=row.map{|col| col.to_s.length}
          (0...row.length).each{|i|
            widths[i]=w[i] if widths[i] < w[i]
          }
        }
        widths
      end
    end
  end
end
