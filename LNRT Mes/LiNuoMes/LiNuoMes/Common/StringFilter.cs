using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace LiNuoMes.Common
{
    public class StringFilter
    {
        public static string FilterSpecial(string strHtml)
        {
            if (string.Empty == strHtml)
            {
                return strHtml;
            }
            string[] aryReg = { "'", "'delete", "?", "<", ">", "%", ">=", "=<", "_", ";", "||", "[", "]", "&", "/", "|", " ", "''" };
            for (int i = 0; i < aryReg.Length; i++)
            {
                strHtml = strHtml.Replace(aryReg[i], string.Empty);
            }
            return strHtml;
        }
    }
    
}