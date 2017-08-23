using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace LiNuoMes.Model
{
    public class DailyCompletionRateEntity
    {
      
        public List<string> DispatchNum { set; get; }   //当日sap派工数量
        public List<string> SAPPostNum { set; get; }    //当日sap派工过账数量
        public List<string> PostNum { set; get; }       //当日过账数量
        public List<string> OrderAccuracy { set; get; } //订单准确率
        public List<string> TimelyRate { set; get; }    //订单及时率
        public List<string> AttendanceNum { set; get; } //出勤人数
        public List<string> WorkHour { set; get; }      //当日工作时间
        public List<string> AttendanceTime { set; get; } //出勤时间
        public List<string> EffectiveTime { set; get; }  //有效生产时间
        public List<string> EffectiveRate { set; get; }  //有效生产时间效率
        public List<string> MonthCompleteRate { set; get; }  //月度完成率

    } 
}