using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace LiNuoMes.Model
{
    public class MaterialInfo
    {
        public string ID { set; get; }
        public string InturnNumber { set; get; }
        public string ItemNumber { set; get; }
        public string ItemDsca { set; get; }
        public string UOM { set; get; }
        public string CreateUser { set; get; }
        public string CreateTime { set; get; }
        public string ModifyUser { set; get; }
        public string ModifyTime { set; get; }
    }

    public class MaterialBfkApply
    {
        public string ID { set; get; }
        public string InturnNumber { set; get; }
        public string ItemNumber { set; get; }
        public string ItemDsca { set; get; }
        public string UOM { set; get; }
        public string ApplyQty { set; get; }
        public string ApplyUser { set; get; }
        public string ApplyTime { set; get; }
        public string Status { set; get; }
        
    }

    public class MaterialBfkResponse
    {
        public string ID { set; get; }
        
        public string ItemNumber { set; get; }
        public string ItemDsca { set; get; }
        public string UOM { set; get; }
        public string ApplyQty { set; get; }
        public string ApplyUser { set; get; }
        public string ApplyTime { set; get; }
        public string Status { set; get; }
        public string ActionQty { set; get; }
        public string ActionUser { set; get; }
        public string ActionTime { set; get; }
    }

    public class MaterialBfkConfirm
    {
        public string ID { set; get; }
        public string ItemNumber { set; get; }
        public string ItemDsca { set; get; }
        public string UOM { set; get; }
        public string ApplyQty { set; get; }
        public string ApplyUser { set; get; }
        public string ApplyTime { set; get; }
        public string Status { set; get; }
        public string ActionQty { set; get; }
        public string ActionUser { set; get; }
        public string ActionTime { set; get; }
        public string ConfirmUser { set; get; }
        public string ConfirmTime { set; get; }
        public string ConfirmQty { set; get; }
        public string PrintTime { set; get; }


    }

    public class MaterialBfkReport
    {
        public string ID { set; get; }
        public string InturnNumber { set; get; }
        public string ItemNumber { set; get; }
        public string ItemDsca { set; get; }
        public string UOM { set; get; }
        public string ApplyQty { set; get; } 
        public string ConfirmQty { set; get; }
        public string Remark { set; get; }

    }
}