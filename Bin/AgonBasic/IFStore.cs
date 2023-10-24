using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace AgonBasic
{
    class IFStore
    {
        public int line;
        public int if_index;
        public int then_index;

        public IFStore(int _line, int _if_index, int _then_index)
        {
            line = _line;
            if_index = _if_index;
            then_index = _then_index;
        }
    }
}
