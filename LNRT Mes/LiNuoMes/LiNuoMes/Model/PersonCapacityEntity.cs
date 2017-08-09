using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace LiNuoMes.Model
{
    public class PersonCapacityEntity
    {    
        public List<string> Yield { get; set; }

        public List<string> PersonNum { get; set; }

        public List<string> PerCapacity { get; set; }
    }
}