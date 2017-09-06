using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace LiNuoMes.Model
{
    public class FirstLevelMaintence
    {

        public List<string> InspectionStandrad1 { set; get; }
        public List<string> InspectionStandrad2 { set; get; }
        public List<string> InspectionStandrad3 { set; get; }
        public List<string> InspectionStandrad4 { set; get; }
        public List<string> InspectionStandrad5 { set; get; }
        public List<string> InspectionStandrad6 { set; get; }
        public List<string> InspectionStandrad7 { set; get; } 
    }

    public class FirstLevelMaintenceProblem
    {
        public string ProblemID { set; get; }
        public string InspectionProblem { set; get; }
        public string InspectionDate { set; get; }
        public string FindProblem { set; get; }
        public string RepairProblem { set; get; }
        public string ReaminProblem { set; get; }
      
    }
}