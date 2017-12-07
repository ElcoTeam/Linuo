using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace LiNuoMes.Model
{
    public class ProcessArtInfo
    {
        public string ID { set; get; }
        public string InturnNumber { set; get; }
        public string ProcessCode { set; get; }
        public string ProcessName { set; get; }
        public string ArtName { set; get; }
        public string ArtValue { set; get; }
        public string UpdateUser { set; get; }
        
    }

    public class ResultMsg_ProcessArtInfo
    {
        public string result { set; get; }
        public string msg { set; get; }
        public ProcessArtInfo data { set; get; }
    }
}