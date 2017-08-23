using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace LiNuoMes.Model
{
    public class ProductionCompareEntity
    {
        public List<string> Yiled { get; set; }

        public List<string> YiledSecond { get; set; }

        public List<string> YiledCompare { get; set; }
    }
}