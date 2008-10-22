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
        format_impl(target,false,'','--',out)
        return out.join("\n")+"\n"
      end
      def format_impl(target,parent_has_next_child,prefix,item_prefix,output)
        value=@accessor.value_of(target)
        output << prefix+item_prefix+value
        children=@accessor.children(target).to_a
        child_prefix=prefix+(parent_has_next_child ? '| ' : '  ')
        (0...children.length-1).each{|i|
          format_impl(children[i],true,child_prefix,'+-',output)
        }
        format_impl(children.last,false,child_prefix,'L-',output) unless children.empty?
      end
    end
  end
end
