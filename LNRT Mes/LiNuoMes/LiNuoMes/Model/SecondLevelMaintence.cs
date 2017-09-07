using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace LiNuoMes.Model
{
    public class SecondLevelMaintence
    {
        public string PmDate { set; get; }       //日期
        public string DeviceCode { set; get; }   //设备编号
        public string DeviceName { set; get; }   //设备名称
        public string DeviceKind { set; get; }   //设备类型
        public string PowerLine { set; get; }    //电源线绝缘
        public string GroundLead { set; get; }   //接地线
        public string MaintenceTime { set; get; }  //保养工时
        public string InspectionProblem { set; get; } //保养前存在问题
        public string PmOper { set; get; }             //维护保养人员
        public string ConfirmPerson { set; get; }     //验收确认
    }


    public class SecondLevelMaintenceContent
    { 
        public string MaintenceContent { set; get; }     //保养内容
        public string IsActive { set; get; }             //保养标志
    }

    public class SecondLevelMaintenceReplace
    {
        public string PmDate { set; get; }       //日期
        public string DeviceCode { set; get; }   //设备编号
        public string DeviceName { set; get; }   //设备名称
        public string ReplacePart { set; get; }  //部位
        public string ReplaceName { set; get; }  //名称
        public string ReplaceCount { set; get; } //件数
    }
}