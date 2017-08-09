using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace LiNuoMes.Model
{
   
    public class UserAttendence
    {
        public List<string> AttendanceNum { get; set; }

        public List<string> WorkHours { get; set; }

        public List<string> TotalAttendenceHours { get; set; }

        public List<string> ActiveWorkHours { get; set; }
    }
}