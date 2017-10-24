using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace LiNuoMes.Model
{
    public class Chart
    {
        public List<string> catagory { set; get; }

        public List<double> datavalue { set; get; }
    }

    public class DoubleChart
    {
        public List<string> catagory { set; get; }

        public List<double> datavalueFirst { set; get; }

        public List<double> datavalueSecond { set; get; }
    }

    public class ChartWithName
    {
        public string name { set; get; }
        public List<string> catagory { set; get; }

        public List<double> datavalue { set; get; }
    }

    public class ColunmChartWithName
    {
        
        public string name { set; get; }   //横轴名字 

        public double y { set; get; }      //y轴 数值
    }
}